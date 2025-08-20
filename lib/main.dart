import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// 新しく作成したvoting_page.dartをインポート
import 'voting_page.dart';

void main() {
  runApp(const MyApp());
}

// アプリ全体のルートとなるWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '投票アプリ',
      // 最初のページをResultsPageからVotingPageに変更
      home: VotingPage(),
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
  // 接続先のGoサーバーのURL
  final String _baseUrl = 'http://localhost:8080';
  
  // サーバーから取得した投票結果を保存するための変数
  Map<String, int>? _voteResults;
  
  // 5秒ごとにデータを自動更新するためのタイマー変数
  Timer? _timer;

  // このページが表示された時に、最初に一度だけ実行される初期化処理
  @override
  void initState() {
    super.initState();
    _fetchResults();

    // 5秒ごとに_fetchResults関数を繰り返し実行するタイマーを開始
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchResults();
    });
  }

  // このページが破棄される時に実行される後片付け処理
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Goサーバーに接続して、最新の投票結果を取得する非同期関数
  Future<void> _fetchResults() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/results'));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decodedBody);

        if (mounted) {
          setState(() {
            _voteResults = data.map((key, value) => MapEntry(key, value as int));
          });
        }
      }
    } catch (e) {
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
        child: _voteResults == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text("あつい", style: TextStyle(fontSize: 24)),
                        trailing: Text(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchResults,
        tooltip: '更新',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}}