import 'package:flashzone_web/src/model/op_results.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  static const String razorpayKey = "rzp_live_HBI3NVNg9u7FHK";
  static const String razorpayKeySecret = "wxR593R6j9UM9ldiNH36UV67";

  var options = {
    'key': razorpayKey,
    'amount': 0,
    'currency': 'INR',
    'name': 'Super Real',
    'description': 'Balance Topup',
    'prefill': {
      'contact': '+919625068595',
      'email': 'contact@superrealapp.com'
    },
    'external': {
      'wallets': ['paytm', 'gpay', 'upi']
    }
  };

  late Razorpay _razorpay;

  Future<void> initService() async {
    _razorpay = Razorpay();
  }

  void attachCallbacks(Function (PaymentSuccessResponse) onPaymentSuccess, Function (PaymentFailureResponse) onPaymentFailure, Function (ExternalWalletResponse) onChangePaymentMethod) async {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onChangePaymentMethod);
  }

  

  void initiatePayment(double amount, String currency) {
    options['amount'] = amount.round() * 100;
    options['currency'] = currency;
    try {
      _razorpay.open(options);
    } catch (e) {
      String msg = "While initiating Razorpay payment: ${e.toString()}";
      print(msg);
      throw FZResult(code: SuccessCode.failed, message: msg);
    }
  }

  void onDispose() {
    _razorpay.clear();
  }

}