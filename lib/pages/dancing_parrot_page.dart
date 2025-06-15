import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class DancingParrotPage extends StatefulWidget {
  const DancingParrotPage({super.key, required this.title});

  final String title;

  @override
  State<DancingParrotPage> createState() => _DancingParrotPageState();
}

class _DancingParrotPageState extends State<DancingParrotPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _frameTimer;
  late Timer _colorTimer;

  int _currentFrame = 0;
  String _currentFrameContent = '';
  Color _currentColor = Colors.green;
  bool _isAnimating = true;

  final List<Color> _colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.yellow,
  ];

  final Random _random = Random();
  static const int _totalFrames = 10; // 0.txt to 9.txt

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _loadFrame(0);
    _startAnimation();
  }

  void _startAnimation() {
    // Frame animation timer - cycles through frames
    _frameTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        _currentFrame = (_currentFrame + 1) % _totalFrames;
      });
      _loadFrame(_currentFrame);
    });

    // Color change timer - changes color randomly
    _colorTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _currentColor = _colors[_random.nextInt(_colors.length)];
      });
    });
  }

  Future<void> _loadFrame(int frameIndex) async {
    try {
      final content = await rootBundle.loadString('lib/frames/$frameIndex.txt');
      setState(() {
        _currentFrameContent = content;
      });
    } catch (e) {
      debugPrint('Error loading frame $frameIndex: $e');
    }
  }

  void _toggleAnimation() {
    if (_isAnimating) {
      _frameTimer.cancel();
      _colorTimer.cancel();
      _animationController.stop();
      setState(() {
        _isAnimating = false;
      });
    } else {
      _startAnimation();
      _animationController.repeat();
      setState(() {
        _isAnimating = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _frameTimer.cancel();
    _colorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.blue, Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _toggleAnimation,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          child: Icon(_isAnimating ? Icons.pause : Icons.celebration, size: 24),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Disco lights
            Container(
              height: 60,
              width: double.infinity,
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: Stack(
                    children: List.generate(8, (index) {
                      return AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        left: (index * 40.0) + (_currentFrame * 5.0) % 40,
                        top: 10 + (index.isEven ? 0 : 20),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                _colors[(_currentFrame + index) %
                                    _colors.length],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    _colors[(_currentFrame + index) %
                                        _colors.length],
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Calculate responsive font size based on screen width
                  final screenWidth = MediaQuery.of(context).size.width;
                  final fontSize = (screenWidth * 0.025).clamp(8.0, 20.0);

                  return Text(
                    _currentFrameContent,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: fontSize,
                      color: _currentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
