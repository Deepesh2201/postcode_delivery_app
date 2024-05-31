import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> submit() async {
    Map req = {
      'old_password': oldPassController.text.trim(),
      'new_password': newPassController.text.trim(),
    };
    appStore.setLoading(true);

    await setValue(USER_PASSWORD, newPassController.text.trim());

    await changePassword(req).then((value) {
      toast(value.message.toString());
      appStore.setLoading(false);

      finish(context);
    }).catchError((error) {
      appStore.setLoading(false);

      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.changePassword)),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: BodyCornerWidget(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, top: 30, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.oldPassword, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: oldPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: oldPassFocus,
                      nextFocus: newPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorMinimumPasswordLength: language.passwordInvalid,
                    ),
                    16.height,
                    Text(language.newPassword, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: newPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: newPassFocus,
                      nextFocus: confirmPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorMinimumPasswordLength: language.passwordInvalid,
                    ),
                    16.height,
                    Text(language.confirmPassword, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: confirmPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: confirmPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorMinimumPasswordLength: language.passwordInvalid,
                      validator: (val) {
                        if (val!.isEmpty) return language.fieldRequiredMsg;
                        if (val != newPassController.text) return language.passwordNotMatch;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.saveChanges, () {
          if (formKey.currentState!.validate()) {
            submit();
          }
        }),
      ),
    );
  }
}
