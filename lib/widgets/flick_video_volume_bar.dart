import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Renders progress bar for the video using custom paint.
class FlickVideoVolumeBar extends StatelessWidget {
  FlickVideoVolumeBar({
    this.volume,
  });
  final double volume;

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    if (volume <= 0) {
      iconData = Icons.volume_mute;
    } else if (volume < 0.5) {
      iconData = Icons.volume_down;
    } else {
      iconData = Icons.volume_up;
    }
    final primaryColor = Theme.of(context).primaryColor;
    return LayoutBuilder(builder: (context, size) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
            child: Align(
          alignment: Alignment(0, -0.4),
          child: Card(
            color: Color(0x33000000),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    iconData,
                    color: Colors.white,
                  ),
                  Container(
                    width: 75,
                    height: 3,
                    margin: EdgeInsets.only(left: 8),
                    child: LinearProgressIndicator(
                      value: volume,
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation(primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      );
    });
  }
}
