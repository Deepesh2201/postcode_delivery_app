import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaystackWebView extends StatefulWidget {
  final String initialUrl;
  final Function(String)? onUrlChanged;

  PaystackWebView({required this.initialUrl, this.onUrlChanged, required String paystackUrl, required String reference});

  @override
  _PaystackWebViewState createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {

  /// Web view added for paystack
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: 'https://checkout.paystack.com/7zu1ot06d0qn9h6',
        javascriptMode: JavascriptMode.unrestricted,
        userAgent: 'Flutter;Webview',
        navigationDelegate: (navigation){
          //Listen for callback URL
          if(navigation.url == "https://hello.pstk.xyz/callback"){
            // verifyTransaction(reference);
            Navigator.of(context).pop(); //close webview
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
