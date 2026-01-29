import 'package:flashzone_web/src/model/op_results.dart';
import 'package:razorpay_web/razorpay_web.dart';
//import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  static const String razorpayKey = "rzp_test_RzrMRVQm9hCnY2";
  static const String razorpayKeySecret = "yPSXmM949JMGqY4quP5jEaSu";

  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';
  static const EVENT_EXTERNAL_WALLET = 'payment.external_wallet';

  var options = {
    'key': razorpayKey,
    'amount': 0,
    'currency': 'INR',
    'name': 'Surabhi Mishra',
    'description': 'Service Payment',
    'prefill': {
      'contact': '+919821754624',
      'email': 'ed@flashzone.com'
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
    _razorpay.on(EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    _razorpay.on(EVENT_PAYMENT_ERROR, onPaymentFailure);
    _razorpay.on(EVENT_EXTERNAL_WALLET, onChangePaymentMethod);
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