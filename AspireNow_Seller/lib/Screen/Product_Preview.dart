import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import '../Helper/Color.dart';
import '../Helper/Session.dart';

class ProductPreview extends StatefulWidget {
  final int? pos, secPos, index;
  final bool? list, from;
  final Size? screenSize;
  final String? id, video, videoType;
  final List<String?>? imgList;

  const ProductPreview(
      {Key? key,
      this.pos,
      this.secPos,
      this.index,
      this.list,
      this.id,
      this.imgList,
      this.screenSize,
      this.video,
      this.videoType,
      this.from})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StatePreview();
}

class StatePreview extends State<ProductPreview> {
  late PageController pageController = PageController(
    initialPage: widget.pos!,
  );

  late List<ScrollController> scrollControllers = [];

  late int curPos = widget.pos!;

  void initScrollControllers() {
    double initialPosition = widget.screenSize!.width * (0.4);

    widget.imgList!.forEach(
      (element) {
        scrollControllers.add(
          ScrollController(
            initialScrollOffset: initialPosition,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initScrollControllers();
    curPos = widget.pos!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onHorizontalDragUpdate(DragUpdateDetails dragUpdateDetails) {
    if (dragUpdateDetails.primaryDelta! != 0.0) {
      double value =
          scrollControllers[curPos].offset - dragUpdateDetails.primaryDelta!;
      if (value >= scrollControllers[curPos].position.maxScrollExtent) {
        double pageControllerValue =
            pageController.offset - dragUpdateDetails.primaryDelta!;

        if (curPos != (widget.imgList!.length - 1)) {
          pageController.jumpTo(pageControllerValue);
        }
      } else {
        if (value < 0.0) {
          double pageControllerValue =
              pageController.offset - dragUpdateDetails.primaryDelta!;
          if (curPos != 0) {
            pageController.jumpTo(pageControllerValue);
          }
        } else {
          scrollControllers[curPos].jumpTo(value);
        }
      }
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails dragUpdateDetails) {}

  @override
  void deactivate() {
    super.deactivate();
  }

  double scaleData = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          widget.video == ''
              ? Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onVerticalDragUpdate: onVerticalDragUpdate,
                        onHorizontalDragUpdate: onHorizontalDragUpdate,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * (1.0),
                          child: PageView.builder(
                            onPageChanged: (index) {
                              setState(
                                () {
                                  curPos = index;
                                },
                              );
                            },
                            controller: pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.imgList!.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                controller: scrollControllers[index],
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Transform.scale(
                                  scale: scaleData,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        (1.8),
                                    child: Hero(
                                      tag: widget.list!
                                          ? '${widget.id}'
                                          : "${widget.secPos}${widget.index}",
                                      child: Image.network(
                                        widget.imgList![index]!,
                                        fit: BoxFit.fitHeight,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    curPos != (widget.imgList!.length - 1)
                        ? Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: IconButton(
                              onPressed: () {
                                pageController.nextPage(
                                  duration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  curve: Curves.ease,
                                );
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    curPos != 0
                        ? Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              onPressed: () {
                                pageController.previousPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                              ),
                            ))
                        : const SizedBox(),
                  ],
                )
              : PageView.builder(
                  itemCount: widget.imgList!.length,
                  controller: PageController(initialPage: curPos),
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(
                        () {
                          curPos = index;
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 1 &&
                        widget.from! &&
                        widget.videoType != null &&
                        widget.video != '') {}

                    // return Container();
                    return PhotoView(
                      backgroundDecoration: const BoxDecoration(color: white),
                      initialScale: PhotoViewComputedScale.contained * 0.9,
                      minScale: PhotoViewComputedScale.contained * 0.9,
                      maxScale: PhotoViewComputedScale.contained * 1.8,
                      gaplessPlayback: false,
                      customSize: MediaQuery.of(context).size,
                      imageProvider: NetworkImage(
                        widget.imgList![index]!,
                      ),
                    );
                  },
                ),
          Positioned(
            top: 34.0,
            left: 5.0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: shadow(),
                child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Center(
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        color: primary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 25.0,
            right: 25.0,
            child: SelectedPhoto(
              numberOfDots: widget.imgList!.length,
              photoIndex: curPos,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller!.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: const Color(0x8A000000),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller!.value.isPlaying
                ? controller!.pause()
                : controller!.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller!.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller!.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text(
                      '${speed}x',
                    ),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text(
                '${controller!.value.playbackSpeed}x',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SelectedPhoto extends StatelessWidget {
  final int? numberOfDots;
  final int? photoIndex;

  const SelectedPhoto({Key? key, this.numberOfDots, this.photoIndex})
      : super(key: key);

  Widget _inactivePhoto() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 3.0,
        end: 3.0,
      ),
      child: Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }

  Widget _activePhoto() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 5.0,
        end: 5.0,
      ),
      child: Container(
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 0.0,
              blurRadius: 2.0,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];
    for (int i = 0; i < numberOfDots!; i++) {
      dots.add(
        i == photoIndex ? _activePhoto() : _inactivePhoto(),
      );
    }
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}
