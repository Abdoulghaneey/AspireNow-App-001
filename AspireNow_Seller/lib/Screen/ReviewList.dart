import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/ProductModel/Product.dart';
import '../Model/RattingModel/Ratting.dart';
import 'Product_Preview.dart';
import 'Review_Gallary.dart';
import 'Review_Preview.dart';

class ReviewList extends StatefulWidget {
  final String? id;
  final Product? model;

  const ReviewList(this.id, this.model, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateRate();
  }
}

int offset = 0;
int total = 0;

class StateRate extends State<ReviewList> {
  bool _isNetworkAvail = true;
  bool _isLoading = true;

  List<ProductRatting> reviewList = [];
  List<imgModel> revImgList = [];

  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isPhotoVisible = true;
  var star1 = '0',
      star2 = '0',
      star3 = '0',
      star4 = '0',
      star5 = '0',
      averageRating = '0';
  String? userComment = '', userRating = '0.0';

  @override
  void initState() {
    getReview('0');
    controller.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;
              if (offset < total) {
                getReview(
                  offset.toString(),
                );
              }
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar("Customer Reviews", context),
      body: !_isLoading
          ? userComment != "00.00"
              ? _review()
              : const Center(
                  child: Text("No Ratting Found...!"),
                )
          : shimmer(),
    );
  }

  Widget _review() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Text(
                        averageRating,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      Text("${reviewList.length}   ratings")
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        getRatingBarIndicator(5.0, 5),
                        getRatingBarIndicator(4.0, 4),
                        getRatingBarIndicator(3.0, 3),
                        getRatingBarIndicator(2.0, 2),
                        getRatingBarIndicator(1.0, 1),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getRatingIndicator(int.parse(star5)),
                        getRatingIndicator(int.parse(star4)),
                        getRatingIndicator(int.parse(star3)),
                        getRatingIndicator(int.parse(star2)),
                        getRatingIndicator(int.parse(star1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTotalStarRating(star5),
                      getTotalStarRating(star4),
                      getTotalStarRating(star3),
                      getTotalStarRating(star2),
                      getTotalStarRating(star1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          revImgList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    elevation: 0.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "Images By Customers",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        _reviewImg(),
                      ],
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${reviewList.length} Update Review",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ],
                ),
                revImgList.isNotEmpty
                    ? Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  isPhotoVisible = !isPhotoVisible;
                                },
                              );
                            },
                            child: Container(
                              height: 20.0,
                              width: 20.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: isPhotoVisible ? primary : white,
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border.all(
                                  color: primary,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: isPhotoVisible
                                    ? const Icon(
                                        Icons.check,
                                        size: 15.0,
                                        color: white,
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            "with photo",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            controller: controller,
            itemCount:
                (offset < total) ? reviewList.length + 1 : reviewList.length,
            itemBuilder: (context, index) {
              if (index == reviewList.length && isLoadingmore) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primary,
                  ),
                );
              } else {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reviewList[index].username!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RatingBarIndicator(
                                    rating:
                                        double.parse(reviewList[index].rating!),
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 12.0,
                                    direction: Axis.horizontal,
                                  ),
                                  const Spacer(),
                                  Text(
                                    reviewList[index].date!,
                                    style: const TextStyle(
                                        color: lightBlack2, fontSize: 11),
                                  )
                                ],
                              ),
                              reviewList[index].comment != '' &&
                                      reviewList[index].comment!.isNotEmpty
                                  ? Text(
                                      reviewList[index].comment ?? '',
                                      textAlign: TextAlign.left,
                                    )
                                  : Container(),
                              isPhotoVisible ? reviewImage(index) : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(
                              reviewList[index].userProfile!),
                          fit: BoxFit.fill,
                          height: 36,
                          width: 36,
                          placeholder: placeHolder(36),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.account_circle_outlined,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  _reviewImg() {
    return revImgList.isNotEmpty
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: revImgList.length > 5 ? 5 : revImgList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: InkWell(
                    onTap: () async {
                      if (index == 4) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ReviewGallary(
                              imageList: revImgList,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ReviewPreview(
                              index: index,
                              imageList: revImgList,
                              RattingModel: reviewList[index],
                            ),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(
                            revImgList[index].img!,
                          ),
                          height: 100.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                          placeholder: placeHolder(80),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(80),
                        ),
                        index == 4
                            ? Container(
                                height: 100.0,
                                width: 80.0,
                                color: black,
                                child: Center(
                                  child: Text(
                                    '+${revImgList.length - 5}',
                                    style: const TextStyle(
                                      color: white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Container();
  }

  reviewImage(int i) {
    return SizedBox(
      height: reviewList[i].Images!.isNotEmpty ? 100 : 0,
      child: ListView.builder(
        itemCount: reviewList[i].Images!.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsetsDirectional.only(end: 10, bottom: 5.0, top: 5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProductPreview(
                      pos: index,
                      secPos: 0,
                      index: 0,
                      id: "$index${reviewList[i].id}",
                      imgList: reviewList[i].Images,
                      list: true,
                      from: false,
                      screenSize: MediaQuery.of(context).size,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: /*$index*/ '$index${reviewList[i].id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: FadeInImage(
                    image: CachedNetworkImageProvider(
                        reviewList[i].Images![index]),
                    height: 100.0,
                    width: 100.0,
                    placeholder: placeHolder(50),
                    imageErrorBuilder: (context, error, stackTrace) =>
                        erroWidget(50),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getReview(var value) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          "product_id": widget.id,
          LIMIT: perPage.toString(),
          OFFSET: value,
        };
        Response response = await post(
          getProductRatingApi,
          body: parameter,
          headers: headers,
        ).timeout(
          const Duration(
            seconds: timeOut,
          ),
        );
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          star1 = getdata['star_1'];
          star2 = getdata['star_2'];
          star3 = getdata['star_3'];
          star4 = getdata['star_4'];
          star5 = getdata['star_5'];
          averageRating = getdata['product_rating'];

          total = int.parse(getdata['total']);
          offset = int.parse(value);
          if (offset < total) {
            var data = getdata['data'];
            reviewList = (data as List)
                .map(
                  (data) => ProductRatting.fromJson(data),
                )
                .toList();
            offset = offset + perPage;
          }
          setState(
            () {
              isLoadingmore = false;
            },
          );
        } else {
          if (msg != 'No ratings found !') {
            setsnackbar(
              msg!,
              context,
            );
          }
          isLoadingmore = false;
          userComment = "00.00";
        }
        if (mounted) {
          setState(
            () {
              _isLoading = false;
            },
          );
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, 'somethingMSg')!,
          context,
        );
        if (mounted) {
          setState(
            () {
              _isLoading = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
          },
        );
      }
    }
  }

  getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        textDirection: TextDirection.rtl,
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_rate_rounded,
          color: Colors.amber,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  getRatingIndicator(var totalStar) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          Container(
            height: 10,
            width: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  width: 0.5,
                  color: primary,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: primary,
            ),
            width: (totalStar / reviewList.length) *
                MediaQuery.of(context).size.width /
                3,
            height: 10,
          ),
        ],
      ),
    );
  }

  getTotalStarRating(var totalStar) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Text(
        totalStar,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
