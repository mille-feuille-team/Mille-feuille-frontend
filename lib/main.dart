import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// アプリ全体のルートとなるWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリの基本的な設定（タイトルなど）を行い、最初のページとしてResultsPageを指定
    return const MaterialApp(
      title: '投票結果',
      home: ResultsPage(),
    );
  }
}

// 投票結果を表示するための、状態を持つページWidget
class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

// ResultsPageの実際の状態を管理するクラス
class _ResultsPageState extends State<ResultsPage> {
  // 接続先のGoサーバーのURL。自分のPCで動かす場合はこのままでOK
  final String _baseUrl = 'http://localhost:8080';
  
  // サーバーから取得した投票結果を保存するための変数 (最初はデータがないのでnull)
  Map<String, int>? _voteResults;
  
  // 5秒ごとにデータを自動更新するためのタイマー変数
  Timer? _timer;

  // このページが表示された時に、最初に一度だけ実行される初期化処理
  @override
  void initState() {
    super.initState();
    // すぐに結果を取得しにいく
    _fetchResults();

    // 5秒ごとに_fetchResults関数を繰り返し実行するタイマーを開始
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchResults();
    });
  }

  // このページが破棄される時に実行される後片付け処理
  @override
  void dispose() {
    // メモリリークを防ぐために、不要になったタイマーを停止する
    _timer?.cancel();
    super.dispose();
  }

  // Goサーバーに接続して、最新の投票結果を取得する非同期関数
  Future<void> _fetchResults() async {
    try {
      // Goサーバーの/resultsエンドポイントにGETリクエストを送信
      final response = await http.get(Uri.parse('$_baseUrl/results'));

      // サーバーからの応答が成功(ステータスコード200)だった場合
      if (response.statusCode == 200) {
        // 日本語が文字化けしないようにUTF-8でデコード
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decodedBody);

        // このページがまだ画面に表示されている場合のみ、UIの状態を更新
        if (mounted) {
          setState(() {
            _voteResults = data.map((key, value) => MapEntry(key, value as int));
          });
        }
      }
    } catch (e) {
      // 通信中にエラーが発生した場合
      print("結果の取得に失敗: $e");
    }
  }

  // 画面のUIを構築するメインの処理
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("現在の投票結果"),
      ),
      body: Center(
        // _voteResultsにまだデータが入っていない（nullの）場合は、ローディングアイコンを表示
        child: _voteResults == null
            ? const CircularProgressIndicator()
            // データがあれば、結果を表示
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 結果表示用のカード
                    Card(
                      child: ListTile(
                        title: const Text("あつい", style: TextStyle(fontSize: 24)),
                        trailing: Text(
                          // _voteResultsがnullでないことを!で保証して表示
                          _voteResults!['あつい'].toString(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("ちょうどよい", style: TextStyle(fontSize: 24)),
                        trailing: Text(
                          _voteResults!['ちょうどよい'].toString(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("さむい", style: TextStyle(fontSize: 24)),
                        trailing: Text(
                          _voteResults!['さむい'].toString(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      // 手動更新ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchResults,
        tooltip: '更新',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}