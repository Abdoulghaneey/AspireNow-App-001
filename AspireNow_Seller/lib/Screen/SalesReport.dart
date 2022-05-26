import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sellermultivendor/Helper/ApiBaseHelper.dart';
import 'package:sellermultivendor/Helper/AppBtn.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Helper/Constant.dart';
import 'package:sellermultivendor/Helper/Session.dart';
import 'package:sellermultivendor/Helper/String.dart';
import '../Model/SalesReportModel/SalesReportModel.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({Key? key}) : super(key: key);

  @override
  _SalesReportState createState() => _SalesReportState();
}

bool isLoadingmore = true;
int offset = 0;
int total = 0;
List<SalesReportModel> tranList = [];

class _SalesReportState extends State<SalesReport>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String totalReports = "",
      totalDeliveryCharge = "",
      grandFinalTotal = "",
      grandTotal = "";

  TextEditingController amountController = TextEditingController();
  TextEditingController msgController = TextEditingController();
  bool _isNetworkAvail = true;
  String? amount, msg;
  ScrollController controller = ScrollController();
  TextEditingController? amtC, bankDetailC;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<SalesReportModel> tempList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    getSalesReportRequest();
    controller.addListener(_scrollListener);
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
    amtC = TextEditingController();
    bankDetailC = TextEditingController();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total) getSalesReportRequest();
        });
      }
    }
  }

  Future<void> getSalesReportRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        SellerId: CUR_USERID,
        //    OFFSET: "0",
      };
      apiBaseHelper.postAPICall(getSalesListApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];
          String msgtest = getdata["message"];
          if (!error) {
            totalReports = getdata["total"];
            totalDeliveryCharge = getdata["grand_total"];
            grandFinalTotal = getdata["total_delivery_charge"];
            grandTotal = getdata["grand_final_total"];
            total = int.parse(
              getdata["total"],
            );
            if ((offset) < total) {
              tempList.clear();
              var data = getdata["rows"];

              tempList = (data as List)
                  .map((data) => SalesReportModel.fromJson(data))
                  .toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
            _isLoading = false;

            setState(
              () {},
            );
          } else {
            setsnackbar(msgtest, context);
            _isLoading = true;

            setState(
              () {},
            );
          }
        },
        onError: (error) {
          setsnackbar(
            error.toString(),
            context,
          );
          setState(
            () {
              _isLoading = false;
              isLoadingmore = false;
            },
          );
        },
      );
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
    }
    return;
  }

  getRowFields(
    String title,
    String value,
    bool simple,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: grey,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          () {
            if (simple) {
              return value;
            } else {
              return getPriceFormat(
                context,
                double.parse(value),
              )!;
            }
          }(),
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: grey,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  getGeneralDataShower() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getRowFields("Total Orders :", totalReports, true),
              const SizedBox(
                height: 15,
              ),
              getRowFields("Grand Total :", totalDeliveryCharge, false),
              getRowFields("Total Delivery Charge :", grandFinalTotal, false),
              const Divider(),
              getRowFields("Grand Final Total :", grandTotal, false),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    Completer<void> completer = Completer<void>();
    await Future.delayed(const Duration(seconds: 3)).then(
      (onvalue) {
        completer.complete();
        offset = 0;
        total = 0;
        tranList.clear();
        setState(
          () {
            _isLoading = true;
          },
        );
        tranList.clear();
        getSalesReportRequest();
      },
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: lightWhite,
      appBar: getAppBar("Sales Report", context),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      children: [
                        getGeneralDataShower(),
                        tranList.isEmpty
                            ? Center(
                                child: Text(
                                  getTranslated(context, "noItem")!,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: (offset < total)
                                    ? tranList.length + 1
                                    : tranList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return (index == tranList.length &&
                                          isLoadingmore)
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : listItem(index);
                                },
                              ),
                      ],
                    ),
                  ),
                )
          : noInternet(context),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
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
              title: getTranslated(context, "TRY_AGAIN_INT_LBL")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      await getSalesReportRequest();
                    } else {
                      await buttonController!.reverse();
                      setState(
                        () {},
                      );
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

  listItem(int index) {
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Name" + " : " + tranList[index].name!,
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      capitalize(tranList[index].paymentMethod!),
                      style: const TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const Divider(),
              getRowFields("Order ID" + " : ", tranList[index].id!, true),
              getRowFields(
                  "Date & Time" + " : ", tranList[index].dateAdded!, true),
              const SizedBox(
                height: 10,
              ),
              getRowFields("Total " + " : ", tranList[index].total!, false),
              getRowFields(
                  "Tax Amount" + " : ", tranList[index].taxAmount!, false),
              getRowFields(
                  "Discount" + " : ", tranList[index].discountedPrice!, false),
              getRowFields("Delivery Charge" + " : ",
                  tranList[index].deliveryCharge!, false),
              Divider(),
              getRowFields(
                  "Final Total" + " : ", tranList[index].finalTotal!, false),
            ],
          ),
        ),
      ),
    );
  }
}
