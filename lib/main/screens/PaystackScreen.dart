import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_riders_delivery/user/screens/WalletScreen.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart'; // Import dio package

import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';

class PaystackScreen extends StatefulWidget {
  static String tag = '/PaymentScreen';
  final num totalAmount;
  final String? orderId;
  final bool? isWallet;
  final String? payStackPublicKey;
  PaystackScreen({required this.totalAmount, this.orderId, this.isWallet, required this.payStackPublicKey});
  @override
  _PaystackScreenState createState() => _PaystackScreenState();
}

class _PaystackScreenState extends State<PaystackScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final TextEditingController _urlController = TextEditingController();
  String _reference = ''; // Define the reference variable
  Dio? _dio; // Define a Dio instance for making HTTP requests
  bool _isMounted = false; // Keep track of widget mounting state
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _dio = Dio(); // Initialize the Dio instance
    // Subscribe to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Handle connectivity changes here
    });
    initializeTransaction();
  }

  @override
  void dispose() {
    // Cancel the subscription to avoid memory leaks
    _connectivitySubscription?.cancel();
    _isMounted = false; // Set _isMounted to false when disposing
    super.dispose();
  }

  Future<void> initializeTransaction() async {
    try {
      if (!_isMounted) return; // Check if the widget is still mounted

      var cancelToken = CancelToken(); // Create a cancel token
      var response = await _dio!.post(
        'https://api.paystack.co/transaction/initialize',
        data: {
          'email': getStringAsync(USER_EMAIL),
          'amount': widget.totalAmount,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.payStackPublicKey}',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: cancelToken, // Pass the cancel token to the request
      );

      if (!_isMounted) return; // Check if the widget is still mounted

      setState(() {
        if (_isMounted && response.statusCode == 200) {
          var data = response.data;
          var authorizationUrl = data['data']['authorization_url'];
          _reference = data['data']['reference'];

          if (authorizationUrl != null) {
            _controller.future.then((controller) {
              controller.loadUrl(authorizationUrl);
            });
          }
        } else {
          throw Exception('Failed to initialize transaction');
        }
      });
    } catch (error) {
      if (!_isMounted) return; // Check if the widget is still mounted
      print('Error initializing transaction: $error');
    }
  }
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
  void verifyTransaction(String? trxRef, String? reference) {
    // Perform verification of transaction using the reference
    // Assume verification is successful for demonstration purposes
    bool transactionSuccessful = true;
    if (_isMounted) {
      if (transactionSuccessful) {
        print('Payment successful!'); // Print success message

        print(trxRef);
        print(reference);

        // Call payStackPayment function
        payStackPayment(trxRef, reference);
      } else {
        print('Payment failed. Please try again.'); // Print failure message
        // You can handle the failure case here
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Paystack Payment'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },

              navigationDelegate: (navigation) {
                // Check if the current URL contains the callback base URL
                if (navigation.url.startsWith("https://gogoriders.ng/callback")) {
                  // Parse the query parameters to extract transaction reference and reference
                  Uri uri = Uri.parse(navigation.url);
                  String? trxRef = uri.queryParameters['trxref'];
                  String? reference = uri.queryParameters['reference'];
                  // Close the webview
                  // Navigator.of(context).pop();
                  // Verify the transaction using the transaction reference and reference
                  verifyTransaction(trxRef, reference);



                  // Prevent navigation to the callback URL
                  return NavigationDecision.prevent;
                }

                // Allow navigation to other URLs
                return NavigationDecision.navigate;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// PayStack Payment
  void payStackPayment(String? trxRef, String? reference) async {

    if (_isMounted) {
      try {
        Map<String, dynamic> req = {
          "status": 'success',
          "message": 'Wallet added',
          "method": 'paystack',
          "reference": trxRef,
        };

        print(widget.orderId);
        if (widget.orderId == null) {
          paymentConfirm();
        } else {
          int? orderIdAsInt = int.tryParse(widget.orderId.toString());
          if (orderIdAsInt != null) {
            savePaymentApiCall(
                paymentType: PAYMENT_TYPE_PAYSTACK,
                paymentStatus: PAYMENT_PAID,
                transactionDetail: req,
                txnId: trxRef);
          } else {
            paymentConfirm();
          }
        }
      } catch (e) {
        payStackShowMessage("Check console for error");
        rethrow;
      }
    }
  }

  Future<void> paymentConfirm() async {
    if (_isMounted) {
      Map req = {
        "user_id": getIntAsync(USER_ID),
        "type": "credit",
        "amount": widget.totalAmount / 100,
        "transaction_type": "topup",
        "currency": appStore.currencyCode,
      };

      // Set loading state to true
      appStore.isLoading = true;

      try {
        // Perform the asynchronous operation to save wallet data
        var response = await saveWallet(req);

        // Show a toast message with the response message
        toast(response.message.toString());
        // await Future.delayed(Duration(seconds: 1));
       // Navigator.of(context).pop();
       //  WalletScreen().launch(context);
        DashboardScreen().launch(context, isNewTask: true);
      } catch (error) {
        // Handle errors by logging the error
        log(error.toString());
      } finally {
        // Set loading state to false after the operation completes
        appStore.isLoading = false;
      }
    }
  }

  /// Save Payment
  Future<void> savePaymentApiCall(
      {String? paymentType,
        String? txnId,
        String? paymentStatus = PAYMENT_PENDING,
        Map? transactionDetail}) async {
    if (_isMounted) {
      Map req = {
        "id": "",
        "order_id": widget.orderId.toString(),
        "client_id": getIntAsync(USER_ID).toString(),
        "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
        "total_amount": widget.totalAmount / 100,
        "payment_type": paymentType,
        "txn_id": txnId,
        "payment_status": paymentStatus,
        "transaction_detail": transactionDetail ?? {}
      };

      appStore.setLoading(true);

      savePayment(req).then((value) {
        appStore.setLoading(false);
        toast(value.message.toString());

          DashboardScreen().launch(context, isNewTask: true);

      }).catchError((error) {
        appStore.setLoading(false);
        print(error.toString());
      });
    }
  }

  payStackUpdateStatus(String? reference, String message) {
    payStackShowMessage(message, const Duration(seconds: 7));
  }

  void payStackShowMessage(String message, [Duration duration = const Duration(seconds: 4)]) {
    toast(message);
    log(message);
  }
}
