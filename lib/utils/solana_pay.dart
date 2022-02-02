// solana:
// mvines9iiHiQTysrwkJjGf2gb9Ex9jXJX8ns3qwf2kN?
// amount=0.01&
// reference=82ZJ7nbGpixjeDCmEhUcmwXYfvurzAgGdtSMuHnUgyny&
// label=Michael&
// message=Thanks%20for%20all%20the%20fish&
// memo=OrderId5678

class TransactionSolanaPay {
  String recipient;
  double amount;
  String? reference;
  String? label;
  String? message;
  String? memo;
  String? splToken;
  TransactionSolanaPay(
    this.recipient,
    this.reference,
    this.amount,
    this.label,
    this.message,
    this.memo,
    this.splToken,
  );
}

/// Deserialize a Solana Pay uri
TransactionSolanaPay parseUri(String uriSolanaPay) {
  Uri uri = Uri.parse(uriSolanaPay);
  String recipient = uri.path;
  dynamic meta = uri.queryParameters;

  return new TransactionSolanaPay(
    recipient,
    meta['reference'],
    double.parse(meta['amount']),
    meta['label'],
    meta['message'],
    meta['memo'],
    meta['spl-token'],
  );
}
