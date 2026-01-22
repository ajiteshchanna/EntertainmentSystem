import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  bool _isLoading = true;
  bool _showControls = true;
  bool _isFullscreen = false;

  Timer? _hideTimer;

  // Double tap overlays
  bool _showForwardIcon = false;
  bool _showRewindIcon = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
        _startHideTimer();
      });

    // controls auto update during playback
    _controller.addListener(() {
      if (mounted && _controller.value.isPlaying) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _exitFullscreen();
    _controller.dispose();
    super.dispose();
  }

  // ✅ Auto hide logic
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  // ✅ Play / Pause
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
        _hideTimer?.cancel();
      } else {
        _controller.play();
        _showControls = true;
        _startHideTimer();
      }
    });
  }

  // ✅ Seek helper
  Future<void> _seekBy(Duration offset) async {
    final current = _controller.value.position;
    final target = current + offset;

    final duration = _controller.value.duration;

    Duration finalTarget = target;

    if (finalTarget < Duration.zero) {
      finalTarget = Duration.zero;
    } else if (finalTarget > duration) {
      finalTarget = duration;
    }

    await _controller.seekTo(finalTarget);

    setState(() {
      _showControls = true;
    });
    _startHideTimer();
  }

  // ✅ Double tap rewind
  void _doubleTapRewind() async {
    setState(() => _showRewindIcon = true);
    await _seekBy(const Duration(seconds: -10));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showRewindIcon = false);
    });
  }

  // ✅ Double tap forward
  void _doubleTapForward() async {
    setState(() => _showForwardIcon = true);
    await _seekBy(const Duration(seconds: 10));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showForwardIcon = false);
    });
  }

  // ✅ Fullscreen enter/exit
  Future<void> _enterFullscreen() async {
    setState(() => _isFullscreen = true);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullscreen() async {
    setState(() => _isFullscreen = false);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      _exitFullscreen();
    } else {
      _enterFullscreen();
    }
  }

  // ✅ Time format
  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    final hours = d.inHours;

    if (hours > 0) {
      return "${hours.toString().padLeft(2, "0")}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text(widget.title),
              backgroundColor: Colors.black,
            ),
      body: SafeArea(
        top: !_isFullscreen,
        bottom: !_isFullscreen,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onTap: _toggleControls,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ✅ VIDEO
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),

                      // ✅ Double tap Left (-10 sec)
                      Positioned.fill(
                        left: 0,
                        right: MediaQuery.of(context).size.width / 2,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: _doubleTapRewind,
                        ),
                      ),

                      // ✅ Double tap Right (+10 sec)
                      Positioned.fill(
                        left: MediaQuery.of(context).size.width / 2,
                        right: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: _doubleTapForward,
                        ),
                      ),

                      // ✅ Rewind Icon Overlay
                      if (_showRewindIcon)
                        const Positioned(
                          left: 60,
                          child: Icon(
                            Icons.replay_10,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),

                      // ✅ Forward Icon Overlay
                      if (_showForwardIcon)
                        const Positioned(
                          right: 60,
                          child: Icon(
                            Icons.forward_10,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),

                      // ✅ Controls Overlay
                      if (_showControls)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.35),
                          ),
                        ),

                      // ✅ Center Play/Pause Button (YouTube style)
                      if (_showControls)
                        IconButton(
                          iconSize: 70,
                          color: Colors.white,
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                          ),
                        ),

                      // ✅ Bottom Controls
                      if (_showControls)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Text(
                                    _format(_controller.value.position),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "/",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _format(_controller.value.duration),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const Spacer(),

                                  IconButton(
                                    onPressed: _toggleFullscreen,
                                    icon: Icon(
                                      _isFullscreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
