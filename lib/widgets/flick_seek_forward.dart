import 'package:cachedflickvideoplayer/manager/flick_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Show a widget based on play/pause state of the player and toggle the same.
class FlickSeekForward extends StatelessWidget {
  const FlickSeekForward({
    Key key,
    this.seekChild,
    this.seekForward,
    this.color,
    this.size,
    this.padding,
    this.decoration,
    this.duration = const Duration(seconds: 10),
  }) : super(key: key);

  /// Widget shown when the video is paused.
  ///
  /// Default - Icon(Icons.play_arrow)
  final Widget seekChild;

  /// Duration by which video will be seek.
  final Duration duration;

  /// Function called onTap of visible child.
  ///
  /// Default action -
  /// ``` dart
  ///     videoManager.isVideoEnded
  ///     ? controlManager.forward()
  ///     : controlManager.seekForward();
  /// ```
  final Function seekForward;

  /// Size for the default icons.
  final double size;

  /// Color for the default icons.
  final Color color;

  /// Padding around the visible child.
  final EdgeInsetsGeometry padding;

  /// Decoration around the visible child.
  final Decoration decoration;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);

    Widget seekWidget = seekChild ??
        Icon(
          Icons.forward_10,
          size: size,
          color: color,
        );
    Widget child = seekWidget;

    return GestureDetector(
        key: key,
        onTap: () {
          displayManager.handleShowPlayerControls();
          if (seekForward != null) {
            seekForward();
          } else {
            videoManager.isVideoEnded
                ? controlManager.replay()
                : controlManager.seekForward(duration);
          }
        },
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ));
  }
}
