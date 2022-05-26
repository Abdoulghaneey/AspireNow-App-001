import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sellermultivendor/Helper/ApiBaseHelper.dart';
import 'package:sellermultivendor/Helper/AppBtn.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Helper/Constant.dart';
import 'package:sellermultivendor/Helper/Session.dart';
import 'package:sellermultivendor/Helper/SimBtn.dart';
import 'package:sellermultivendor/Helper/String.dart';

import '../Model/getWithdrawelRequest/getWithdrawelmodel.dart';

class WalletHistory extends StatefulWidget {
  const WalletHistory({Key? key}) : super(key: key);

  @override
  _WalletHistoryState createState() => _WalletHistoryState();
}

bool _isLoading = true;
bool isLoadingmore = true;
int offset = 0;
int total = 0;
List<GetWithdrawelReq> tranList = [];

class _WalletHistoryState extends State<WalletHistory>
    with TickerProviderStateMixin {
  TextEditingController amountController = TextEditingController();
  TextEditingController msgController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isNetworkAvail = true;
  String? amount, msg;
  ScrollController controller = ScrollController();
  TextEditingController? amtC, bankDetailC;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<GetWithdrawelReq> tempList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    getWithdrawalRequest();
    getSallerBalance();
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

          if (offset < total) getWithdrawalRequest();
        });
      }
    }
  }

  getSallerBalance() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      CUR_USERID = await getPrefrence(Id);

      var parameter = {Id: CUR_USERID};
      apiBaseHelper.postAPICall(getSellerDetailsApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];

          if (!error) {
            var data = getdata["data"][0];
            CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
          }
          setState(() {
            _isLoading = false;
          });
        },
        onError: (error) {
          setsnackbar(
            error.toString(),
            context,
          );
          setState(() {
            _isLoading = false;
          });
        },
      );
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            _isLoading = false;
          },
        );
      }
    }
    return null;
  }

  Future<void> getWithdrawalRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {UserId: CUR_USERID};
      apiBaseHelper.postAPICall(getWithDrawalRequestApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];
          if (!error) {
            total = int.parse(
              getdata["total"],
            );
            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];

              tempList = (data as List)
                  .map((data) => GetWithdrawelReq.fromReqJson(data))
                  .toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
            await getSallerBalance();
          }
          setState(() {
            _isLoading = false;
          });
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
      setState(() {
        _isNetworkAvail = false;
      });
    }
    return;
  }

  getBalanceShower() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: primary,
                  ),
                  Text(
                    " " + getTranslated(context, "CURBAL_LBL")!,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: grey,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(getPriceFormat(context, double.parse(CUR_BALANCE))!,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: black, fontWeight: FontWeight.bold)),
              SimBtn(
                size: 0.8,
                title: getTranslated(context, "WITHDRAW_MONEY")!,
                onBtnSelected: () {
                  _showDialog();
                },
              ),
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
        getWithdrawalRequest();
        getSallerBalance();
      },
    );
    return completer.future;
  }

  // send withdrawel request

  Future<void> sendRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      //    try {
      var parameter = {
        UserId: CUR_USERID,
        Amount: amtC!.text.toString(),
        PaymentAddress: bankDetailC!.text.toString()
      };

      apiBaseHelper.postAPICall(sendWithDrawalRequestApi, parameter).then(
        (getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (!error) {
            setsnackbar(
              msg!,
              context,
            );
            setState(
              () {
                _isLoading = true;
              },
            );
            tranList.clear();
            getWithdrawalRequest();
          } else {
            setsnackbar(
              msg!,
              context,
            );
          }
        },
      );
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            _isLoading = false;
          },
        );
      }
    }

    return;
  }

  _showDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                      child: Text(
                        getTranslated(context, "SEND_REQUEST")!,
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: fontColor),
                      ),
                    ),
                    const Divider(color: lightBlack),
                    Form(
                      key: _formkey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (val) => validateField(val, context),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "WITHDRWAL_AMT")!,
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: lightBlack,
                                        fontWeight: FontWeight.normal),
                              ),
                              controller: amtC,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              validator: (val) => validateField(val, context),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: BANK_DETAIL,
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: lightBlack,
                                        fontWeight: FontWeight.normal),
                              ),
                              controller: bankDetailC,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, "CANCEL")!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: lightBlack, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, "SEND_LBL")!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final form = _formkey.currentState!;
                    if (form.validate()) {
                      form.save();
                      sendRequest();
                      Navigator.pop(context);
                      offset = 0;
                      total = 0;
                      tranList.clear();
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: lightWhite,
      appBar: getAppBar("Wallet History", context),
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
                        getBalanceShower(),
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
                                          child: CircularProgressIndicator())
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
                      await getWithdrawalRequest();
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
    Color back;
    if (tranList[index].status == "success" ||
        tranList[index].status == ACCEPTEd) {
      back = Colors.green;
    } else if (tranList[index].status == PENDINg) {
      back = Colors.orange;
    } else {
      back = red;
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    getTranslated(context, "AMT_LBL")! +
                        " : " +
                        getPriceFormat(context,
                            double.parse(tranList[index].amountRequested!))!,
                    style: const TextStyle(
                        color: black, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(tranList[index].dateCreated!),
                ],
              ),
              const Divider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    getTranslated(context, "ID_LBL")! +
                        " : " +
                        tranList[index].id!,
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: back,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      capitalize(tranList[index].status!),
                      style: const TextStyle(color: white),
                    ),
                  )
                ],
              ),
              tranList[index].paymentAddress != null &&
                      tranList[index].paymentAddress!.isNotEmpty
                  ? Text(getTranslated(context, "PaymentAddress")! +
                      " : " +
                      tranList[index].paymentAddress! +
                      ".")
                  : Container(),
              tranList[index].paymentType != null &&
                      tranList[index].paymentType!.isNotEmpty
                  ? Text(getTranslated(context, "PaymentType")! +
                      " : " +
                      tranList[index].paymentType!)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
