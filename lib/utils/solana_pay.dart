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
    Map<String, dynamic> meta = uri.queryParametersAll;

    return TransactionSolanaPay(
      recipient: recipient,
      references: meta['reference'] ?? [],
      amount: meta["amount"] != null ? double.parse(meta['amount'][0]) : null,
      label: meta["label"] != null ? meta["label"][0] : null,
      message: meta["message"] != null ? meta["message"][0] : null,
      memo: meta["memo"] != null ? meta["memo"][0] : null,
      splToken: meta["spl-token"] != null ? meta["spl-token"][0] : null,
    );
  }

  /// Serialized a Solana transaction into a uri
  String toUri() {
    String uri = 'solana:$recipient';
    bool addQueryDelimeter = true;

    if (amount != null) {
      uri += "?amount=${amount.toString()}";
      addQueryDelimeter = false;
    }
    for (final ref in references) {
      uri += "${addQueryDelimeter ? "?" : "&"}reference=$ref";
      addQueryDelimeter = false;
    }
    if (label != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}label=$label";
      addQueryDelimeter = false;
    }
    if (message != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}message=$message";
      addQueryDelimeter = false;
    }
    if (memo != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}memo=$memo";
      addQueryDelimeter = false;
    }
    if (splToken != null) {
      uri += "${addQueryDelimeter ? "?" : "&"}spl-token=$splToken";
      addQueryDelimeter = false;
    }

    return uri;
  }
}
