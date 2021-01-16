import 'package:cached_video_player/cached_video_player.dart';
import 'package:cachedflickvideoplayer/manager/flick_manager.dart';
import 'package:cachedflickvideoplayer/widgets/flick_current_position.dart';
import 'package:cachedflickvideoplayer/widgets/flick_total_duration.dart';
import 'package:cachedflickvideoplayer/widgets/flick_video_brightness_bar.dart';
import 'package:cachedflickvideoplayer/widgets/flick_video_volume_bar.dart';
import 'package:cachedflickvideoplayer/widgets/helpers/flick_auto_hide_child.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// GestureDetector's that calls [flickControlManager.seekForward]/[flickControlManager.seekBackward] onTap of opaque area/child.
///
/// Renders two GestureDetector inside a row, the first detector is responsible to seekBackward and the second detector is responsible to seekForward.
class FlickSeekVideoAction extends StatelessWidget {
  const FlickSeekVideoAction({
    Key key,
    this.child,
    this.forwardSeekIcon = const Icon(Icons.fast_forward),
    this.backwardSeekIcon = const Icon(Icons.fast_rewind),
    this.duration = const Duration(seconds: 10),
    this.fontSize = 20.0,
    this.seekForward,
    this.seekBackward,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
  }) : super(key: key);

  /// Widget to be stacked above this action.
  final Widget child;
  final Function onDragEnd;
  final Function onDragStart;
  final Function onDragUpdate;

  /// Widget to be shown when user forwardSeek the video.
  ///
  /// This widget is shown for a duration managed by [FlickDisplayManager].
  final Widget forwardSeekIcon;

  /// Widget to be shown when user backwardSeek the video.
  ///
  /// This widget is shown for a duration managed by [FlickDisplayManager].
  final Widget backwardSeekIcon;

  /// Function called onTap of [forwardSeekIcon].
  ///
  /// Default action -
  /// ``` dart
  ///    controlManager.seekForward(Duration(seconds: 10));
  /// ```
  final Function seekForward;

  /// Function called onTap of [backwardSeekIcon].
  ///
  /// Default action -
  /// ``` dart
  ///     controlManager.seekBackward(Duration(seconds: 10));
  /// ```
  final Function seekBackward;

  /// Duration by which video will be seek.
  final Duration duration;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);
    displayManager.setFirstBrightness();

    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);
    CachedVideoPlayerValue cachedVideoPlayerValue =
        videoManager.cachedVideoPlayerValue;

    bool showForwardSeek = displayManager.showForwardSeek;
    void seekToRelativePosition(Offset globalPosition) {
      Duration position = videoManager?.cachedVideoPlayerValue?.position;
      Duration duration = videoManager?.cachedVideoPlayerValue?.duration;
      final double _seekP = duration.inMilliseconds.toDouble() /
          150 *
          globalPosition.dx.clamp(-1.0, 1.0);
      final double seekPos = (position.inMilliseconds + _seekP)
          .clamp(0.0, duration.inMilliseconds.toDouble());
      controlManager.seekTo(Duration(milliseconds: seekPos.toInt()));
    }

    Widget _child = displayManager.showSeekTime
        ? Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                      color: Colors.transparent,
                      child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              FlickCurrentPosition(
                                fontSize: fontSize,
                                color: Colors.white,
                              ),
                              FlickAutoHideChild(
                                autoHide: false,
                                child: Text(
                                  ' / ',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: fontSize),
                                ),
                              ),
                              FlickTotalDuration(
                                fontSize: fontSize,
                                color: Colors.white,
                              )
                            ],
                          )))
                ]))
        : child;
    return Stack(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (DragStartDetails details) {
                  if (!cachedVideoPlayerValue.initialized) {
                    return;
                  }
                  if (videoManager.isPlaying) {
                    controlManager.autoPause();
                  }
                  if (onDragStart != null) {
                    onDragStart();
                  }
                },
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  if (!cachedVideoPlayerValue.initialized) {
                    return;
                  }
                  controlManager.autoPause();
                  displayManager.handleSeekTime(show: true);
                  // displayManager.handleTogglePlayerControls(show: false);
                  seekToRelativePosition(details.delta);
                  if (onDragUpdate != null) {
                    onDragUpdate();
                  }
                },
                onHorizontalDragEnd: (DragEndDetails details) {
                  controlManager.autoResume();
                  displayManager.handleSeekTime(show: false);
                  // displayManager.handleTogglePlayerControls(show: false);
                  if (onDragEnd != null) {
                    onDragEnd();
                  }
                },
                onVerticalDragUpdate: (DragUpdateDetails details) async {
                  final box = context.findRenderObject() as RenderBox;
                  Offset _offset = box.globalToLocal(details.globalPosition);
                  if (_offset.dx > box.size.width / 2) {
                    displayManager.handleShowVolume(show: true);
                    double volume = (cachedVideoPlayerValue.volume -
                            details.delta.dy.clamp(-0.055, 0.055))
                        .clamp(0.0, 1.0);
                    controlManager.setVolume(volume);
                  } else {
                    displayManager.handleShowBrightness(show: true);
                    double brightness = (displayManager.brightness -
                            details.delta.dy.clamp(-0.055, 0.055))
                        .clamp(0.0, 1.0);
                    displayManager.setBrightness(brightness);
                  }
                },
                onVerticalDragStart: (DragStartDetails details) {
                  final box = context.findRenderObject() as RenderBox;
                  Offset _offset = box.globalToLocal(details.globalPosition);
                  if (_offset.dx > box.size.width / 2) {
                    displayManager.handleShowVolume(show: true);
                  } else {
                    displayManager.handleShowBrightness(show: true);
                  }
                },
                onVerticalDragEnd: (DragEndDetails details) {},
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedCrossFade(
                    duration: Duration(milliseconds: 100),
                    firstChild: IconTheme(
                        data: IconThemeData(
                          color: Colors.transparent,
                        ),
                        child: forwardSeekIcon),
                    crossFadeState: showForwardSeek
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    secondChild: IconTheme(
                      data: IconThemeData(color: Colors.white),
                      child: forwardSeekIcon,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        if (_child != null) _child,
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          displayManager.showBrightness
              ? Container(
                  child: FlickVideoBrightnessBar(
                      brightness: displayManager.brightness))
              : displayManager.showVolume
                  ? Container(
                      child: FlickVideoVolumeBar(
                          volume: cachedVideoPlayerValue.volume))
                  : Container(),
        ]),
      ],
    );
  }
}
