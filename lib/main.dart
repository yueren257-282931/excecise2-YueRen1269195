import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryMatchApp());
}

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Match',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C5CFF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MemoryGameScreen(),
    );
  }
}

class MemoryCard {
  MemoryCard({required this.id, required this.imagePath});

  final int id;
  final String imagePath;
  bool isFaceUp = false;
  bool isMatched = false;
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _animalImages = const [
    'assets/images/animal_fox.png',
    'assets/images/animal_panda.png',
    'assets/images/animal_cat.png',
    'assets/images/animal_dog.png',
    'assets/images/animal_lion.png',
    'assets/images/animal_rabbit.png',
    'assets/images/animal_zebra.png',
    'assets/images/animal_koala.png',
  ];

  late List<MemoryCard> _cards;
  final List<int> _selectedIndexes = [];
  bool _canTap = true;
  int _moves = 0;
  int _matches = 0;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartGame() {
    _timer?.cancel();
    final cards = <MemoryCard>[];
    for (var i = 0; i < _animalImages.length; i++) {
      cards.add(MemoryCard(id: i, imagePath: _animalImages[i]));
      cards.add(MemoryCard(id: i, imagePath: _animalImages[i]));
    }
    cards.shuffle(Random());

    setState(() {
      _cards = cards;
      _selectedIndexes.clear();
      _canTap = true;
      _moves = 0;
      _matches = 0;
      _seconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  Future<void> _onCardTap(int index) async {
    if (!_canTap || _cards[index].isFaceUp || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFaceUp = true;
      _selectedIndexes.add(index);
    });

    if (_selectedIndexes.length == 2) {
      _canTap = false;
      _moves++;
      final first = _selectedIndexes[0];
      final second = _selectedIndexes[1];

      if (_cards[first].id == _cards[second].id) {
        await Future.delayed(const Duration(milliseconds: 450));
        setState(() {
          _cards[first].isMatched = true;
          _cards[second].isMatched = true;
          _matches++;
          _selectedIndexes.clear();
          _canTap = true;
        });

        if (_matches == _animalImages.length) {
          _timer?.cancel();
          _showWinDialog();
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 850));
        setState(() {
          _cards[first].isFaceUp = false;
          _cards[second].isFaceUp = false;
          _selectedIndexes.clear();
          _canTap = true;
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('You won!'),
          content: Text('You matched all cards in $_moves moves and ${_formatTime(_seconds)}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text('Play again'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F0FF), Color(0xFFFFF9D7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildStats(),
                const SizedBox(height: 16),
                Expanded(child: _buildGrid()),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Memory Match',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF6247AA)),
              ),
              SizedBox(height: 4),
              Text(
                'Find all matching pairs!',
                style: TextStyle(fontSize: 15, color: Color(0xFF2E7D32), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: const Color(0xFFD8C8FF),
          child: Text('${_animalImages.length - _matches}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _statCard(Icons.touch_app, 'Moves', '$_moves')),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.timer, 'Time', _formatTime(_seconds))),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.emoji_events, 'Pairs', '$_matches/${_animalImages.length}')),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7C5CFF)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      itemCount: _cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _MemoryTile(
        card: _cards[index],
        onTap: () => _onCardTap(index),
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.card, required this.onTap});

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showFront = card.isFaceUp || card.isMatched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: showFront ? Colors.white : null,
          gradient: showFront
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8A64FF), Color(0xFFFFB703)],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: showFront ? const Color(0xFFDCCFFF) : Colors.transparent, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showFront
                ? Padding(
                    key: ValueKey(card.imagePath),
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(card.imagePath, fit: BoxFit.contain),
                  )
                : const Text(
                    '?',
                    key: ValueKey('back'),
                    style: TextStyle(fontSize: 36, color: Colors.red, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ),
    );
  }
}
