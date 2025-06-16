import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DancingParrotPage extends StatefulWidget {
  const DancingParrotPage({super.key, required this.title});

  final String title;

  @override
  State<DancingParrotPage> createState() => _DancingParrotPageState();
}

class _DancingParrotPageState extends State<DancingParrotPage>
    with SingleTickerProviderStateMixin {
  // Constants
  static const int _totalFrames = 10;
  static const Duration _animationDuration = Duration(milliseconds: 100);
  static const Duration _colorChangeDuration = Duration(milliseconds: 300);
  static const Duration _sliderAnimationDuration = Duration(milliseconds: 300);
  static const double _minAnimationSpeed = 20.0;
  static const double _maxAnimationSpeed = 200.0;
  static const double _defaultAnimationSpeed = 80.0;

  // Animation controllers and timers
  late AnimationController _animationController;
  late Timer _frameTimer;
  late Timer _colorTimer;

  // State variables
  int _currentFrame = 0;
  String _currentFrameContent = '';
  Color _currentColor = Colors.green;
  bool _isAnimating = true;
  bool _showSpeedSlider = false;
  double _animationSpeed = _defaultAnimationSpeed;

  // Color palette
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

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _loadFrame(0);
    _startAnimation();
  }

  void _startAnimation() {
    _startFrameTimer();
    _startColorTimer();
  }

  void _startFrameTimer() {
    _frameTimer = Timer.periodic(
      Duration(milliseconds: _animationSpeed.round()),
      (timer) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % _totalFrames;
        });
        _loadFrame(_currentFrame);
      },
    );
  }

  void _startColorTimer() {
    _colorTimer = Timer.periodic(_colorChangeDuration, (timer) {
      setState(() {
        _currentColor = _colors[_random.nextInt(_colors.length)];
      });
    });
  }

  void _stopAnimation() {
    _frameTimer.cancel();
    _colorTimer.cancel();
    _animationController.stop();
  }

  void _restartFrameTimer() {
    _frameTimer.cancel();
    _startFrameTimer();
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
      _stopAnimation();
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

  void _toggleSpeedSlider() {
    setState(() {
      _showSpeedSlider = !_showSpeedSlider;
    });
  }

  void _updateAnimationSpeed(double newSpeed) {
    setState(() {
      _animationSpeed = newSpeed;
    });

    if (_isAnimating) {
      _restartFrameTimer();
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
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButtons(),
      body: _buildBody(context),
    );
  }

  // UI Component Methods
  AppBar _buildAppBar() {
    return AppBar(backgroundColor: Colors.black);
  }

  Widget _buildFloatingActionButtons() {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSpeedSlider(),
          _buildSpeedButton(),
          _buildPlayPauseButton(),
        ],
      ),
    );
  }

  Widget _buildSpeedSlider() {
    return AnimatedContainer(
      duration: _sliderAnimationDuration,
      curve: Curves.easeInOut,
      height: _showSpeedSlider ? 200 : 0,
      width: 60,
      margin: EdgeInsets.only(bottom: _showSpeedSlider ? 10 : 0),
      decoration: BoxDecoration(
        gradient: _showSpeedSlider ? _buildGradient() : null,
        borderRadius: BorderRadius.circular(30),
      ),
      child: _showSpeedSlider ? _buildSliderContent() : const SizedBox.shrink(),
    );
  }

  Widget _buildSliderContent() {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: RotatedBox(
        quarterTurns: 3,
        child: SliderTheme(
          data: _buildSliderTheme(),
          child: Slider(
            value: _animationSpeed,
            min: _minAnimationSpeed,
            max: _maxAnimationSpeed,
            divisions: 18,
            onChanged: _updateAnimationSpeed,
          ),
        ),
      ),
    );
  }

  SliderThemeData _buildSliderTheme() {
    return SliderTheme.of(context).copyWith(
      trackHeight: 8,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
      thumbColor: Colors.white,
      overlayColor: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildSpeedButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: _buildGradient(),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        heroTag: "speed",
        onPressed: _toggleSpeedSlider,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: Icon(_showSpeedSlider ? Icons.close : Icons.speed, size: 24),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: _buildGradient(),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        heroTag: "play",
        onPressed: _toggleAnimation,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: Icon(_isAnimating ? Icons.pause : Icons.celebration, size: 24),
      ),
    );
  }

  LinearGradient _buildGradient() {
    return LinearGradient(
      colors: [Colors.green, Colors.blue, Colors.purple, Colors.pink],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDiscoLights(),
          const SizedBox(height: 20),
          _buildParrotDisplay(context),
        ],
      ),
    );
  }

  Widget _buildDiscoLights() {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 320,
          child: Stack(
            children: List.generate(8, (index) => _buildDiscoLight(index)),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoLight(int index) {
    return AnimatedPositioned(
      duration: _sliderAnimationDuration,
      left: (index * 40.0) + (_currentFrame * 5.0) % 40,
      top: 10 + (index.isEven ? 0 : 20),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _colors[(_currentFrame + index) % _colors.length],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _colors[(_currentFrame + index) % _colors.length],
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParrotDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => _buildParrotText(context),
      ),
    );
  }

  Widget _buildParrotText(BuildContext context) {
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
  }
}
