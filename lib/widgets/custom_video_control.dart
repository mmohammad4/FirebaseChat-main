import 'package:create_social/style/style.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Default portrait VideoControls.
class CustomFlickPortraitControls extends StatelessWidget {
  const CustomFlickPortraitControls(
      {Key? key,
      this.iconSize = 25,
      this.fontSize = 12,
        this.hideBackButton= true,
      this.progressBarSettings})
      : super(key: key);

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  /// [FlickProgressBarSettings] settings.
  final FlickProgressBarSettings? progressBarSettings;
  final bool hideBackButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        FlickVideoBuffer(
          bufferingChild: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 5,
            ),
          ),
          child:  Stack(
            children: [
              Positioned.fill(
                child: FlickShowControlsAction(
                  child: Center(
                    child: CustomFlickAutoHideChild(
                      showIfVideoNotInitialized: false,
                      child: FlickPlayToggle(
                        size: 40,
                        color: primaryColor,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomFlickAutoHideChild(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            FlickCurrentPosition(
                              fontSize: fontSize,
                            ),
                            CustomFlickAutoHideChild(
                              child: Text(
                                ' / ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: fontSize),
                              ),
                            ),
                            FlickTotalDuration(
                              fontSize: fontSize,
                            ),
                          ],
                        ),
                        FlickVideoProgressBar(
                          flickProgressBarSettings: progressBarSettings,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlickPlayToggle(
                                size: iconSize + 5,
                                color: primaryColor,
                                padding: const EdgeInsets.all(10.0),
                                playChild: Icon(
                                  Icons.play_arrow_rounded,
                                  size: iconSize,
                                  color: primaryColor,
                                ),
                                pauseChild: Icon(
                                  Icons.pause,
                                  size: iconSize,
                                  color: primaryColor,
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if(hideBackButton)
        Positioned(
          height: headerSize,
          top: 30,
          left: 15,
          child: FlickFullScreenToggle(
            size: iconSize,
            padding: const EdgeInsets.all(10.0),
            enterFullScreenChild: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 25,
            ),
            exitFullScreenChild: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}

/// Default landscape VideoControls.
class CustomFlickLandscapeControls extends StatelessWidget {
  const CustomFlickLandscapeControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomFlickPortraitControls(
      fontSize: 14,
      iconSize: 28,
      progressBarSettings: FlickProgressBarSettings(
        height: 5,
        playedColor: primaryColor,
        handleColor: primaryColor,
      ),
    );
  }
}

/// Default Mute/Unmute VideoControls.
class CustomFlickSoundToggle extends StatelessWidget {
  const CustomFlickSoundToggle({
    Key? key,
    this.muteChild,
    this.unmuteChild,
    this.toggleMute,
    this.size,
    this.color,
    this.padding,
    this.decoration,
  }) : super(key: key);

  /// Widget shown when the video is not muted.
  ///
  /// Default - Icon(Icons.volume_off)
  final Widget? muteChild;

  /// Widget shown when the video is muted.
  ///
  /// Default - Icon(Icons.volume_up)
  final Widget? unmuteChild;

  /// Function called onTap of visible child.
  ///
  /// Default action -
  /// ``` dart
  ///    controlManager.toggleMute();
  /// ```
  final Function? toggleMute;

  /// Size for the default icons.
  final double? size;

  /// Color for the default icons.
  final Color? color;

  /// Padding around the visible child.
  final EdgeInsetsGeometry? padding;

  /// Decoration around the visible child.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);

    Widget muteWidget = muteChild ??
        Icon(
          Icons.volume_off,
          size: size,
          color: color,
        );
    Widget unmuteWidget = unmuteChild ??
        Icon(
          Icons.volume_up,
          size: size,
          color: color,
        );

    Widget child = controlManager.isMute ? muteWidget : unmuteWidget;

    return GestureDetector(
        key: key,
        onTap: () {
          if (toggleMute != null) {
            toggleMute!();
          } else {
            controlManager.toggleMute();

          }
        },
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ));
  }
}

/// Default Looping VideoControls.
class CustomFlickLoopToggle extends StatelessWidget {
  const CustomFlickLoopToggle({
    Key? key,
    this.loopChild,
    this.unloopChild,
    this.toggleLoop,
    this.size,
    this.color,
    this.padding,
    this.decoration,
  }) : super(key: key);

  /// Widget shown when the video is not muted.
  ///
  /// Default - Icon(Icons.volume_off)
  final Widget? loopChild;

  /// Widget shown when the video is muted.
  ///
  /// Default - Icon(Icons.volume_up)
  final Widget? unloopChild;

  /// Function called onTap of visible child.
  ///
  /// Default action -
  /// ``` dart
  ///    controlManager.toggleMute();
  /// ```
  final Function(bool isLooping)? toggleLoop;

  /// Size for the default icons.
  final double? size;

  /// Color for the default icons.
  final Color? color;

  /// Padding around the visible child.
  final EdgeInsetsGeometry? padding;

  /// Decoration around the visible child.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    Widget loopWidget = loopChild ??
        Icon(
          Icons.loop,
          size: size,
          color: primaryColor,
        );
    Widget unloopWidget = unloopChild ??
        Icon(
          Icons.loop,
          size: size,
          color: Colors.white,
        );

    Widget child =
        videoManager.videoPlayerValue!.isLooping ? loopWidget : unloopWidget;

    return GestureDetector(
        key: key,
        onTap: () {
          if (toggleLoop != null) {
            toggleLoop!(!videoManager.videoPlayerValue!.isLooping);
          }
          videoManager.videoPlayerController!
              .setLooping(!videoManager.videoPlayerValue!.isLooping);
        },
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ));
  }
}

class CustomFlickAutoHideChild extends StatelessWidget {
  const CustomFlickAutoHideChild({
    Key? key,
    required this.child,
    this.autoHide = true,
    this.showIfVideoNotInitialized = true,
  }) : super(key: key);
  final Widget child;
  final bool autoHide;

  /// Show the child if video is not initialized.
  final bool showIfVideoNotInitialized;

  @override
  Widget build(BuildContext context) {
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    return (!videoManager.isVideoInitialized && !showIfVideoNotInitialized)
        ? Container()
        : autoHide
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child:
                    (displayManager.showPlayerControls) ? child : Container(),
              )
            : child;
  }
}

class CustomFlickFullScreenToggle extends StatelessWidget {
  const CustomFlickFullScreenToggle(
      {Key? key,
        this.enterFullScreenChild,
        this.exitFullScreenChild,
        this.toggleFullscreen,
        this.size,
        this.color,
        this.padding,
        this.decoration})
      : super(key: key);

  /// Widget shown when player is not in full-screen.
  ///
  /// Default - [Icon(Icons.fullscreen)]
  final Widget? enterFullScreenChild;

  /// Widget shown when player is in full-screen.
  ///
  ///  Default - [Icon(Icons.fullscreen_exit)]
  final Widget? exitFullScreenChild;

  /// Function called onTap of the visible child.
  ///
  /// Default action -
  /// ```dart
  ///     controlManager.toggleFullscreen();
  /// ```
  final Function? toggleFullscreen;

  /// Size for the default icons.
  final double? size;

  /// Color for the default icons.
  final Color? color;

  /// Padding around the visible child.
  final EdgeInsetsGeometry? padding;

  /// Decoration around the visible child.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
    Provider.of<FlickControlManager>(context);
    Widget enterFullScreenWidget = enterFullScreenChild ??
        Icon(
          Icons.fullscreen,
          size: size,
          color: color,
        );
    Widget exitFullScreenWidget = exitFullScreenChild ??
        Icon(
          Icons.fullscreen_exit,
          size: size,
          color: color,
        );

    Widget child = controlManager.isFullscreen
        ? exitFullScreenWidget
        : enterFullScreenWidget;

    return GestureDetector(
      key: key,
      onTap: () {
        controlManager.toggleFullscreen();
        if (toggleFullscreen != null) {
          toggleFullscreen!();
        }
      },
      child: Container(
        padding: padding,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

class FlickVideoBuffer extends StatelessWidget {
  const FlickVideoBuffer({
    Key? key,
    this.bufferingChild = const CircularProgressIndicator(

    ),
    this.child,
  }) : super(key: key);
  /// Widget to be shown when the video is buffering.
  final Widget bufferingChild;
  /// Widget to be shown when the video is not buffering.
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    return Container(
      // child: videoManager.isBuffering ?  bufferingChild: child,
      child: (videoManager.isBuffering && videoManager.isPlaying)
          ? bufferingChild
          : child,
    );
  }
}