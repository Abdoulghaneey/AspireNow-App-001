import 'dart:async';
import 'package:flutter/material.dart';

import '../Helper/ApiBaseHelper.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateProfile();
}

String? lat, long;

class StateProfile extends State<Profile> with TickerProviderStateMixin {
//==============================================================================
//========================== Variable Dectlaration =============================

  String? name,
      email,
      mobile,
      address,
      image,
      curPass,
      newPass,
      confPass,
      loaction,
      accNo,
      storename,
      storeurl,
      storeDesc,
      accname,
      bankname,
      bankcode,
      latitutute,
      longitude,
      taxname,
      taxnumber,
      pannumber,
      status,
      storelogo;

  bool isLoading = false;
  GlobalKey<FormState> sellernameKey = GlobalKey<FormState>();
  GlobalKey<FormState> mobilenumberKey = GlobalKey<FormState>();

  GlobalKey<FormState> emailKey = GlobalKey<FormState>();
  GlobalKey<FormState> addressKey = GlobalKey<FormState>();
  GlobalKey<FormState> storenameKey = GlobalKey<FormState>();
  GlobalKey<FormState> storeurlKey = GlobalKey<FormState>();
  GlobalKey<FormState> storeDescKey = GlobalKey<FormState>();
  GlobalKey<FormState> accnameKey = GlobalKey<FormState>();
  GlobalKey<FormState> accnumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> bankcodeKey = GlobalKey<FormState>();
  GlobalKey<FormState> banknameKey = GlobalKey<FormState>();
  GlobalKey<FormState> latitututeKey = GlobalKey<FormState>();
  GlobalKey<FormState> longituteKey = GlobalKey<FormState>();
  GlobalKey<FormState> taxnameKey = GlobalKey<FormState>();
  GlobalKey<FormState> taxnumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> pannumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController? nameC,
      emailC,
      mobileC,
      addressC,
      storenameC,
      storeurlC,
      storeDescC,
      accnameC,
      accnumberC,
      bankcodeC,
      banknameC,
      latitututeC,
      longituteC,
      taxnameC,
      taxnumberC,
      pannumberC,
      curPassC,
      newPassC,
      confPassC,
      unusedC;

  bool isSelected = false, isArea = true;
  bool _isNetworkAvail = true;
  bool _showCurPassword = false, _showPassword = false, _showCmPassword = false;
  Animation? buttonSqueezeanimation;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  AnimationController? buttonController;

//==============================================================================
//============================= Init method ====================================

  @override
  void initState() {
    super.initState();

    mobileC = TextEditingController();
    nameC = TextEditingController();
    emailC = TextEditingController();
    addressC = TextEditingController();
    storenameC = TextEditingController();
    storeurlC = TextEditingController();
    storeDescC = TextEditingController();
    accnameC = TextEditingController();
    accnumberC = TextEditingController();
    bankcodeC = TextEditingController();
    banknameC = TextEditingController();
    latitututeC = TextEditingController();
    longituteC = TextEditingController();
    taxnameC = TextEditingController();
    pannumberC = TextEditingController();
    taxnumberC = TextEditingController();
    getUserDetails();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

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
  }
//==============================================================================
//============================= dispose method =================================

  @override
  void dispose() {
    buttonController!.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    addressC!.dispose();
    emailC!.dispose();
    storenameC!.dispose();
    storeurlC!.dispose();
    storeDescC!.dispose();
    accnameC!.dispose();
    accnumberC!.dispose();
    bankcodeC!.dispose();
    banknameC!.dispose();
    latitututeC!.dispose();
    longituteC!.dispose();
    taxnameC!.dispose();
    pannumberC!.dispose();
    taxnumberC!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

//==============================================================================
//================= User Details frome Shared Preferance =======================

  getUserDetails() async {
    CUR_USERID = await getPrefrence(Id);
    mobile = await getPrefrence(Mobile);
    name = await getPrefrence(Username);
    email = await getPrefrence(Email);
    address = await getPrefrence(Address);
    image = await getPrefrence(IMage);
    CUR_USERID = await getPrefrence(Id);
    mobile = await getPrefrence(Mobile);
    storename = await getPrefrence(StoreName);
    storeurl = await getPrefrence(Storeurl);
    storeDesc = await getPrefrence(storeDescription);
    accNo = await getPrefrence(accountNumber);
    accname = await getPrefrence(accountName);
    bankcode = await getPrefrence(bankCode);
    bankname = await getPrefrence(bankName);
    latitutute = await getPrefrence(Latitude);
    longitude = await getPrefrence(Longitude);
    taxname = await getPrefrence(taxName);
    taxnumber = await getPrefrence(taxNumber);
    pannumber = await getPrefrence(panNumber);
    status = await getPrefrence(STATUS);
    storelogo = await getPrefrence(StoreLogo);
    mobileC!.text = mobile ?? "";
    nameC!.text = name ?? "";
    emailC!.text = email ?? "";
    addressC!.text = address ?? "";
    storenameC!.text = storename ?? "";
    storeurlC!.text = storeurl ?? "";
    storeDescC!.text = storeDesc ?? "";
    accnameC!.text = accname ?? "";
    accnumberC!.text = accNo ?? "";
    bankcodeC!.text = bankcode ?? "";
    banknameC!.text = bankname ?? "";
    latitututeC!.text = latitutute ?? "";
    longituteC!.text = longitude ?? "";
    taxnameC!.text = taxname ?? "";
    taxnumberC!.text = taxnumber ?? "";
    pannumberC!.text = pannumber ?? "";
    setState(() {});
  }

//==============================================================================
//===================== noInternet Widget ======================================

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

                Future.delayed(
                  const Duration(seconds: 2),
                ).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
                      );
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

//==============================================================================
//========================= Network awailabilitry ==============================

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await buttonController!.reverse();
      setUpdateUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        },
      );
    }
  }

//==============================================================================
//========================= For Update Saller API  =============================

  Future<void> setUpdateUser() async {
    var parameter = {
      Id: CUR_USERID,
      Name: name ?? "",
      Mobile: mobile ?? "",
      Email: email ?? "",
      Address: address ?? "",
      StoreName: storename ?? "",
      Storeurl: storeurl ?? "",
      storeDescription: storeDesc ?? "",
      accountNumber: accNo ?? "",
      accountName: accname ?? "",
      bankCode: bankcode ?? "",
      bankName: bankname ?? "",
      Latitude: latitutute ?? "",
      Longitude: longitude ?? "",
      taxName: taxname ?? "",
      taxNumber: taxnumber ?? "",
      panNumber: pannumber ?? "",
      STATUS: status ?? "1",
    };

    apiBaseHelper.postAPICall(updateUserApi, parameter).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          await buttonController!.reverse();
          setsnackbar(msg!, context);
        } else {
          await buttonController!.reverse();
          setsnackbar(msg!, context);
          setState(
            () {},
          );
        }
      },
      onError: (error) {
        setsnackbar(error.toString(), context);
      },
    );
  }

//==============================================================================
//========================== build Method ======================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(getTranslated(context, "EDIT_PROFILE_LBL")!, context),
      body: Stack(
        children: <Widget>[
          bodyPart(),
          showCircularProgress(isLoading, primary)
        ],
      ),
    );
  }

//==============================================================================
//========================== build Method ======================================
  bodyPart() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: _isNetworkAvail
            ? Column(
                children: <Widget>[
                  getprofileImage(),
                  getFirstHeader(),
                  getSecondHeader(),
                  getThirdHeader(),
                  getFurthHeader(),
                  changePass(),
                  updateBtn(),
                ],
              )
            : noInternet(context),
      ),
    );
  }

//==============================================================================
//=========================== profile Image ====================================

  getprofileImage() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: primary,
        child: LOGO != ''
            ? Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: primary)),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(LOGO),
                  radius: 100,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: primary)),
                child: const Icon(Icons.account_circle, size: 100)),
      ),
    );
  }

//==============================================================================
//============================== First Header ==================================

  getFirstHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5.0),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.person_outlined,
              getTranslated(context, "NAME_LBL")!,
              name,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "ADD_NAME_LBL")!,
              sellernameKey,
              TextInputType.text,
              (val) => validateUserName(val, context),
              0,
            ),
            getDivider(),
            commanDesingFields(
              Icons.phone_in_talk_outlined,
              getTranslated(context, "MOBILEHINT_LBL")!,
              mobile,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "Add Mobile Number")!,
              mobilenumberKey,
              TextInputType.number,
              (val) => validateMob(val, context),
              1,
            ),
            getDivider(),
            commanDesingFields(
              Icons.email_outlined,
              getTranslated(context, "Email")!,
              email,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addEmail")!,
              emailKey,
              TextInputType.text,
              (val) => validateField(val, context),
              2,
            ),
            getDivider(),
            commanDesingFields(
              Icons.location_on_outlined,
              getTranslated(context, "Addresh")!,
              address,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddAddress")!,
              addressKey,
              TextInputType.text,
              (val) => validateField(val, context),
              3,
            ),
          ],
        ),
      ),
    );
  }

//==============================================================================
//============================ Second Header ===================================

  getSecondHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5.0),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.store_outlined,
              getTranslated(context, "StoreName")!,
              storename,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addStoreName")!,
              storenameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              4,
            ),
            getDivider(),
            commanDesingFields(
              Icons.link_outlined,
              getTranslated(context, "StoreURL")!,
              storeurl,
              getTranslated(context, "NoURL")!,
              getTranslated(context, "addURL")!,
              storeurlKey,
              TextInputType.text,
              (val) => validateField(val, context),
              5,
            ),
            getDivider(),
            commanDesingFields(
              Icons.description_outlined,
              getTranslated(context, "Description")!,
              storeDesc,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addDescription")!,
              storeDescKey,
              TextInputType.text,
              (val) => validateField(val, context),
              6,
            ),
          ],
        ),
      ),
    );
  }

//==============================================================================
//============================ Third Header ====================================

  getThirdHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5.0),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.format_list_numbered_outlined,
              getTranslated(context, "AccountNumber")!,
              accNo,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addAccontNumber")!,
              accnumberKey,
              TextInputType.text,
              (val) => validateField(val, context),
              7,
            ),
            getDivider(),
            commanDesingFields(
              Icons.import_contacts_outlined,
              getTranslated(context, "AccountName")!,
              accname,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addAccountName")!,
              accnameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              8,
            ),
            getDivider(),
            commanDesingFields(
              Icons.request_quote_outlined,
              getTranslated(context, "BankCode")!,
              bankcode,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addBankCode")!,
              bankcodeKey,
              TextInputType.text,
              (val) => validateField(val, context),
              9,
            ),
            getDivider(),
            commanDesingFields(
              Icons.account_balance_outlined,
              getTranslated(context, "BankName")!,
              bankname,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addBankName")!,
              banknameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              10,
            ),
          ],
        ),
      ),
    );
  }

//==============================================================================
//========================= Fourth Header ======================================

  getFurthHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5.0),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.travel_explore_outlined,
              getTranslated(context, "Latitute")!,
              latitutute,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddLatitute")!,
              latitututeKey,
              TextInputType.text,
              (val) => validateField(val, context),
              11,
            ),
            getDivider(),
            commanDesingFields(
              Icons.language_outlined,
              getTranslated(context, "Longitude")!,
              longitude,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddLongitude")!,
              longituteKey,
              TextInputType.text,
              (val) => validateField(val, context),
              12,
            ),
            getDivider(),
            commanDesingFields(
              Icons.text_snippet_outlined,
              getTranslated(context, "TaxName")!,
              taxname,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addTaxName")!,
              taxnameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              13,
            ),
            getDivider(),
            commanDesingFields(
              Icons.assignment_outlined,
              getTranslated(context, "TaxNumber")!,
              taxnumber,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addTaxNumber")!,
              taxnumberKey,
              TextInputType.text,
              (val) => validateField(val, context),
              14,
            ),
            getDivider(),
            commanDesingFields(
              Icons.picture_in_picture_outlined,
              getTranslated(context, "PanNumber")!,
              pannumber,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addPanNumber")!,
              pannumberKey,
              TextInputType.text,
              (val) => validateField(val, context),
              15,
            ),
          ],
        ),
      ),
    );
  }
//==============================================================================
//============================== Divider =======================================

  getDivider() {
    return const Divider(
      height: 1,
      color: lightBlack,
    );
  }

//==============================================================================
//=========================== Saller Name ======================================
  commanDesingFields(
    IconData? icon,
    String title,
    String? variable,
    String empty,
    String addField,
    GlobalKey<FormState> key,
    TextInputType? keybordtype,
    String? Function(String?)? validation,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Icon(
              icon,
              color: primary,
              size: 27,
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: lightBlack2,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                  variable != "" && variable != null
                      ? Text(
                          variable,
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    color: lightBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          empty,
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    color: lightBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: black,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(0),
                      elevation: 2.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              addField,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: fontColor),
                            ),
                          ),
                          const Divider(color: black),
                          Form(
                            key: key,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                              child: TextFormField(
                                keyboardType: keybordtype,
                                style: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      color: lightBlack,
                                      fontWeight: FontWeight.normal,
                                    ),
                                validator: validation,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: () {
                                  if (index == 0) {
                                    return nameC;
                                  } else if (index == 1) {
                                    return mobileC;
                                  } else if (index == 2) {
                                    return emailC;
                                  } else if (index == 3) {
                                    return addressC;
                                  } else if (index == 4) {
                                    return storenameC;
                                  } else if (index == 5) {
                                    return storeurlC;
                                  } else if (index == 6) {
                                    return storeDescC;
                                  } else if (index == 7) {
                                    return accnumberC;
                                  } else if (index == 8) {
                                    return accnameC;
                                  } else if (index == 9) {
                                    return bankcodeC;
                                  } else if (index == 10) {
                                    return banknameC;
                                  } else if (index == 11) {
                                    return latitututeC;
                                  } else if (index == 12) {
                                    return longituteC;
                                  } else if (index == 13) {
                                    return taxnameC;
                                  } else if (index == 14) {
                                    return taxnumberC;
                                  } else if (index == 15) {
                                    return pannumberC;
                                  }
                                  return unusedC;
                                }(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            getTranslated(context, "CANCEL")!,
                            style: const TextStyle(
                              color: lightBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setState(
                              () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                        TextButton(
                          child: Text(
                            getTranslated(context, "SAVE_LBL")!,
                            style: const TextStyle(
                              color: fontColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            final form = key.currentState!;
                            if (form.validate()) {
                              form.save();
                              setState(
                                () {
                                  () {
                                    if (index == 0) {
                                      name = nameC!.text;
                                    } else if (index == 1) {
                                      mobile = mobileC!.text;
                                    } else if (index == 2) {
                                      email = emailC!.text;
                                    } else if (index == 3) {
                                      address = addressC!.text;
                                    } else if (index == 4) {
                                      storename = storenameC!.text;
                                    } else if (index == 5) {
                                      storeurl = storeurlC!.text;
                                    } else if (index == 6) {
                                      storeDesc = storeDescC!.text;
                                    } else if (index == 7) {
                                      accNo = accnumberC!.text;
                                    } else if (index == 8) {
                                      accname = accnameC!.text;
                                    } else if (index == 9) {
                                      bankcode = bankcodeC!.text;
                                    } else if (index == 10) {
                                      bankname = banknameC!.text;
                                    } else if (index == 11) {
                                      latitutute = latitututeC!.text;
                                    } else if (index == 12) {
                                      longitude = longituteC!.text;
                                    } else if (index == 13) {
                                      taxname = taxnameC!.text;
                                    } else if (index == 14) {
                                      taxnumber = taxnumberC!.text;
                                    } else if (index == 15) {
                                      pannumber = pannumberC!.text;
                                    }
                                  }();
                                  Navigator.pop(context);
                                },
                              );
                            }
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

//==============================================================================
//============================ Change Pass =====================================

  changePass() {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            top: 15.0,
            bottom: 15.0,
          ),
          child: Text(
            getTranslated(context, "CHANGE_PASS_LBL")!,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(color: fontColor, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          _showDialog();
        },
      ),
    );
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
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                      child: Text(
                        getTranslated(context, "CHANGE_PASS_LBL")!,
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: fontColor),
                      ),
                    ),
                    const Divider(color: lightBlack),
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (val) => validatePass(val, context),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "CUR_PASS_LBL")!,
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: lightBlack,
                                        fontWeight: FontWeight.normal),
                                suffixIcon: IconButton(
                                  icon: Icon(_showCurPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  iconSize: 20,
                                  color: lightBlack,
                                  onPressed: () {
                                    setStater(
                                      () {
                                        _showCurPassword = !_showCurPassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              obscureText: !_showCurPassword,
                              controller: curPassC,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (val) => validatePass(val, context),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "NEW_PASS_LBL")!,
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: lightBlack,
                                        fontWeight: FontWeight.normal),
                                suffixIcon: IconButton(
                                  icon: Icon(_showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  iconSize: 20,
                                  color: lightBlack,
                                  onPressed: () {
                                    setStater(
                                      () {
                                        _showPassword = !_showPassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              obscureText: !_showPassword,
                              controller: newPassC,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return getTranslated(
                                      context, "CON_PASS_REQUIRED_MSG")!;
                                }
                                if (value != newPass) {
                                  return getTranslated(
                                      context, "CON_PASS_NOT_MATCH_MSG")!;
                                } else {
                                  return null;
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    context, "CONFIRMPASSHINT_LBL")!,
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: lightBlack,
                                        fontWeight: FontWeight.normal),
                                suffixIcon: IconButton(
                                  icon: Icon(_showCmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  iconSize: 20,
                                  color: lightBlack,
                                  onPressed: () {
                                    setStater(
                                      () {
                                        _showCmPassword = !_showCmPassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              obscureText: !_showCmPassword,
                              controller: confPassC,
                              onChanged: (v) => setState(
                                () {
                                  confPass = v;
                                },
                              ),
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
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: Text(
                    getTranslated(context, "SAVE_LBL")!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final form = formKey.currentState!;
                    if (form.validate()) {
                      curPass = curPassC!.text;
                      newPass = newPassC!.text;
                      form.save();
                      setState(
                        () {
                          Navigator.pop(context);
                        },
                      );
                      changePassWord();
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
//==============================================================================
//==================== Same API But Only PassPassword ==========================

  Future<void> changePassWord() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        Id: CUR_USERID,
        Name: name ?? "",
        Mobile: mobile ?? "",
        Email: email ?? "",
        Address: address ?? "",
        StoreName: storename ?? "",
        Storeurl: storeurl ?? "",
        storeDescription: storeDesc ?? "",
        accountNumber: accNo ?? "",
        accountName: accname ?? "",
        bankCode: bankcode ?? "",
        bankName: bankname ?? "",
        Latitude: latitutute ?? "",
        Longitude: longitude ?? "",
        taxName: taxname ?? "",
        taxNumber: taxnumber ?? "",
        panNumber: pannumber ?? "",
        STATUS: status ?? "1",
        OLDPASS: curPass,
        NEWPASS: newPass,
      };
      apiBaseHelper.postAPICall(updateUserApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            Navigator.pop(context);
            setsnackbar(msg!, context);
          } else {
            Navigator.pop(context);
            setsnackbar(msg!, context);
          }
        },
        onError: (error) {
          setsnackbar(error.toString(), context);
        },
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        },
      );
    }
  }
//==============================================================================
//============================== LoginBtn ======================================

  updateBtn() {
    return AppBtn(
      title: getTranslated(context, "Update Profile")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        _playAnimation();
        checkNetwork();
      },
    );
  }
//==============================================================================
//========================= circular Progress ==================================

  Widget showCircularProgress(bool _isProgress, Color color) {
    if (_isProgress) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return const SizedBox(
      height: 0.0,
      width: 0.0,
    );
  }

//==============================================================================
//========================= everything is completed ============================

}
