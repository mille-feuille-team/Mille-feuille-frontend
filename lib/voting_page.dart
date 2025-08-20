import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// main.dart�ɂ���ResultsPage���C���|�[�g
import 'main.dart'; 

// ���[��ʂ�Widget
class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  // Go�T�[�o�[��URL
  final String _baseUrl = 'http://localhost:8080';
  
  // ���͂��ꂽ���[�U�[�����Ǘ����邽�߂̃R���g���[���[
  final _textController = TextEditingController();

  // �ʐM�����ǂ�����������ԕϐ�
  bool _isLoading = false;

  // ���������[�N��h�����߂ɁA�s�v�ɂȂ����R���g���[���[��j��
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Go�T�[�o�[�ɓ��[�f�[�^�𑗐M����񓯊��֐�
  Future<void> _submitVote(String voteOption) async {
    final userId = _textController.text;

    // ���[�U�[�������͂���Ă��Ȃ��ꍇ�̓G���[���b�Z�[�W��\�����ď����𒆒f
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('���[�U�[������͂��Ă�������')),
      );
      return;
    }

    // �ʐM���̏�Ԃɐݒ�
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vote'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // ���M����f�[�^��JSON�`���ɕϊ�
        body: jsonEncode({
          'userId': userId,
          'vote': voteOption,
        }),
      );

      // ���[�����������猋�ʕ\���y�[�W�Ɉړ�
      if (response.statusCode == 200 && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultsPage()),
        );
      } else if (mounted) {
        // ���s������G���[���b�Z�[�W��\��
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('���[�Ɏ��s���܂���')),
        );
      }
    } catch (e) {
      // �ʐM�G���[�����������ꍇ
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('�G���[������: $e')),
        );
      }
    } finally {
      // �����E���s�ɂ�����炸�A�ʐM������Ԃɐݒ�
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
        title: const Text("���[����"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ���[�U�[�����͗�
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: '���[�U�[��',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              
              // �ʐM���̓��[�f�B���O�A�C�R���A�����łȂ���Γ��[�{�^����\��
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _submitVote('����'),
                          child: const Text('����', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _submitVote('���傤�ǂ悢'),
                          child: const Text('���傤�ǂ悢', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _submitVote('���ނ�'),
                          child: const Text('���ނ�', style: TextStyle(fontSize: 20)),
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