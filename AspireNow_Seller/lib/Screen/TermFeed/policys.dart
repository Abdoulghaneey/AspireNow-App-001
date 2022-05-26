import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sellermultivendor/Helper/Color.dart';
import 'package:sellermultivendor/Helper/String.dart';

import '../../Helper/ApiBaseHelper.dart';
import '../../Helper/Session.dart';

class Policy extends StatefulWidget {
  //const ContactUs({Key? key}) : super(key: key);
  String? title;
  int? index;
  Policy({
    this.title,
    this.index,
  });
  @override
  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {
//==============================================================================
//============================= Variables Declaration ==========================

  bool _isLoading = true;
  bool _isNetworkAvail = true;
  String? contactUs;
  String? termCondition;
  String? privacyPolicy;
  String? returnPolicy;
  String? shippingPolicy;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

//==============================================================================
//============================= initState Method ===============================

  @override
  void initState() {
    super.initState();
    getSettings();
  }

//==============================================================================
//========================= getStatics API =====================================

  getSettings() async {
    _isNetworkAvail = await isNetworkAvailable();
    var parameter = {};
    if (_isNetworkAvail) {
      apiBaseHelper.postAPICall(getSettingsApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            contactUs = getdata["data"]["contact_us"][0].toString();
            termCondition = getdata["data"]["terms_conditions"][0].toString();
            privacyPolicy = getdata["data"]["privacy_policy"][0].toString();
            returnPolicy = getdata["data"]["return_policy"][0].toString();
            shippingPolicy = getdata["data"]["shipping_policy"][0].toString();
          } else {
            setsnackbar(
              msg,
              context,
            );
          }
          setState(
            () {
              _isLoading = false;
            },
          );
        },
        onError: (error) {
          setsnackbar(
            error.toString(),
            context,
          );
        },
      );
    } else {
      setState(
        () {
          _isLoading = false;
          _isNetworkAvail = false;
        },
      );
    }
  }

//==============================================================================
//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: getAppBar(
        widget.title!,
        context,
      ),
      body: _isNetworkAvail
          ? _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Html(
                    data: () {
                      if (widget.index == 1) {
                        return contactUs ?? "";
                      } else if (widget.index == 2) {
                        return termCondition ?? "";
                      } else if (widget.index == 3) {
                        return privacyPolicy ?? "";
                      } else if (widget.index == 4) {
                        return returnPolicy ?? "";
                      } else if (widget.index == 5) {
                        return shippingPolicy ?? "";
                      } else {
                        return "";
                      }
                    }(),
                  ),
                )
          : noInternet(context),
    );
  }
}

//==============================================================================
//============================ No Internet Widget ==============================

noInternet(BuildContext context) {
  return Container(
    child: Center(
      child: Text(
        getTranslated(context, "NoInternetAwailable")!,
      ),
    ),
  );
}
