import 'package:cached_video_player/cached_video_player.dart';
import 'package:cachedflickvideoplayer/controls/flick_portrait_controls.dart';
import 'package:cachedflickvideoplayer/controls/flick_video_with_controls.dart';
import 'package:cachedflickvideoplayer/flick_video_player.dart';
import 'package:cachedflickvideoplayer/manager/flick_manager.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      title: 'Cachedflickvideoplayer demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ViewPage(),
    ));

class ViewPage extends StatefulWidget {
  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  FlickManager flickManager;

  _ViewPageState() {
    flickManager = initVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FlickVideoPlayer(
                  flickManager: flickManager,
                  flickVideoWithControls: FlickVideoWithControls(
                    videoFit: BoxFit.contain,
                    controls: FlickPortraitControls(),
                  ),
                  flickVideoWithControlsFullscreen: FlickVideoWithControls(
                    videoFit: BoxFit.contain,
                    controls: FlickPortraitControls(),
                  ),
                ))));
  }

  @override
  void dispose() {
    super.dispose();
    flickManager.dispose();
  }

  FlickManager initVideo() {
    return FlickManager(
      cachedVideoPlayerController: CachedVideoPlayerController.network(
          'https://cdn.smtvideosplay.com:9394/20201229/BwZ9laNp/index.m3u8'),
    );
  }
}
