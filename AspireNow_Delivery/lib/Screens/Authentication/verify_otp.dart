import 'dart:async';
import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/app_btn.dart';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/cropped_container.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'set_password.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;

  VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.title})
      : super(key: key);

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password, mobile, countrycode;
  String? otp;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = "";
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getUserDetails();
    getSingature();
    _onVerifyCode();
    Future.delayed(Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));
  }

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    await SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    mobile = await getPrefrence(MOBILE);
    countrycode = await getPrefrence(COUNTRY_CODE);
    setState(() {});
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setSnackbar(OTPWR);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });

      Future.delayed(Duration(seconds: 60)).then((_) async {
        bool avail = await isNetworkAvailable();
        if (avail) {
          if (_isClickable)
            _onVerifyCode();
          else {
            setSnackbar(OTPWR);
          }
        } else {
          await buttonController!.reverse();
          setSnackbar(somethingMSg);
        }
      });
    }
  }

  verifyBtn() {
    return AppBtn(
        title: VERIFY_AND_PROCEED,
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          _onFormSubmitted();
        });
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: fontColor),
      ),
      backgroundColor: lightWhite,
      elevation: 1.0,
    ));
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          setSnackbar(OTPMSG);
          setPrefrence(MOBILE, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          if (widget.title == FORGOT_PASS_TITLE) {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (context) => SetPass(mobileNumber: mobile!)));
          }
        } else {
          setSnackbar(OTPERROR);
        }
      }).catchError((error) {
        setSnackbar(error.toString());
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setSnackbar(authException.message!);

      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _isClickable = true;
        _verificationId = verificationId;
      });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential _authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(_authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          await buttonController!.reverse();
          setSnackbar(OTPMSG);
          setPrefrence(MOBILE, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          if (widget.title == SEND_OTP_TITLE) {
            /*  Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context, CupertinoPageRoute(builder: (context) => SignUp()));
            });*/
          } else if (widget.title == FORGOT_PASS_TITLE) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SetPass(mobileNumber: mobile!)));
            });
          }
        } else {
          setSnackbar(OTPERROR);
          await buttonController!.reverse();
        }
      }).catchError((error) async {
        setSnackbar(error.toString());

        await buttonController!.reverse();
      });
    } else {
      setSnackbar(ENTEROTP);
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getImage() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Image.asset(
          'assets/images/splashlogo.png',
          color: primary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  Widget monoVarifyText() {
    return Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 30.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(MOBILE_NUMBER_VARIFICATION,
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(color: primary, fontWeight: FontWeight.bold)),
        ));
  }

  Widget otpText() {
    return Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Center(
          child: Text(SENT_VERIFY_CODE_TO_NO_LBL,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: fontColor, fontWeight: FontWeight.normal)),
        ));
  }

  Widget mobText() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 10.0, left: 20.0, right: 20.0, top: 10.0),
      child: Center(
        child: Text("+$countrycode-$mobile",
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: fontColor, fontWeight: FontWeight.normal)),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
        padding: const EdgeInsets.only(
          left: 50.0,
          right: 50.0,
        ),
        child: Center(
            child: PinFieldAutoFill(
                decoration: const UnderlineDecoration(
                  textStyle: TextStyle(fontSize: 20, color: fontColor),
                  colorBuilder: FixedColorBuilder(primary),
                ),
                currentCode: otp,
                codeLength: 6,
                onCodeChanged: (String? code) {
                  otp = code;
                },
                onCodeSubmitted: (String code) {
                  otp = code;
                })));
  }

  Widget resendText() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 30.0, left: 25.0, right: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DIDNT_GET_THE_CODE,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: fontColor, fontWeight: FontWeight.normal),
          ),
          InkWell(
              onTap: () async {
                await buttonController!.reverse();
                checkNetworkOtp();
              },
              child: Text(
                RESEND_OTP,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        body: Container(
          color: lightWhite,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: back(),
              ),
              Image.asset(
                'assets/images/doodle.png',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
              getLoginContainer(),
              getLogo(),
            ],
          ),
        ));
  }

  Widget getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      monoVarifyText(),
                      otpText(),
                      mobText(),
                      otpLayout(),
                      verifyBtn(),
                      resendText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          'assets/images/loginlogo.svg',
        ),
      ),
    );
  }
}
