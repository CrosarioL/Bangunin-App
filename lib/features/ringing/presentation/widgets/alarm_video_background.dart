import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../alarms/domain/alarm_clip.dart';

/// Full-bleed, muted, looping video behind the ringing screen.
///
/// The sound comes from AlarmAudioService on the alarm stream, never from
/// here (see [AlarmClip]). This widget only follows it: every time the audio
/// loops, the video jumps back to the start so the two can't drift apart.
///
/// Anything that goes wrong (a missing asset, a codec the device can't
/// decode) leaves the plain ringing screen in place. A video alarm must
/// never be the reason an alarm screen fails to show.
class AlarmVideoBackground extends ConsumerStatefulWidget {
  const AlarmVideoBackground({super.key, required this.clip});

  final AlarmClip clip;

  @override
  ConsumerState<AlarmVideoBackground> createState() =>
      _AlarmVideoBackgroundState();
}

class _AlarmVideoBackgroundState extends ConsumerState<AlarmVideoBackground> {
  late final VideoPlayerController _controller = VideoPlayerController.asset(
    widget.clip.videoAsset,
    // Never take audio focus from the alarm itself.
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  StreamSubscription<void>? _loops;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.setLooping(true);
      await _controller.play();
    } on Object {
      return;
    }
    _loops = ref
        .read(alarmAudioServiceProvider)
        .loopRestarts
        .listen((_) => unawaited(_controller.seekTo(Duration.zero)));
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    unawaited(_loops?.cancel());
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _controller.value.size;
    return Stack(
      fit: StackFit.expand,
      children: [
        // The thumbnail covers the gap while the decoder spins up, so the
        // screen never flashes black at the moment someone opens their eyes.
        Image.asset(
          widget.clip.thumbnailAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
        if (_ready && !size.isEmpty)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        // Keeps the clock and the stop controls legible over any footage.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x5506152D),
                Color(0x2206152D),
                AppColors.nightTop,
              ],
              stops: [0, .45, 1],
            ),
          ),
        ),
      ],
    );
  }
}
