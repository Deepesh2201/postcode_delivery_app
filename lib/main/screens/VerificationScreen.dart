import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gogo_riders_delivery/main/services/AuthSertvices.dart';
import 'package:gogo_riders_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../delivery/components/OTPDialog.dart';
import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'LoginScreen.dart';

class VerificationScreen extends StatefulWidget {
  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authService = AuthServices();
  String countryCode = defaultPhoneCode;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  userDetailGet() async {
    await getUserDetail(getIntAsync(USER_ID)).then((value) async {
      appStore.setLoading(false);
      setValue(OTP_VERIFIED, value.otpVerifyAt != null);
      setState(() {});
      if (getBoolAsync(OTP_VERIFIED).validate()) {
        DashboardScreen().launch(context, isNewTask: true);
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> mobileUpdateApiCall(String currentPhoneNumber, String newPhoneNumber, String currentPassword) async {
    hideKeyboard(context);
    appStore.setLoading(true);

    var request = {
      "current_contact": '$currentPhoneNumber',
      "new_contact": '$countryCode $newPhoneNumber',
      "current_password": '$currentPassword',
      "player_id": getStringAsync(PLAYER_ID).validate(),
    };

    try {
      // Make the API request and wait for the response
      var response = await updateMobileApi(request);

      // Check the response code
      if (response.status == true) {
        // API call was successful
        var responseBody = response.data; // Assuming your API response contains data
        var message = responseBody?.message; // Assuming 'message' is the key for the message in the response
        var status = responseBody?.status; // Assuming 'message' is the key for the message in the response

        print('-------============-------');
        print(status);
        // Check the message and take appropriate action
        if (status == 'updated') {
          // Handle success case, e.g., navigate to another screen
          LoginScreen().launch(context, isNewTask: true);
        } else if (status == 'mobile_exists') {
          // Handle case where mobile number already exists
          // You can show a toast or display an error message
          toast('Mobile number already exists');
        }
        else if (status == 'invalid_mobile') {
          // Handle case where mobile number already exists
          // You can show a toast or display an error message
          toast('Enter valid mobile number');
        }
        else if (status == 'invalid_credentials') {
          // Handle case where mobile number already exists
          // You can show a toast or display an error message
          toast('Invalid credentials');
        }
        else {
          // Handle other cases or display a generic error message
          toast('Something went wrong, try again later');
        }
      } else {
        // Handle non-200 status code (e.g., 400, 500)
        // You can display an error message based on the status code
        toast('API request failed with status code: ${response.status}');
      }

      appStore.setLoading(false);
    } catch (e) {
      // Handle any exceptions that may occur during the API request
      appStore.setLoading(false);
      toast('An error occurred: $e');
      log('API request error: $e');
    }
  }

  // Function to open the phone number change popup
  void _showPhoneNumberChangePopup() {
    String currentPhoneNumber = getStringAsync(USER_CONTACT_NUMBER); // Default value for the current phone number
    String newPhoneNumber = ""; // Initialize with an empty string for the new phone number
    String currentPassword = ""; // Initialize with an empty string for the current password

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Phone Number"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text field for Current Phone Number (disabled/readonly)
              TextFormField(
                // controller: phoneController,
                readOnly: true,
                initialValue: currentPhoneNumber, // Assign the default value
                decoration: InputDecoration(
                  labelText: "Current Phone Number",
                ),
              ),
              SizedBox(height: 10), // Add some spacing between the text fields
              Row(
                children: [
                  // Country Code Picker
                  CountryCodePicker(
                    initialSelection: countryCode,
                    showCountryOnly: false,
                    dialogSize: Size(context.width() - 60, context.height() * 0.6),
                    showFlag: false,
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
                  // Text field for New Phone Number
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "New Phone Number"),
                      onChanged: (value) {
                        newPhoneNumber = value;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Add some spacing between the text fields
              // Text field for Current Password
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Current Password",
                ),
                onChanged: (value) {
                  currentPassword = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add code to cancel and close the popup.
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Pass the values to the mobileUpdateApiCall function
                mobileUpdateApiCall(currentPhoneNumber, newPhoneNumber, currentPassword);
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(Duration(seconds: 3), () {
          userDetailGet();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.verification, style: boldTextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () async {
                  appStore.setLoading(true);
                  await userDetailGet();
                },
                icon: Icon(Icons.refresh)),
            IconButton(
                onPressed: () async {
                  await showConfirmDialogCustom(
                    context,
                    primaryColor: colorPrimary,
                    title: language.logoutConfirmationMsg,
                    positiveText: language.yes,
                    negativeText: language.no,
                    onAccept: (c) {
                      logout(context, isVerification: true);
                    },
                  );
                },
                icon: Icon(Icons.logout)),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                InkWell(
                  onTap: () async {
                    if (getBoolAsync(OTP_VERIFIED).validate()) {
                      toast(language.phoneNumberAlreadyVerified);
                    } else {
                      appStore.setLoading(true);
                      // print(getStringAsync(USER_CONTACT_NUMBER));
                      // log('-----${getStringAsync(USER_CONTACT_NUMBER)}');
                      sendOtp(context, phoneNumber: getStringAsync(USER_CONTACT_NUMBER), onUpdate: (verificationId) async {
                        await showInDialog(context,
                            builder: (context) => OTPDialog(
                                phoneNumber: getStringAsync(USER_CONTACT_NUMBER),
                                onUpdate: () {
                                  updateUserStatus({"id": getIntAsync(USER_ID), "otp_verify_at": DateTime.now().toString()}).then((value) {
                                    setValue(OTP_VERIFIED, true);
                                    if (getStringAsync(USER_TYPE) == CLIENT) {
                                      DashboardScreen().launch(getContext, isNewTask: true);
                                    } else {
                                      DeliveryDashBoard().launch(getContext, isNewTask: true);
                                    }
                                  });
                                },
                                verificationId: verificationId),
                            barrierDismissible: false);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/phone.png', height: 24, width: 24, fit: BoxFit.cover),
                        SizedBox(width: 8),
                        Expanded(child: Text(language.verifyPhoneNumber, style: primaryTextStyle())),
                        SizedBox(width: 16),
                        getBoolAsync(OTP_VERIFIED).validate() ? Icon(Icons.verified, color: Colors.green) : Icon(Icons.navigate_next),
                      ],
                    ),
                  ),
                ),

                // "Wrong Phone Number?"
                ElevatedButton(
                  onPressed: () {
                    _showPhoneNumberChangePopup();
                  },
                  child: Text("Wrong Phone Number?\nClick here to change", textAlign: TextAlign.center),
                ),
              ],
            ),
            Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
          ],
        ),
      ),
    );
  }
}
