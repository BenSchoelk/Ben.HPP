import 'package:flutterquiz/features/wallet/walletException.dart';
import 'package:flutterquiz/features/wallet/walletRemoteDataSource.dart';

class WalletRepository {
  static final WalletRepository _walletRepository =
      WalletRepository._internal();

  late WalletRemoteDataSource _walletRemoteDataSource;

  factory WalletRepository() {
    _walletRepository._walletRemoteDataSource = WalletRemoteDataSource();
    return _walletRepository;
  }

  WalletRepository._internal();

  Future<void> makePaymentRequest({
    required String userId,
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      await _walletRemoteDataSource.makePaymentRequest(
          userId: userId,
          paymentType: paymentType,
          paymentAddress: paymentAddress,
          paymentAmount: paymentAmount,
          coinUsed: coinUsed,
          details: details);
    } catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    }
  }
}
