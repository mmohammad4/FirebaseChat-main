import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../style/style.dart';
import 'custom_video_control.dart';

class DefaultPlayer extends StatefulWidget {
  final String url;
  const DefaultPlayer({Key? key, required this.url}) : super(key: key);

  @override
  _DefaultPlayerState createState() => _DefaultPlayerState();
}

class _DefaultPlayerState extends State<DefaultPlayer> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();

    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
        widget.url,
      ),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                height: headerSize,
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context,
                        flickManager.flickVideoManager?.videoPlayerController?.position);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height/1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 56.0),
                      child: Center(
                        child: Container(
                          width:double.maxFinite,
                          color: Colors.black,
                          child: VisibilityDetector(
                            key: ObjectKey(flickManager),
                            onVisibilityChanged: (visibility) {
                              if (visibility.visibleFraction == 0 && mounted) {
                                flickManager.flickControlManager?.autoPause();
                              } else if (visibility.visibleFraction == 1) {
                                flickManager.flickControlManager?.autoResume();
                              }
                            },
                            child: FlickVideoPlayer(
                              flickManager: flickManager,
                              preferredDeviceOrientationFullscreen: const [
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight,
                                DeviceOrientation.portraitUp,
                                DeviceOrientation.portraitDown,
                              ],
                              flickVideoWithControls: FlickVideoWithControls(
                                videoFit: BoxFit.contain,
                                iconThemeData: const IconThemeData(color: primaryColor),
                                playerLoadingFallback:  const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                ),
                                playerErrorFallback:  const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                ),
                                controls: CustomFlickPortraitControls(
                                  hideBackButton: false,
                                  progressBarSettings: FlickProgressBarSettings(
                                    handleColor: primaryColor,
                                    height: 3.0,
                                    playedColor: primaryColor,
                                  ),
                                ),
                              ),
                              flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                                videoFit: BoxFit.contain,
                                playerLoadingFallback:  Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                ),
                                controls: CustomFlickLandscapeControls(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}