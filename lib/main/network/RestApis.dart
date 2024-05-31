import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../../main/models/ChangePasswordResponse.dart';
import '../../main/models/CityDetailModel.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/CountryDetailModel.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/DeliveryDocumentListModel.dart';
import '../../main/models/DocumentListModel.dart';
import '../../main/models/LDBaseResponse.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/NotificationModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/ParcelTypeListModel.dart';
import '../../main/models/PaymentGatewayListModel.dart';
import '../../main/screens/LoginScreen.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../models/AppSettingModel.dart';
import '../models/AutoCompletePlacesListModel.dart';
import '../models/InvoiceSettingModel.dart';
import '../models/OrderDetailModel.dart';
import '../models/PlaceIdDetailModel.dart';
import '../models/UserProfileDetailModel.dart';
import '../models/VehicleModel.dart';
import '../models/WalletListModel.dart';
import '../models/WithDrawListModel.dart';
import 'NetworkUtils.dart';

//region Auth
Future<LoginResponse> signUpApi(Map request) async {
  Response response = await buildHttpResponse('register', request: request, method: HttpMethod.POST);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    // await setValue(USER_ID, loginResponse.data!.id.validate());
    // await setValue(NAME, loginResponse.data!.name.validate());
    // await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    // await setValue(USER_TOKEN, loginResponse.data!.fcmToken.validate());
    // await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
    // await setValue(USER_PROFILE_PHOTO, loginResponse.data!.profileImage.validate());
    // await setValue(USER_TYPE, loginResponse.data!.userType.validate());
    // await setValue(USER_NAME, loginResponse.data!.username.validate());
    // await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
    // await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
    // await setValue(CITY_ID, loginResponse.data!.cityId.validate());
    // await userService.getUser(email: loginResponse.data!.email.validate()).then((value) async {
    //   await setValue(UID, value.uid.validate());
    // }).catchError((e) {
    //   log(e.toString());
    //   if (e.toString() == "User not found") {
    //     toast('user Not Found');
    //   }
    // });
    // await setValue(IS_VERIFIED_DELIVERY_MAN, loginResponse.data!.isVerifiedDeliveryMan == 1);
    //
    // await appStore.setUserEmail(loginResponse.data!.email.validate());
    // await appStore.setLogin(true);
    //
    // await setValue(USER_PASSWORD, request['password']);

    return loginResponse;
  }).catchError((e) {
    log(e.toString());
    throw e.toString();
  });
}

Future<ApiResponse<LoginResponse>> updateMobileApi(Map request) async {
  try {
    Response response = await buildHttpResponse('update-mobile', request: request, method: HttpMethod.POST);

    if (!response.statusCode.isSuccessful()) {
      if (response.body.isJson()) {
        var json = jsonDecode(response.body);

        // if (json.containsKey('code') && json['code'].toString().contains('invalid_password')) {
        //   throw 'invalid_password';
        // }
      }
    }

    var loginResponse = await handleResponse(response).then((json) async {
      var loginResponse = LoginResponse.fromJson(json);
      // Your logic to handle the response data here

      return loginResponse;
    }).catchError((e) {
      log(e.toString());
      throw e.toString();
    });

    return ApiResponse<LoginResponse>(status: true, data: loginResponse);
  } catch (e) {
    log(e.toString());
    return ApiResponse<LoginResponse>(status: false, error: e.toString());
  }
}

class ApiResponse<T> {
  final bool status;
  final T? data;
  final String? error;

  ApiResponse({required this.status, this.data, this.error});
}

Future<LoginResponse> logInApi(Map request, {bool isSocialLogin = false}) async {
  Response response = await buildHttpResponse('login', request: request, method: HttpMethod.POST);
  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') && json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    /*if (request['login_type'] == LoginTypeGoogle) {
      await setValue(USER_PHOTO_URL, request['image']);
    } else {
      await setValue(USER_PHOTO_URL, loginResponse.userData!.profile_image.validate());
    }

    await setValue(GENDER, loginResponse.userData!.gender.validate());
    await setValue(NAME, loginResponse.userData!.name.validate());
    await setValue(BIO, loginResponse.userData!.bio.validate());
    await setValue(DOB, loginResponse.userData!.dob.validate());
*/

    await setValue(USER_ID, loginResponse.data!.id.validate());
    await setValue(NAME, loginResponse.data!.name.validate());
    await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    await setValue(USER_TOKEN, loginResponse.data!.apiToken.validate());
    await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
    await setValue(USER_TYPE, loginResponse.data!.userType.validate());
    await setValue(USER_NAME, loginResponse.data!.username.validate());
    await setValue(STATUS, loginResponse.data!.status.validate());
    await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
    await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
    await setValue(CITY_ID, loginResponse.data!.cityId.validate());
    await setValue(OTP_VERIFIED, loginResponse.data!.otpVerifyAt != null);
    appStore.setUserProfile(loginResponse.data!.profileImage.validate());
    await userService.getUser(email: loginResponse.data!.email.validate()).then((value) async {
      log(value);
      await setValue(UID, value.uid.validate());
    }).catchError((e) {
      log(e.toString());
      if (e.toString() == "User not found") {
        toast('user Not Found');
      }
    });
    await setValue(IS_VERIFIED_DELIVERY_MAN, loginResponse.data!.isVerifiedDeliveryMan == 1);
    /* await appStore.setUserName(loginResponse.userData!.username.validate());
    await appStore.setRole(loginResponse.userData!.user_type.validate());
    await appStore.setToken(loginResponse.userData!.api_token.validate());
    await appStore.setUserID(loginResponse.userData!.id.validate());*/
    await appStore.setUserEmail(loginResponse.data!.email.validate());
    if (getIntAsync(STATUS) == 1) {
      await appStore.setLogin(true);
    } else {
      await appStore.setLogin(false);
    }

    await setValue(USER_PASSWORD, request['password']);

    return loginResponse;
  }).catchError((e) {
    throw e.toString();
  });
}

Future<void> logout(BuildContext context, {bool isFromLogin = false, bool isDeleteAccount = false, bool isVerification = false}) async {
  clearData() async {
    await removeKey(USER_ID);
    await removeKey(NAME);
    await removeKey(USER_TOKEN);
    await removeKey(USER_CONTACT_NUMBER);
    await removeKey(USER_PROFILE_PHOTO);
    await removeKey(USER_TYPE);
    await removeKey(USER_NAME);
    await removeKey(USER_ADDRESS);
    await removeKey(STATUS);
    await removeKey(COUNTRY_ID);
    await removeKey(COUNTRY_DATA);
    await removeKey(CITY_ID);
    await removeKey(CITY_DATA);
    await removeKey(FILTER_DATA);
    await removeKey(IS_VERIFIED_DELIVERY_MAN);
    await removeKey(OTP_VERIFIED);
    if (!getBoolAsync(REMEMBER_ME)) {
      await removeKey(USER_EMAIL);
      await removeKey(USER_PASSWORD);
    }

    await appStore.setLogin(false);
    appStore.setFiltering(false);
    appStore.setUserProfile('');
    if (isFromLogin) {
      toast(language.credentialNotMatch);
    } else {
      LoginScreen().launch(context, isNewTask: true);
    }
  }

  if (getStringAsync(USER_TYPE) == DELIVERY_MAN && !isVerification && positionStream != null) {
    positionStream!.cancel();
  }
  if (isDeleteAccount) {
    clearData();
  } else {
    await logoutApi().then((value) async {
      clearData();
    }).catchError((e) {
      appStore.setLoading(false);
      throw e.toString();
    });
  }
}

Future<ChangePasswordResponseModel> changePassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(await buildHttpResponse('change-password', request: req, method: HttpMethod.POST)));
}

Future<ChangePasswordResponseModel> forgotPassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(await buildHttpResponse('forget-password', request: req, method: HttpMethod.POST)));
}

Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  multiPartRequest.headers.addAll(buildHeaderTokens());

  await multiPartRequest.send().then((res) {
    log(res.statusCode);
    res.stream.transform(utf8.decoder).listen((value) {
      log(value);
      onSuccess?.call(jsonDecode(value));
    });
  }).catchError((error) {
    onError?.call(error.toString());
  });
}

/// Profile Update
Future updateProfile({String? userName, String? name, String? userEmail, String? address, String? contactNumber, File? file}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
  multiPartRequest.fields['username'] = userName.validate();
  multiPartRequest.fields['email'] = userEmail ?? appStore.userEmail;
  multiPartRequest.fields['name'] = name.validate();
  multiPartRequest.fields['contact_number'] = contactNumber.validate();
  multiPartRequest.fields['address'] = address.validate();

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      LoginResponse res = LoginResponse.fromJson(data);
      if (res.data != null) {
        await setValue(NAME, res.data!.name.validate());
        await setValue(USER_NAME, res.data!.username.validate());
        await setValue(USER_ADDRESS, res.data!.address.validate());
        await setValue(USER_CONTACT_NUMBER, res.data!.contactNumber.validate());
        await appStore.setUserEmail(res.data!.email.validate());
        appStore.setUserProfile(res.data!.profileImage.validate());
      }
      toast(res.message.toString());
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<UserData> getUserDetail(int id) async {
  return UserData.fromJson(await handleResponse(await buildHttpResponse('user-detail?id=$id', method: HttpMethod.GET)).then((value) => value['data']));
}

/// Create Order Api
Future<LDBaseResponse> createOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-save', request: request, method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteOrder(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-delete/$id', method: HttpMethod.POST)));
}

Future<OrderDetailModel> getOrderDetails(int id) async {
  return OrderDetailModel.fromJson(await handleResponse(await buildHttpResponse('order-detail?id=$id', method: HttpMethod.GET)));
}

/// ParcelType Api
Future<ParcelTypeListModel> getParcelTypeList({int? page}) async {
  return ParcelTypeListModel.fromJson(await handleResponse(await buildHttpResponse('staticdata-list?type=parcel_type&per_page=-1', method: HttpMethod.GET)));
}

Future<CountryListModel> getCountryList() async {
  return CountryListModel.fromJson(await handleResponse(await buildHttpResponse('country-list?per_page=-1', method: HttpMethod.GET)));
}

Future<CountryDetailModel> getCountryDetail(int id) async {
  return CountryDetailModel.fromJson(await handleResponse(await buildHttpResponse('country-detail?id=$id', method: HttpMethod.GET)));
}

Future<CityListModel> getCityList({required int countryId, String? name}) async {
  return CityListModel.fromJson(await handleResponse(await buildHttpResponse(name != null ? 'city-list?country_id=$countryId&name=$name&per_page=-1' : 'city-list?country_id=$countryId&per_page=-1', method: HttpMethod.GET)));
}

Future<CityDetailModel> getCityDetail(int id) async {
  return CityDetailModel.fromJson(await handleResponse(await buildHttpResponse('city-detail?id=$id', method: HttpMethod.GET)));
}

///Vehicle
Future<VehicleListModel> getVehicleList({String? type, int? perPage, int? page, int? cityID, bool isDeleted = false, int? totalItem, int? totalPage = 10}) async {
  if (cityID != null) {
    return VehicleListModel.fromJson(await handleResponse(await buildHttpResponse('vehicle-list?city_id=$cityID&per_page=-1&status=1', method: HttpMethod.GET)));
  } else {
    return VehicleListModel.fromJson(await handleResponse(await buildHttpResponse('vehicle-list?per_page=-1', method: HttpMethod.GET)));
  }
}

/// get OrderList
Future<OrderListModel> getOrderList({required int page, String? orderStatus, String? fromDate, String? toDate,String? excludeStatus}) async {
  String endPoint = 'order-list?client_id=${getIntAsync(USER_ID)}&city_id=${getIntAsync(CITY_ID)}&page=$page';

  if (orderStatus.validate().isNotEmpty) {
    endPoint += '&status=$orderStatus';
  }

  if(excludeStatus.validate().isNotEmpty){
    endPoint += '&exclude_status=$excludeStatus';
  }

  if (fromDate.validate().isNotEmpty && toDate.validate().isNotEmpty) {
    endPoint += '&from_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate.validate()))}&to_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(toDate.validate()))}';
  }

  return OrderListModel.fromJson(await handleResponse(await buildHttpResponse(endPoint, method: HttpMethod.GET)));
}

/// get deliveryBoy orderList
Future<OrderListModel> getDeliveryBoyOrderList({required int page, required int deliveryBoyID, required int countryId, required int cityId, required String orderStatus}) async {
  return OrderListModel.fromJson(await handleResponse(await buildHttpResponse('order-list?delivery_man_id=$deliveryBoyID&page=$page&city_id=$cityId&country_id=$countryId&status=$orderStatus', method: HttpMethod.GET)));
}

/// update status
Future updateStatus({String? orderStatus, int? orderId}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('order-update/$orderId');
  multiPartRequest.fields['status'] = orderStatus.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

/// update order
Future updateOrder({
  String? pickupDatetime,
  String? deliveryDatetime,
  String? clientName,
  String? deliveryman,
  String? orderStatus,
  String? reason,
  int? orderId,
  File? picUpSignature,
  File? deliverySignature,
}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('order-update/$orderId');
  if (pickupDatetime != null) multiPartRequest.fields['pickup_datetime'] = pickupDatetime;
  if (deliveryDatetime != null) multiPartRequest.fields['delivery_datetime'] = deliveryDatetime;
  if (clientName != null) multiPartRequest.fields['pickup_confirm_by_client'] = clientName;
  if (deliveryman != null) multiPartRequest.fields['pickup_confirm_by_delivery_man'] = deliveryman;
  if (reason != null) multiPartRequest.fields['reason'] = reason;
  if (orderStatus != null) multiPartRequest.fields['status'] = orderStatus;

  if (picUpSignature != null) multiPartRequest.files.add(await MultipartFile.fromPath('pickup_time_signature', picUpSignature.path));
  if (deliverySignature != null) multiPartRequest.files.add(await MultipartFile.fromPath('delivery_time_signature', deliverySignature.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<PaymentGatewayListModel> getPaymentGatewayList() async {
  return PaymentGatewayListModel.fromJson(await handleResponse(await buildHttpResponse('paymentgateway-list?status=1', method: HttpMethod.GET)));
}

Future<LDBaseResponse> savePayment(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('payment-save', request: request, method: HttpMethod.POST)));
}

Future<WithDrawListModel> getWithDrawList({int? page}) async {
  return WithDrawListModel.fromJson(await handleResponse(await buildHttpResponse('withdrawrequest-list?page=$page', method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWithDrawRequest(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('save-withdrawrequest', method: HttpMethod.POST, request: request)));
}

/// Get Notification List
Future<NotificationListModel> getNotification({required int page}) async {
  return NotificationListModel.fromJson(await handleResponse(await buildHttpResponse('notification-list?page=$page', method: HttpMethod.POST)));
}

/// Get Document List
Future<DocumentListModel> getDocumentList({int? page}) async {
  return DocumentListModel.fromJson(await handleResponse(await buildHttpResponse('document-list?status=1&per_page=-1', method: HttpMethod.GET)));
}

/// Get Delivery Document List
Future<DeliveryDocumentListModel> getDeliveryPersonDocumentList({int? page}) async {
  return DeliveryDocumentListModel.fromJson(await handleResponse(await buildHttpResponse('delivery-man-document-list?per_page=-1', method: HttpMethod.GET)));
}

Future<LDBaseResponse> deleteDeliveryDoc(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('delivery-man-document-delete/$id', method: HttpMethod.POST)));
}

/// App Setting
Future<AppSettingModel> getAppSetting() async {
  return AppSettingModel.fromJson(await handleResponse(await buildHttpResponse('get-appsetting', method: HttpMethod.GET)));
}

/// Cancel AutoAssign order
Future<LDBaseResponse> cancelAutoAssignOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-auto-assign', request: request, method: HttpMethod.POST)));
}

Future<AutoCompletePlacesListModel> placeAutoCompleteApi({String searchText = '', String countryCode = "in", String language = 'en'}) async {
  return AutoCompletePlacesListModel.fromJson(await handleResponse(await buildHttpResponse('place-autocomplete-api?country_code=$countryCode&language=$language&search_text=$searchText', method: HttpMethod.GET)));
}

Future<PlaceIdDetailModel> getPlaceDetail({String placeId = ''}) async {
  return PlaceIdDetailModel.fromJson(await handleResponse(await buildHttpResponse('place-detail-api?placeid=$placeId', method: HttpMethod.GET)));
}

Future<LDBaseResponse> deleteUser(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('delete-user', request: req, method: HttpMethod.POST)));
}

Future<LDBaseResponse> userAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('user-action', request: request, method: HttpMethod.POST)));
}

Future<WalletListModel> getWalletList({required int page}) async {
  return WalletListModel.fromJson(await handleResponse(await buildHttpResponse('wallet-list?page=$page', method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWallet(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('save-wallet', method: HttpMethod.POST, request: request)));
}

/// Update Bank Info
Future updateBankDetail({String? bankName, String? bankCode, String? accountName, String? accountNumber}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
  multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL).validate();
  multiPartRequest.fields['contact_number'] = getStringAsync(USER_CONTACT_NUMBER).validate();
  multiPartRequest.fields['username'] = getStringAsync(USER_NAME).validate();
  multiPartRequest.fields['user_bank_account[bank_name]'] = bankName.validate();
  multiPartRequest.fields['user_bank_account[bank_code]'] = bankCode.validate();
  multiPartRequest.fields['user_bank_account[account_holder_name]'] = accountName.validate();
  multiPartRequest.fields['user_bank_account[account_number]'] = accountNumber.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> logoutApi() async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('logout?clear=player_id', method: HttpMethod.GET)));
}

Future<EarningList> getPaymentList({required int page}) async {
  return EarningList.fromJson(await handleResponse(await buildHttpResponse('payment-list?page=$page&delivery_man_id=${getIntAsync(USER_ID)}&type=earning', method: HttpMethod.GET)));
}

Future<UserProfileDetailModel> getUserProfile() async {
  return UserProfileDetailModel.fromJson(await handleResponse(await buildHttpResponse('user-profile-detail?id=${getIntAsync(USER_ID)}', method: HttpMethod.GET)));
}

Future<InvoiceSettingModel> getInvoiceSetting() async {
  return InvoiceSettingModel.fromJson(await handleResponse(await buildHttpResponse('get-setting', method: HttpMethod.GET)));
}

Future<LDBaseResponse> updateUserStatus(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('update-user-status', request: req, method: HttpMethod.POST)));
}
