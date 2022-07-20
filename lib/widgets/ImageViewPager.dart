import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import '../style/style.dart';

class ImageViewPager extends StatefulWidget {
  final List<dynamic> imageList;
  const ImageViewPager({Key? key, required this.imageList}) : super(key: key);

  @override
  ImageViewPagerState createState() => ImageViewPagerState();
}

class ImageViewPagerState extends State<ImageViewPager> {
  int _current = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              Container(
                height: headerSize,
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: widget.imageList.length,
                  itemBuilder:(BuildContext context, int itemIndex,int a){
                    return Row(
                      children: [
                        CachedNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          imageUrl: widget.imageList[itemIndex].toString(),
                          fit: BoxFit.contain,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Image.asset(
                            'images/no_images.png',
                            fit: BoxFit.contain,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'images/no_images.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                      height: MediaQuery.of(context).size.height,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      scrollPhysics: const BouncingScrollPhysics(),
                      viewportFraction:1,
                      aspectRatio: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }
                  ),
                ),
              ),
              if(widget.imageList.length >1)
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: DotsIndicator(
                  dotsCount: widget.imageList.length,
                  position: _current.toDouble(),
                  decorator: const DotsDecorator(
                      color: Colors.black12, // Inactive color
                      activeColor: primaryColor,
                      spacing: EdgeInsets.all(4),
                      size: Size.square(6.0)
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}
