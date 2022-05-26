import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sellermultivendor/Helper/ApiBaseHelper.dart';
import 'package:sellermultivendor/Helper/AppBtn.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Helper/Session.dart';
import 'package:sellermultivendor/Helper/String.dart';
import 'package:sellermultivendor/Screen/EditProduct.dart';

import '../Helper/Constant.dart';
import '../Model/ProductModel/Product.dart';

class Search extends StatefulWidget {
  final Function? updateHome;
  Search({this.updateHome});
  @override
  _StateSearch createState() => _StateSearch();
}

class _StateSearch extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0;
  bool isProgress = false;
  List<Product> productList = [];
  List<TextEditingController> _controllerList = [];
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  String _searchText = "", _lastsearch = "";
  int notificationoffset = 0;
  ScrollController? notificationcontroller;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  late AnimationController _animationController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    super.initState();
    productList.clear();

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_transactionscrollListener);

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchText = "";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchText = _controller.text;
          });
        }
      }

      if (_lastsearch != _searchText && (_searchText.length > 2)) {
        _lastsearch = _searchText;
        notificationisloadmore = true;
        notificationoffset = 0;
        getProduct();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  _transactionscrollListener() {
    if (notificationcontroller!.offset >=
            notificationcontroller!.position.maxScrollExtent &&
        !notificationcontroller!.position.outOfRange) {
      if (mounted) {
        setState(() {
          getProduct();
        });
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    notificationcontroller!.dispose();
    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++) {
      _controllerList[i].dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, "NO_INTERNET")!,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: shadow(),
              child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(end: 4.0),
                    child: Icon(Icons.keyboard_arrow_left, color: primary),
                  ),
                ),
              ),
            );
          }),
          backgroundColor: white,
          title: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
              prefixIcon: const Icon(Icons.search, color: primary, size: 17),
              hintText: getTranslated(context, "SEARCH")!,
              hintStyle: TextStyle(color: primary.withOpacity(0.5)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: white),
              ),
            ),
            // onChanged: (query) => updateSearchQuery(query),
          ),
          titleSpacing: 0,
        ),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(),
                  showCircularProgress(isProgress, primary),
                ],
              )
            : noInternet(context));
  }

  Widget listItem(int index) {
    Product model = productList[index];

    if (_controllerList.length < index + 1) {
      _controllerList.add(TextEditingController());
    }
    _controllerList[index].text =
        model.prVarientList![model.selVarient!].cartCount!;

    double price =
        double.parse(model.prVarientList![model.selVarient!].disPrice!);
    if (price == 0) {
      price = double.parse(model.prVarientList![model.selVarient!].price!);
    }
    List att = [], val = [];
    if (model.prVarientList![model.selVarient!].attr_name != null) {
      att = model.prVarientList![model.selVarient!].attr_name!.split(',');
      val = model.prVarientList![model.selVarient!].varient_value!.split(',');
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: "$index${model.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: FadeInImage(
                        image: NetworkImage(productList[index].image!),
                        height: 80.0,
                        width: 80.0,
                        // fit: extendImg ? BoxFit.fill : BoxFit.contain,
                        //errorWidget:(context, url,e) => placeHolder(80) ,
                        placeholder: placeHolder(80),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            model.name!,
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: lightBlack,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: <Widget>[
                                  Text(
                                      getPriceFormat(context,
                                          double.parse(price.toString()))!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                  Text(
                                    double.parse(model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .disPrice!) !=
                                            0
                                        ? getPriceFormat(
                                            context,
                                            double.parse(model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .price!))!
                                        : "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .overline!
                                        .copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            letterSpacing: 0),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  productDeletDialog(model.name!, model.id!);
                                },
                                child: const Card(
                                  child: Icon(
                                    Icons.delete,
                                    color: primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          model.prVarientList![model.selVarient!].attr_name !=
                                      null &&
                                  model.prVarientList![model.selVarient!]
                                      .attr_name!.isNotEmpty
                              ? ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: att.length,
                                  itemBuilder: (context, index) {
                                    return Row(children: [
                                      Flexible(
                                        child: Text(
                                          att[index].trim() + ":",
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(color: lightBlack),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 5.0),
                                        child: Text(
                                          val[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  color: lightBlack,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ]);
                                  })
                              : Container(),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: primary,
                                    size: 12,
                                  ),
                                  Text(
                                    " " + productList[index].rating!,
                                    style: Theme.of(context).textTheme.overline,
                                  ),
                                  Text(
                                    " (" + productList[index].noOfRating! + ")",
                                    style: Theme.of(context).textTheme.overline,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              productList[index].availability == "0"
                  ? Text(getTranslated(context, "OutOfStock")!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: red, fontWeight: FontWeight.bold))
                  : Container(),
            ],
          ),
          splashColor: primary.withOpacity(0.2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  updateSearch() {
    if (mounted) setState(() {});
  }

  void getAvailVarient(List<Product> tempList) {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  Future getProduct() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          if (mounted) {
            setState(() {
              notificationisloadmore = false;
              notificationisgettingdata = true;
              if (notificationoffset == 0) {
                productList = [];
              }
            });
          }
          CUR_USERID = await getPrefrence(Id);
          var parameter = {
            SellerId: CUR_USERID,
            SEARCH: _searchText.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
          };
          apiBaseHelper.postAPICall(getProductsApi, parameter).then(
            (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              notificationisgettingdata = false;
              if (notificationoffset == 0) notificationisnodata = error;
              if (!error) {
                if (mounted) {
                  Future.delayed(
                    Duration.zero,
                    () => setState(
                      () {
                        List mainlist = getdata['data'];

                        if (mainlist.isNotEmpty) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(
                            mainlist
                                .map((data) => Product.fromJson(data))
                                .toList(),
                          );
                          allitems.addAll(items);

                          for (Product item in items) {
                            productList.where((i) => i.id == item.id).map(
                              (obj) {
                                allitems.remove(item);
                                return obj;
                              },
                            ).toList();
                          }
                          getAvailVarient(allitems);
                          notificationisloadmore = true;
                          notificationoffset = notificationoffset + perPage;
                        } else {
                          notificationisloadmore = false;
                        }
                      },
                    ),
                  );
                }
              } else {
                setsnackbar(
                  msg!,
                  context,
                );
                notificationisloadmore = false;
                if (mounted) {
                  setState(
                    () {},
                  );
                }
              }
            },
            onError: (error) {
              setsnackbar(
                error.toString(),
                context,
              );
            },
          );
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          'somethingMSg',
          context,
        );
        if (mounted) {
          setState(() {
            notificationisloadmore = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  _showContent() {
    return notificationisnodata
        ? getNoItem(context)
        : NotificationListener<ScrollNotification>(
            //  onNotification:
            //       (scrollNotification) {} as bool Function(ScrollNotification)?,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsetsDirectional.only(
                        bottom: 5, start: 10, end: 10, top: 12),
                    controller: notificationcontroller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      Product? item;
                      try {
                        item = productList.isEmpty ? null : productList[index];
                        if (notificationisloadmore &&
                            index == (productList.length - 1) &&
                            notificationcontroller!.position.pixels <= 0) {
                          getProduct();
                        }
                      } on Exception catch (_) {}

                      return item == null ? Container() : listItem(index);
                    },
                  ),
                ),
                notificationisgettingdata
                    ? const Padding(
                        padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            ),
          );
  }

  productDeletDialog(String productName, String id) async {
    String pName = productName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Text(
                getTranslated(context, "sure")! +
                    " \"  $pName \" " +
                    getTranslated(context, "PRODUCT")!,
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      getTranslated(context, "LOGOUTNO")!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    delProductApi(id);

                    setState(
                      () {
                        _searchText = "";
                        getProduct();
                      },
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  delProductApi(String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        ProductId: id,
      };
      apiBaseHelper.postAPICall(getDeleteProductApi, parameter).then(
        (getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            setsnackbar(
              msg!,
              context,
            );
          } else {
            setsnackbar(
              msg!,
              context,
            );
          }
        },
        onError: (error) {},
      );
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
    return null;
  }
}
