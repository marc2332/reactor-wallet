class TransactionSolanaPay {
  String recipient;
  double? amount;
  String? reference;
  String? label;
  String? message;
  String? memo;
  String? splToken;
  TransactionSolanaPay({
    required this.recipient,
    this.reference,
    this.amount,
    this.label,
    this.message,
    this.memo,
    this.splToken,
  });

  /// Deserialize a Solana Pay uri
  static TransactionSolanaPay parseUri(String uriSolanaPay) {
    Uri uri = Uri.parse(uriSolanaPay);
    String recipient = uri.path;
    dynamic meta = uri.queryParameters;

    return TransactionSolanaPay(
      recipient: recipient,
      reference: meta['reference'],
      amount: double.parse(meta['amount']),
      label: meta['label'],
      message: meta['message'],
      memo: meta['memo'],
      splToken: meta['spl-token'],
    );
  }

  /// Serialized a Solana transaction into a uri
  String toUri() {
    String uri = 'solana:$recipient?amount=${amount.toString()}';

    if (label != null) uri += "&label=$label";
    if (message != null) uri += "&message=$message";
    if (memo != null) uri += "&memo=$memo";
    if (splToken != null) uri += "&spl-token=$splToken";

    return uri;
  }
}
