import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/ForgotPasswordScreen.dart';
import '../../main/screens/RegisterScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../components/UserCitySelectScreen.dart';
import '../models/CityListModel.dart';
import '../services/AuthSertvices.dart';
import 'SplashScreen.dart';
import 'VerificationScreen.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authService = AuthServices();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;

  bool isAcceptedTc = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary, statusBarIconBrightness: Brightness.light);
    if (getStringAsync(PLAYER_ID).isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        //
      });
    }
    mIsCheck = getBoolAsync(REMEMBER_ME, defaultValue: false);
    if (mIsCheck) {
      emailController.text = getStringAsync(USER_EMAIL);
      passController.text = getStringAsync(USER_PASSWORD);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> loginApiCall() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      if (isAcceptedTc) {
        appStore.setLoading(true);

        Map req = {
          "email": emailController.text,
          "password": passController.text,
          "player_id": getStringAsync(PLAYER_ID).validate(),
        };

        if (mIsCheck) {
          await setValue(REMEMBER_ME, mIsCheck);
          await setValue(USER_EMAIL, emailController.text);
          await setValue(USER_PASSWORD, passController.text);
        }
        await logInApi(req).then((v) async {
          authService.signInWithEmailPassword(context, email: emailController.text, password: passController.text).then((value) async {
            appStore.setLoading(false);
            if (v.data!.userType != CLIENT && v.data!.userType != DELIVERY_MAN) {
              await logout(context, isFromLogin: true);
            } else {
              if (getIntAsync(STATUS) == 1) {
                updateUserStatus({
                  "id": getIntAsync(USER_ID),
                  "uid": getStringAsync(UID),
                }).then((value) {
                  log("value...." + value.toString());
                });
                if (v.data!.countryId != null && v.data!.cityId != null) {
                  await getCountryDetailApiCall(v.data!.countryId.validate());
                  getCityDetailApiCall(v.data!.cityId.validate());
                } else {
                  UserCitySelectScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
                }
              } else {
                toast(language.userNotApproveMsg);
                await logout(context, isDeleteAccount: true);
              }
            }
          });
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
        });
      } else {
        toast(language.acceptTermService);
      }
    }
  }

  getCountryDetailApiCall(int countryId) async {
    await getCountryDetail(countryId).then((value) {
      setValue(COUNTRY_DATA, value.data!.toJson());
    }).catchError((error) {});
  }

  getCityDetailApiCall(int cityId) async {
    await getCityDetail(cityId).then((value) async {
      await setValue(CITY_DATA, value.data!.toJson());
      if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
        if (getBoolAsync(OTP_VERIFIED)) {
          if (getStringAsync(USER_TYPE) == CLIENT) {
            DashboardScreen().launch(context, isNewTask: true);
          } else {
            DeliveryDashBoard().launch(context, isNewTask: true);
          }
        } else {
          VerificationScreen().launch(context, isNewTask: true);
        }
      } else {
        UserCitySelectScreen().launch(context, isNewTask: true);
      }
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: context.height() * 0.25,
                child:
                    Container(height: 90, width: 90, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Image.asset('assets/app_logo_splash.png', height: 70, width: 70)),
              ),
              Container(
                width: context.width(),
                padding: EdgeInsets.only(left: 24, right: 24),
                decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        24.height,
                        Text(language.signIn, style: boldTextStyle(size: headingSize)),
                        8.height,
                        Text(language.signInWithYourCredential, style: secondaryTextStyle(size: 16)),
                        16.height,
                        Text(language.email, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: passFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                          errorInvalidEmail: language.emailInvalid,
                        ),
                        16.height,
                        Text(language.password, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: passController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: passFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.fieldRequiredMsg,
                          errorMinimumPasswordLength: language.passwordInvalid,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: colorPrimary,
                          dense: true,
                          title: Text(language.rememberMe, style: primaryTextStyle()),
                          value: mIsCheck,
                          onChanged: (val) async {
                            mIsCheck = val!;
                            if (!mIsCheck) {
                              removeKey(REMEMBER_ME);
                            }
                            setState(() {});
                          },
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: colorPrimary,
                          dense: true,
                          title: RichTextWidget(
                            list: [
                              TextSpan(text: '${language.iAgreeToThe} ', style: secondaryTextStyle()),
                              TextSpan(
                                text: language.termOfService,
                                style: boldTextStyle(color: colorPrimary, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    commonLaunchUrl(mTermAndCondition);
                                  },
                              ),
                              TextSpan(text: ' & ', style: secondaryTextStyle()),
                              TextSpan(
                                text: language.privacyPolicy,
                                style: boldTextStyle(color: colorPrimary, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    commonLaunchUrl(mPrivacyPolicy);
                                  },
                              ),
                            ],
                          ),
                          value: isAcceptedTc,
                          onChanged: (val) async {
                            isAcceptedTc = val!;
                            setState(() {});
                          },
                        ),
                        16.height,
                        commonButton(
                          language.signIn,
                          () {
                            loginApiCall();
                          },
                          width: context.width(),
                        ),
                        6.height,
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(language.forgotPasswordQue, style: primaryTextStyle(color: colorPrimary)).onTap(() {
                            ForgotPasswordScreen().launch(context);
                          }),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(language.doNotHaveAccount, style: primaryTextStyle()),
                            4.width,
                            Text(language.signUp, style: boldTextStyle(color: colorPrimary)).onTap(() {
                              // SplashScreen();
                              RegisterScreen().launch(context, duration: Duration(milliseconds: 500), pageRouteAnimation: PageRouteAnimation.Slide);
                            }),
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ),
                ),
              ).expand(),
            ],
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Container(
        color: context.scaffoldBackgroundColor,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${language.becomeADeliveryBoy} ?", style: primaryTextStyle()),
            4.width,
            Text(language.signUp, style: boldTextStyle(color: colorPrimary)).onTap(() {
              RegisterScreen(userType: DELIVERY_MAN).launch(context, duration: Duration(milliseconds: 500), pageRouteAnimation: PageRouteAnimation.Slide);
            }),
          ],
        ),
      ),
    );
  }
}
