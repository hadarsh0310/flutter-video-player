import 'package:flutter/material.dart';

class PlayerTimeline extends StatelessWidget {
  const PlayerTimeline({
    super.key,
    required this.position,
    required this.duration,
    required this.canSeek,
    required this.isLocked,
    required this.onSeek,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final Duration position;
  final Duration duration;
  final bool canSeek;
  final bool isLocked;
  final ValueChanged<double> onSeek;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds;
    final progress = maxMs > 0
        ? (position.inMilliseconds / maxMs).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (!canSeek || isLocked || width <= 0) return;

            final fraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
            onSeek(maxMs * fraction / 1000.0);
          },
          onHorizontalDragStart: (_) {
            if (canSeek && !isLocked) {
              onDragStart();
            }
          },
          onHorizontalDragUpdate: (details) {
            if (!canSeek || isLocked || width <= 0) return;

            final fraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
            onDragUpdate(maxMs * fraction);
          },
          onHorizontalDragEnd: (_) {
            if (canSeek && !isLocked) {
              onDragEnd();
            }
          },
          onHorizontalDragCancel: () {
            if (canSeek && !isLocked) {
              onDragCancel();
            }
          },
          child: SizedBox(
            height: 16,
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(color: Colors.white24),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
