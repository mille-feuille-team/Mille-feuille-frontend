import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '室温投票アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '今の室温は？'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, int> _votes = {'暑い': 0, 'ちょうどいい': 0, '寒い': 0};
  String? _selectedChoice;
  String? _votedChoice;
  bool _isPressed = false;
  bool _showConfirmation = false;

  void _submitVote() {
    if (_selectedChoice == null) return;

    setState(() {
      if (_votedChoice != null) {
        _votes[_votedChoice!] = (_votes[_votedChoice!] ?? 1) - 1;
      }
      _votes[_selectedChoice!] = (_votes[_selectedChoice!] ?? 0) + 1;
      _votedChoice = _selectedChoice;
      _showConfirmation = true;
    });
  }

  Widget _buildChoiceButtons() {
    final choices = ['暑い', 'ちょうどいい', '寒い'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: choices.map((label) {
        final isSelected = _selectedChoice == label;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color.fromARGB(255, 58, 183, 148)
                : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          onPressed: () {
            setState(() {
              _selectedChoice = label;
              _showConfirmation = false;
            });
          },
          child: Text('$label（${_votes[label]}票）'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('あなたの感じ方', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                _buildChoiceButtons(),
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()..scale(_isPressed ? 1.05 : 1.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: _selectedChoice == null
                        ? null
                        : () {
                            setState(() => _isPressed = true);
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                setState(() => _isPressed = false);
                                _submitVote();
                              },
                            );
                          },
                    child: const Text('投票する', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _showConfirmation ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: _votedChoice != null
                      ? Text(
                          '✓ あなたの投票: $_votedChoice',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
