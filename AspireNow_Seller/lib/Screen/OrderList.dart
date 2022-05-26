import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sellermultivendor/Helper/ApiBaseHelper.dart';
import 'package:sellermultivendor/Helper/AppBtn.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Helper/Constant.dart';
import 'package:sellermultivendor/Helper/Session.dart';
import 'package:sellermultivendor/Helper/String.dart';
import 'package:sellermultivendor/Screen/Home.dart';
import 'package:sellermultivendor/Screen/OrderDetail.dart';
import '../Model/OrdersModel/OrderModel.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  String _searchText = "", _lastsearch = "";
  bool? isSearching;
  int scrollOffset = 0;
  ScrollController? scrollController;
  bool scrollLoadmore = true, scrollGettingData = false, scrollNodata = false;
  final TextEditingController _controller = TextEditingController();
  List<Order_Model> orderList = [];
  Icon iconSearch = const Icon(
    Icons.search,
    color: primary,
    size: 25,
  );
  Widget? appBarTitle;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<Order_Model> tempList = [];
  String? activeStatus;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String? start, end;

  String? all,
      received,
      orderTrackingTotal,
      processed,
      shipped,
      delivered,
      cancelled,
      returned,
      awaiting;
  List<String> statusList = [
    ALL,
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
  ];

  @override
  void initState() {
    scrollOffset = 0;
    Future.delayed(Duration.zero, getOrder);
    // getOrder();
    appBarTitle = const Text(
      //  getTranslated(context, "ORDER")!,
      "Orders",
      style: TextStyle(color: grad2Color),
    );
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    scrollController = ScrollController(keepScrollOffset: true);
    scrollController!.addListener(_transactionscrollListener);

    buttonSqueezeanimation = Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );

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

      if (_lastsearch != _searchText &&
          (_searchText == '' || (_searchText.length > 2))) {
        _lastsearch = _searchText;
        scrollLoadmore = true;
        scrollOffset = 0;
        getOrder();
      }
    });

    super.initState();
  }

  _transactionscrollListener() {
    if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            scrollLoadmore = true;
            getOrder();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: lightWhite,
        appBar: getAppbar(),
        body: _isNetworkAvail ? _showContent() : noInternet(context));
  }

  void _handleSearchStart() {
    if (!mounted) return;
    setState(
      () {
        isSearching = true;
      },
    );
  }

  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(2020, 1),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(
        () {
          startDate = picked;
          start = DateFormat('dd-MM-yyyy').format(startDate);

          if (start != null && end != null) {
            scrollLoadmore = true;
            scrollOffset = 0;
            getOrder();
          }
        },
      );
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime.now());
    if (picked != null) {
      setState(
        () {
          endDate = picked;
          end = DateFormat('dd-MM-yyyy').format(endDate);
          if (start != null && end != null) {
            scrollLoadmore = true;
            scrollOffset = 0;
            getOrder();
          }
        },
      );
    }
  }

  void _handleSearchEnd() {
    if (!mounted) return;
    setState(
      () {
        iconSearch = const Icon(
          Icons.search,
          color: primary,
          size: 25,
        );
        appBarTitle = Text(
          getTranslated(context, "ORDER")!,
          style: const TextStyle(color: grad2Color),
        );
        isSearching = false;
        _controller.clear();
      },
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, "NO_INTERNET")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  super.widget)).then(
                        (value) {
                          setState(
                            () {},
                          );
                        },
                      );
                    } else {
                      await buttonController!.reverse();
                      if (mounted) {
                        setState(
                          () {},
                        );
                      }
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  AppBar getAppbar() {
    return AppBar(
      title: appBarTitle,
      elevation: 5,
      titleSpacing: 0,
      iconTheme: const IconThemeData(color: primary),
      backgroundColor: white,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
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
          );
        },
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              if (!mounted) return;
              setState(
                () {
                  if (iconSearch.icon == Icons.search) {
                    iconSearch = const Icon(
                      Icons.close,
                      color: primary,
                      size: 25,
                    );
                    appBarTitle = TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(
                        color: primary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: primary),
                        hintText: getTranslated(context, "Search"),
                        hintStyle: const TextStyle(color: primary),
                      ),
                      //  onChanged: searchOperation,
                    );
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: iconSearch,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: filterDialog,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.filter_alt_outlined,
                color: primary,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  commanDesingField(
    String title,
    IconData icon,
    int index,
    String? onTapAction,
  ) {
    return Expanded(
      flex: 1,
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: () {
            setState(
              () {
                activeStatus = onTapAction;
                scrollLoadmore = true;
                scrollOffset = 0;
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: primary,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  () {
                    if (index == 0) {
                      if (all != null) {
                        return all!;
                      } else {
                        return "";
                      }
                    } else if (index == 1) {
                      if (received != null) {
                        return received!;
                      } else {
                        return "";
                      }
                    } else if (index == 2) {
                      if (processed != null) {
                        return processed!;
                      } else {
                        return "";
                      }
                    } else if (index == 3) {
                      if (shipped != null) {
                        return shipped!;
                      } else {
                        return "";
                      }
                    } else if (index == 4) {
                      if (delivered != null) {
                        return delivered!;
                      } else {
                        return "";
                      }
                    } else if (index == 5) {
                      if (cancelled != null) {
                        return cancelled!;
                      } else {
                        return "";
                      }
                    } else if (index == 6) {
                      if (returned != null) {
                        return returned!;
                      } else {
                        return "";
                      }
                    } else {
                      return "";
                    }
                  }(),
                  style: const TextStyle(
                    color: black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showContent() {
    return scrollNodata
        ? getNoItem(context)
        : NotificationListener<ScrollNotification>(
            // onNotification:
            //     (scrollNotification) {} as bool Function(ScrollNotification)?,
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: <Widget>[
                      _detailHeader(),
                      _detailHeader2(),
                      _filterRow(),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsetsDirectional.only(
                            bottom: 5, start: 10, end: 10),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderList.length,
                        itemBuilder: (context, index) {
                          Order_Model? item;
                          try {
                            item = orderList.isEmpty ? null : orderList[index];
                            if (scrollLoadmore &&
                                index == (orderList.length - 1) &&
                                scrollController!.position.pixels <= 0) {
                              getOrder();
                            }
                          } on Exception catch (_) {}

                          return item == null ? Container() : orderItem(index);
                        },
                      ),
                    ],
                  ),
                ),
                scrollGettingData
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            ),
          );
  }

  _detailHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          commanDesingField(
            getTranslated(context, "ORDER")!,
            Icons.shopping_cart,
            0,
            null,
          ),
          commanDesingField(
            getTranslated(context, "RECEIVED_LBL")!,
            Icons.archive,
            1,
            statusList[1],
          ),
          commanDesingField(
            getTranslated(context, "PROCESSED_LBL")!,
            Icons.work,
            2,
            statusList[2],
          ),
        ],
      ),
    );
  }

  _detailHeader2() {
    return Row(
      children: [
        commanDesingField(
          getTranslated(context, "SHIPED_LBL")!,
          Icons.airport_shuttle,
          3,
          statusList[3],
        ),
        commanDesingField(
          getTranslated(context, "DELIVERED_LBL")!,
          Icons.assignment_turned_in,
          4,
          statusList[4],
        ),

        // index = 5
        commanDesingField(
          getTranslated(context, "CANCELLED_LBL")!,
          Icons.cancel,
          5,
          statusList[5],
        ),

        commanDesingField(
          getTranslated(context, "RETURNED_LBL")!,
          Icons.upload,
          6,
          statusList[6],
        )
      ],
    );
  }

  orderItem(int index) {
    Order_Model model = orderList[index];
    Color back;

    if ((model.itemList![0].activeStatus!) == DELIVERD) {
      back = Colors.green;
    } else if ((model.itemList![0].activeStatus!) == SHIPED) {
      back = Colors.orange;
    } else if ((model.itemList![0].activeStatus!) == CANCLED ||
        model.itemList![0].activeStatus! == RETURNED) {
      back = red;
    } else if ((model.itemList![0].activeStatus!) == PROCESSED) {
      back = Colors.indigo;
    } else if ((model.itemList![0].activeStatus!) == PROCESSED) {
      back = Colors.indigo;
    } else if (model.itemList![0].activeStatus! == "awaiting") {
      back = Colors.black;
    } else {
      back = Colors.cyan;
    }
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          getTranslated(context, "Order_No")! + ".",
                          style: const TextStyle(color: grey),
                        ),
                        Text(
                          model.id!,
                          style: const TextStyle(color: black),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: back,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(
                            4.0,
                          ),
                        ),
                      ),
                      child: Text(
                        () {
                          if (capitalize(model.itemList![0].activeStatus!) ==
                              "Received") {
                            return getTranslated(context, "RECEIVED_LBL")!;
                          } else if (capitalize(
                                  model.itemList![0].activeStatus!) ==
                              "Processed") {
                            return getTranslated(context, "PROCESSED_LBL")!;
                          } else if (capitalize(
                                  model.itemList![0].activeStatus!) ==
                              "Shipped") {
                            return getTranslated(context, "SHIPED_LBL")!;
                          } else if (capitalize(
                                  model.itemList![0].activeStatus!) ==
                              "Delivered") {
                            return getTranslated(context, "DELIVERED_LBL")!;
                          } else if (capitalize(
                                  model.itemList![0].activeStatus!) ==
                              "Awaiting") {
                            return getTranslated(context, "AWAITING_LBL")!;
                          } else if (capitalize(
                                  model.itemList![0].activeStatus!) ==
                              "Cancelled") {
                            return getTranslated(context, "CANCELLED_LBL")!;
                          } else if (capitalize(
                                  model.itemList![0].activeStatus!) ==
                              "Returned") {
                            return getTranslated(context, "RETURNED_LBL")!;
                          } else {
                            return capitalize(model.itemList![0].activeStatus!);
                          }
                        }(),
                        style: const TextStyle(color: white),
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: secondary,
                          ),
                          Expanded(
                            child: Text(
                              model.name != null && model.name!.isNotEmpty
                                  ? " " + capitalize(model.name!)
                                  : " ",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    customerViewPermission
                        ? InkWell(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.call,
                                  size: 14,
                                  color: secondary,
                                ),
                                Text(
                                  " " + model.mobile!,
                                  style: const TextStyle(
                                      color: black,
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                            onTap: () {
                              //  _launchCaller(index);
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.money,
                          size: 14,
                          color: secondary,
                        ),
                        Row(
                          children: [
                            Text(
                              " " +
                                  getTranslated(context, "PayableTXT")! +
                                  ": ",
                              style: const TextStyle(color: grey),
                            ),
                            Text(
                              " " +
                                  getPriceFormat(
                                      context, double.parse(model.payable!))!,
                              style: const TextStyle(color: black),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.payment,
                          size: 14,
                          color: secondary,
                        ),
                        Text(
                          " " + model.payMethod!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 14,
                      color: secondary,
                    ),
                    Row(
                      children: [
                        Text(
                          " " + getTranslated(context, "ORDER_DATE")! + ": ",
                          style: const TextStyle(color: grey),
                        ),
                        Text(
                          model.orderDate!,
                          style: const TextStyle(color: black),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetail(
                //   model: orderList[index],
                id: model.id,
              ),
            ),
          );
          setState(
            () {
              getOrder();
            },
          );
        },
      ),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> getOrder() async {
    if (readOrder) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (scrollLoadmore) {
          if (mounted) {
            setState(() {
              scrollLoadmore = false;
              scrollGettingData = true;
              if (scrollOffset == 0) {
                orderList = [];
              }
            });
          }
          CUR_USERID = await getPrefrence(Id);
          CUR_USERNAME = await getPrefrence(Username);

          var parameter = {
            SellerId: CUR_USERID,
            LIMIT: perPage.toString(),
            OFFSET: scrollOffset.toString(),
            SEARCH: _searchText.trim(),
          };
          if (start != null) {
            parameter[START_DATE] = "${startDate.toLocal()}".split(' ')[0];
          }
          if (end != null) {
            parameter[END_DATE] = "${endDate.toLocal()}".split(' ')[0];
          }
          if (activeStatus != null) {
            if (activeStatus == awaitingPayment) activeStatus = "awaiting";
            parameter[ActiveStatus] = activeStatus!;
          }

          apiBaseHelper.postAPICall(getOrdersApi, parameter).then(
            (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              scrollGettingData = false;
              if (scrollOffset == 0) scrollNodata = error;

              if (!error) {
                all = getdata["total"];
                received = getdata["received"];
                processed = getdata["processed"];
                shipped = getdata["shipped"];
                delivered = getdata["delivered"];
                cancelled = getdata["cancelled"];
                returned = getdata["returned"];
                awaiting = getdata["awaiting"];
                tempList.clear();
                var data = getdata["data"];
                if (data.length != 0) {
                  tempList = (data as List)
                      .map((data) => Order_Model.fromJson(data))
                      .toList();

                  orderList.addAll(tempList);
                  scrollLoadmore = true;
                  scrollOffset = scrollOffset + perPage;
                } else {
                  scrollLoadmore = false;
                }
              } else {
                setsnackbar(
                  msg!,
                  context,
                );
                scrollLoadmore = false;
              }
              if (mounted) {
                setState(() {
                  scrollLoadmore = false;
                });
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
      } else {
        if (mounted) {
          setState(
            () {
              _isNetworkAvail = false;
              scrollLoadmore = false;
            },
          );
        }
      }
      return;
    } else {
      setsnackbar(
        getTranslated(
            context, "You have not authorized permission for read order!!")!,
        context,
      );
    }
  }

  void filterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ButtonBarTheme(
          data: const ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
          child: AlertDialog(
            elevation: 2.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            contentPadding: const EdgeInsets.all(0.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 19.0, bottom: 16.0),
                    child: Text(
                      getTranslated(context, "FILTER_BY")!,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: fontColor),
                    ),
                  ),
                  const Divider(color: lightBlack),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: getStatusList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> getStatusList() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            Column(
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: TextButton(
                      child: Text(
                          capitalize(
                            statusList[index],
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        setState(() {
                          activeStatus = index == 0 ? null : statusList[index];
                          scrollLoadmore = true;
                          scrollOffset = 0;
                        });

                        getOrder();

                        Navigator.pop(context, 'option $index');
                      }),
                ),
                const Divider(
                  color: lightBlack,
                  height: 1,
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  _filterRow() {
    return Row(
      children: [
        Container(
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * .375,
            height: 45,
            child: ElevatedButton(
              onPressed: () => _startDate(context),
              child: Text(
                start == null ? getTranslated(context, "Start Date")! : start!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: primary),
                primary: primary,
                onPrimary: Colors.white,
                onSurface: fontColor,
              ),
            )),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width * .375,
          height: 45,
          child: ElevatedButton(
            onPressed: () => _endDate(context),
            child:
                Text(end == null ? getTranslated(context, "End Date")! : end!),
            style: ElevatedButton.styleFrom(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    start = null;
                    end = null;
                    startDate = DateTime.now();
                    endDate = DateTime.now();
                    scrollLoadmore = true;
                    scrollOffset = 0;
                  },
                );
                getOrder();
              },
              child: const Center(
                child: Icon(Icons.close),
              ),
              style: ElevatedButton.styleFrom(
                primary: primary,
                onPrimary: Colors.white,
                onSurface: Colors.grey,
                padding: const EdgeInsets.all(0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
