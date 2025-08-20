import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// main.dartにあるResultsPageをインポート
import 'main.dart'; 

// 投票画面のWidget
class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  // GoサーバーのURL
  final String _baseUrl = 'http://localhost:8080';
  
  // 入力されたユーザー名を管理するためのコントローラー
  final _textController = TextEditingController();

  // 通信中かどうかを示す状態変数
  bool _isLoading = false;

  // メモリリークを防ぐために、不要になったコントローラーを破棄
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Goサーバーに投票データを送信する非同期関数
  Future<void> _submitVote(String voteOption) async {
    final userId = _textController.text;

    // ユーザー名が入力されていない場合はエラーメッセージを表示して処理を中断
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザー名を入力してください')),
      );
      return;
    }

    // 通信中の状態に設定
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vote'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // 送信するデータをJSON形式に変換
        body: jsonEncode({
          'userId': userId,
          'vote': voteOption,
        }),
      );

      // 投票が成功したら結果表示ページに移動
      if (response.statusCode == 200 && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultsPage()),
        );
      } else if (mounted) {
        // 失敗したらエラーメッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投票に失敗しました')),
        );
      }
    } catch (e) {
      // 通信エラーが発生した場合
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生: $e')),
        );
      }
    } finally {
      // 成功・失敗にかかわらず、通信完了状態に設定
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("投票する"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ユーザー名入力欄
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'ユーザー名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              
              // 通信中はローディングアイコン、そうでなければ投票ボタンを表示
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _submitVote('あつい'),
                          child: const Text('あつい', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _submitVote('ちょうどよい'),
                          child: const Text('ちょうどよい', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _submitVote('さむい'),
                          child: const Text('さむい', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}