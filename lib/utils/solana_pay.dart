class TransactionSolanaPay {
  String recipient;
  double? amount;
  List<String> references = [];
  String? label;
  String? message;
  String? memo;
  String? splToken;
  TransactionSolanaPay({
    required this.recipient,
    this.references = const [],
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
    dynamic meta = uri.queryParametersAll;

    return TransactionSolanaPay(
      recipient: recipient,
      references: meta['reference'],
      amount: double.parse(meta['amount'][0]),
      label: meta['label'][0],
      message: meta['message'][0],
      memo: meta['memo'][0],
      splToken: meta['spl-token'][0],
    );
  }

  /// Serialized a Solana transaction into a uri
  String toUri() {
    String uri = 'solana:$recipient?amount=${amount.toString()}';

    for (final ref in references) {
      uri += "&reference=$ref";
    }
    if (label != null) uri += "&label=$label";
    if (message != null) uri += "&message=$message";
    if (memo != null) uri += "&memo=$memo";
    if (splToken != null) uri += "&spl-token=$splToken";

    return uri;
  }
}
