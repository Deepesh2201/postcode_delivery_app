import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  XFile? imageProfile;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    String phoneNum = getStringAsync(USER_CONTACT_NUMBER);
    emailController.text = getStringAsync(USER_EMAIL);
    usernameController.text = getStringAsync(USER_NAME);
    nameController.text = getStringAsync(NAME);
    if (phoneNum.split(" ").length == 1) {
      contactNumberController.text = phoneNum.split(" ").last;
    } else {
      countryCode = phoneNum.split(" ").first;
      contactNumberController.text = phoneNum.split(" ").last;
    }
    addressController.text = getStringAsync(USER_ADDRESS).validate();
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Image.file(File(imageProfile!.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(100).center();
    } else {
      if (appStore.userProfile.isNotEmpty) {
        return commonCachedNetworkImage(appStore.userProfile.validate(), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(100).center();
      } else {
        return commonCachedNetworkImage('assets/profile.png', height: 90, width: 90).cornerRadiusWithClipRRect(50).paddingOnly(right: 4, bottom: 4).center();
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future<void> save() async {
    appStore.setLoading(true);
    await updateProfile(
      file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
      name: nameController.text.validate(),
      userName: usernameController.text.validate(),
      userEmail: emailController.text.validate(),
      address: addressController.text.validate(),
      contactNumber: '$countryCode ${contactNumberController.text.trim()}',
    ).then((value) {
      finish(context);
      appStore.setLoading(false);
    }).catchError((error) {
      log(error);
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.editProfile)),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        profileImage(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: colorPrimary),
                            child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(
                                Icons.edit,
                                color: white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    16.height,
                    Text(language.email, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: usernameFocus,
                      decoration: commonInputDecoration(),
                      onTap: () {
                        toast(language.notChangeEmail);
                      },
                    ),
                    16.height,
                    Text(language.username, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: usernameController,
                      textFieldType: TextFieldType.USERNAME,
                      focus: usernameFocus,
                      nextFocus: nameFocus,
                      decoration: commonInputDecoration(),
                      onTap: () {
                        toast(language.notChangeUsername);
                      },
                    ),
                    16.height,
                    Text(language.name, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: nameController,
                      textFieldType: TextFieldType.NAME,
                      focus: nameFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                    ),
                    16.height,
                    Text(language.contactNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: contactNumberController,
                      textFieldType: TextFieldType.PHONE,
                      readOnly: true,
                      focus: contactFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(
                        prefixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryCodePicker(
                                initialSelection: countryCode,
                                showCountryOnly: false,
                                dialogSize: Size(context.width() - 60, context.height() * 0.6),
                                showFlag: true,
                                enabled: false,
                                showFlagDialog: true,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                textStyle: primaryTextStyle(),
                                dialogBackgroundColor: Theme.of(context).cardColor,
                                barrierColor: Colors.black12,
                                dialogTextStyle: primaryTextStyle(),
                                searchDecoration: InputDecoration(
                                  iconColor: Theme.of(context).dividerColor,
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                                ),
                                searchStyle: primaryTextStyle(),
                                onInit: (c) {
                                  countryCode = c!.dialCode!;
                                },
                                onChanged: (c) {
                                  countryCode = c.dialCode!;
                                },
                              ),
                              VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.trim().isEmpty) return language.fieldRequiredMsg;
                      //  if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
                        return null;
                      },
                      onTap: () {
                        toast(language.notChangeMobileNo);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    16.height,
                    Text(language.address, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: addressController,
                      textFieldType: TextFieldType.MULTILINE,
                      focus: addressFocus,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.saveChanges, () {
          if (_formKey.currentState!.validate()) {
            save();
          }
        }),
      ),
    );
  }
}
