import 'package:khqr_sdk/khqr_sdk.dart';

class BakongQrData {
  const BakongQrData({
    required this.qr,
    required this.md5Hash,
  });

  final String qr;
  final String md5Hash;
}

class BakongQrResult {
  const BakongQrResult({this.data, this.errorMessage});

  final BakongQrData? data;
  final String? errorMessage;

  bool get isSuccess => data != null;
}

class BakongMerchantConfig {
  const BakongMerchantConfig({
    required this.bakongAccountId,
    required this.merchantName,
    this.merchantCity = 'Phnom Penh',
    this.currency = KhqrCurrency.usd,
    this.qrExpiry = const Duration(minutes: 5),
  });

  final String bakongAccountId;
  final String merchantName;
  final String merchantCity;
  final KhqrCurrency currency;
  final Duration qrExpiry;
}

class BakongPaymentService {
  BakongPaymentService._();

  static const BakongMerchantConfig config = BakongMerchantConfig(
    bakongAccountId: 'seavminh_yuddho@bkrt',
    merchantName: 'Yuddho Seavminh Co., Ltd.',
    merchantCity: 'Phnom Penh',
    currency: KhqrCurrency.usd,
    qrExpiry: Duration(minutes: 1),
  );

  static String generateBillNumber() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static BakongQrResult generateQr({
    required double amount,
    required String billNumber,
  }) {
    final expirationTimestamp = DateTime.now()
        .add(config.qrExpiry)
        .millisecondsSinceEpoch;

    final individualInfo = IndividualInfo(
      bakongAccountId: config.bakongAccountId,
      merchantName: config.merchantName,
      merchantCity: config.merchantCity,
      currency: config.currency,
      amount: amount,
      expirationTimestamp: expirationTimestamp,
    );

    final response = KhqrSdk.generateIndividual(individualInfo);
    final data = response.data;

    String? qr;
    String? md5Hash;
    try {
      final rawQr = data?.qr;
      final rawMd5 = data?.md5Hash;
      if (rawQr is String) {
        qr = rawQr;
      }
      if (rawMd5 is String) {
        md5Hash = rawMd5;
      }
    } catch (_) {
      qr = null;
      md5Hash = null;
    }

    if (response.isSuccess && qr != null && md5Hash != null) {
      return BakongQrResult(data: BakongQrData(qr: qr, md5Hash: md5Hash));
    }

    String? message;
    try {
      final rawMessage = response.status.message;
      if (rawMessage is String) {
        message = rawMessage;
      }
    } catch (_) {
      message = null;
    }
    return BakongQrResult(
      errorMessage: message ?? 'Unable to generate KHQR.',
    );
  }
}
