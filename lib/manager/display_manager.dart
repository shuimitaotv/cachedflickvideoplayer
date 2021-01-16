part of flick_manager;

/// Manages display related properties like auto-hide controls.
class FlickDisplayManager extends ChangeNotifier {
  /// Manages display related properties like auto-hide controls.
  FlickDisplayManager({
    FlickManager flickManager,
  }) : _flickManager = flickManager {
    handleShowPlayerControls();
  }

  final FlickManager _flickManager;
  bool _mounted = true;
  Timer _showPlayerControlsTimer;
  Timer _showVolumeTimer;
  Timer _showBrightnessTimer;
  bool _showPlayerControls = true;
  bool _showForwardSeek = false;
  bool _showBackwardSeek = false;
  bool _showSeekTime = false;
  bool _showVolume = false;
  bool _showBrightness = false;
  double _brightness = 0.0;

  /// Show player controls or not.
  bool get showPlayerControls => _showPlayerControls;

  // Show forward seek icon or not.
  bool get showForwardSeek => _showForwardSeek;

  // Show backward seek icon or not.
  bool get showBackwardSeek => _showBackwardSeek;

  // Show backward seek icon or not.
  bool get showSeekTime => _showSeekTime;

  // Show showVolume icon or not.
  bool get showVolume => _showVolume;

  // Show showBrightness icon or not.
  bool get showBrightness => _showBrightness;

  double get brightness => _brightness;

  setFirstBrightness() {
    Screen.brightness.then((b) => {_brightness = b});
  }

  setBrightness(double brightness) {
    if (brightness != _brightness) {
      Screen.setBrightness(brightness);
    }
  }

  /// User video tap action.
  handleVideoTap() {
    // If playerControls are showing,
    // cancel the hide timer and hide the controls.
    if (_showPlayerControls) {
      _showPlayerControls = false;
      _showPlayerControlsTimer?.cancel();
      _notify();
    } else {
      // If playerControls are not showing,
      // show player controls.
      handleShowPlayerControls();
    }
  }

  handleShowVolume({bool show = true}) {
    _showVolume = show;
    // Cancel any previously running timer.
    _showVolumeTimer?.cancel();
    _notify();
    if (show) {
      // Timer duration fetched through channel, passing the current player information.
      _showVolumeTimer = Timer(Duration(milliseconds: 1000), () {
        _showVolume = false;
        _notify();
      });
    }
  }

  handleShowBrightness({bool show = true}) {
    _showBrightness = show;
    // Cancel any previously running timer.
    _showBrightnessTimer?.cancel();
    _notify();
    if (show) {
      // Timer duration fetched through channel, passing the current player information.
      _showBrightnessTimer = Timer(Duration(milliseconds: 1000), () {
        _showBrightness = false;
        _notify();
      });
    }
  }

  handleTogglePlayerControls({bool show}) {
    // If playerControls are showing,
    // cancel the hide timer and hide the controls.
    if (!show) {
      _showPlayerControls = false;
      _showPlayerControlsTimer?.cancel();
      _notify();
    } else {
      // If playerControls are not showing,
      // show player controls.
      handleShowPlayerControls();
    }
  }

  // Called when user calls seekForward or seekBackward
  // on the controlManager.
  handleSeekTime({bool show}) {
    _showSeekTime = show;
    _notify();
  }

  /// Show the player controls.
  ///
  /// if [showWithTimeout] is false [showPlayerControls] will be set to true without a timeout to change it to false.
  ///
  /// if [showWithTimeout] is true [showPlayerControls] will be set to true with a timeout to auto-hide the controls.
  handleShowPlayerControls({bool showWithTimeout = true}) {
    _showPlayerControls = true;
    _notify();

    // Cancel any previously running timer.
    _showPlayerControlsTimer?.cancel();
    if (showWithTimeout) {
      // Timer duration fetched through channel, passing the current player information.

      _showPlayerControlsTimer = Timer(
          _flickManager.getPlayerControlsTimeout(
            errorInVideo: _flickManager.flickVideoManager.errorInVideo,
            isVideoInitialized:
                _flickManager.flickVideoManager.isVideoInitialized,
            isPlaying: _flickManager.flickVideoManager.isPlaying,
            isVideoEnded: _flickManager.flickVideoManager.isVideoEnded,
          ), () {
        _showPlayerControls = false;
        _notify();
      });
    }
  }

  // Called when user calls seekForward or seekBackward
  // on the controlManager.
  _handleVideoSeek({bool forward}) {
    if (forward) {
      _showForwardSeek = true;
    } else {
      _showBackwardSeek = true;
    }
    _notify();

    Timer(Duration(milliseconds: 400), () {
      _showForwardSeek = false;
      _showBackwardSeek = false;
      _notify();
    });
  }

  // If there is any error in video, show controls
  // for how long to show the controls will be determined by the
  // channel.
  _handleErrorInVideo() {
    handleShowPlayerControls();
  }

  // If video ended, show controls
  // for how long to show the controls will be determined by the
  // channel.
  _handleVideoEnd() {
    handleShowPlayerControls();
  }

  // If orientation changed, show controls
  // for how long to show the controls will be determined by the
  // channel.
  _handleToggleFullscreen() {
    handleShowPlayerControls();
  }

  _notify() {
    if (_mounted) {
      notifyListeners();
    }
  }

  dispose() {
    _mounted = false;
    super.dispose();
  }
}
