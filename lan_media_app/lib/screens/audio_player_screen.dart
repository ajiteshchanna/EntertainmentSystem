import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_model.dart';
import '../core/config.dart';

class AudioPlayerScreen extends StatefulWidget {
  final MediaModel media;

  const AudioPlayerScreen({super.key, required this.media});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _loading = true;

  String get audioUrl {
    final encodedName = Uri.encodeComponent(widget.media.name);
    return "${AppConfig.baseUrl}/api/stream/$encodedName";
  }


  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(audioUrl);
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load audio: $e")),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.media.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note, size: 80),
                  const SizedBox(height: 20),

                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;

                      return ElevatedButton.icon(
                        onPressed: () async {
                          if (playing) {
                            await _player.pause();
                          } else {
                            await _player.play();
                          }
                        },
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        label: Text(playing ? "Pause" : "Play"),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _player.duration ?? Duration.zero;

                      final maxSeconds = duration.inSeconds.toDouble();
                      final currentSeconds = position.inSeconds.toDouble();

                      return Column(
                        children: [
                          Slider(
                            min: 0,
                            max: maxSeconds > 0 ? maxSeconds : 1,
                            value: currentSeconds.clamp(0, maxSeconds > 0 ? maxSeconds : 1),
                            onChanged: (value) async {
                              await _player.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_format(position)),
                              Text(_format(duration)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
