import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onWallet;
  bool _isInitialized = false;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    if (_isInitialized) {
      dispose();
    }

    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onWallet = onWallet;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _isInitialized = true;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) {
      onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onWallet != null) {
      onWallet!(response);
    }
  }

  Future<void> startPayment({
    required double amount,
    required String name,
    required String email,
    required String contact,
    String? description,
  }) async {
    if (!_isInitialized) {
      throw Exception('RazorpayService not initialized');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final keyId =
          prefs.getString('razorpay_key_id') ?? 'rzp_live_rc8gMyakUv9g8d';

      final options = {
        'key': keyId,
        'amount': (amount * 100).toInt(), 
        'name': 'Meatzo',
        'description': description ?? 'Payment for order',
        'prefill': {
          'contact': contact,
          'email': email,
          'name': name,
        },
        'external': {
          'wallets': ['paytm', 'gpay']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      if (onFailure != null) {
        onFailure!(PaymentFailureResponse(
          0, 
          'Failed to start payment: $e', 
          null, 
        ));
      }
    }
  }

  void dispose() {
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
    }
  }
}
