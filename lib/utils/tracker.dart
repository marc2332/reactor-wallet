import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as Http;
import 'dart:async';

/*
 * Types of accounts
 */
enum AccountType {
  Wallet,
  Client,
}

const system_program_id = "11111111111111111111111111111111";
const token_program_id = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA";

/*
 * Token Tracker
 */
class Tracker {
  String name;
  String programMint;
  double usdValue = 0;
  String symbol;

  Tracker(this.name, this.programMint, this.symbol);
}

class TokenInfo {
  late String name = "Unknown";
  late String logoUrl = "";
  late String symbol = "Unknown";
  late String mintAddress;

  TokenInfo();
  TokenInfo.withInfo(this.mintAddress, this.name, this.logoUrl, this.symbol);
}

/*
 * Centralized token trackers list
 */
class TokenTrackers {
  // List of Token trackers
  late Map<String, Tracker> trackers = {
    system_program_id: Tracker('solana', system_program_id, "SOL"),
  };

  late Map<String, TokenInfo> tokensList = Map();

  Future<void> loadTokenList() async {
    var tokensFile = await rootBundle.loadString('assets/tokens_list.json');
    Map tokensList = json.decode(tokensFile);
    for (final token in tokensList["tokens"]) {
      this.tokensList[token['address']] =
          TokenInfo.withInfo(token["address"], token["name"], token["logoURI"], token["symbol"]);
    }
  }

  double getTokenValue(String programMint) {
    Tracker? token = trackers[programMint];
    if (token != null) {
      return token.usdValue;
    } else {
      return 0;
    }
  }

  Tracker? getTracker(String programMint) {
    return trackers[programMint];
  }

  void setTokenValue(String programMint, double usdValue) {
    Tracker? token = trackers[programMint];
    if (token != null) {
      token.usdValue = usdValue;
    }
  }

  TokenInfo getTokenInfo(String programId) {
    if (tokensList.containsKey(programId)) {
      return tokensList[programId]!;
    }
    // If not info about the token is found then an "Unknown" token is returned
    return TokenInfo();
  }

  Tracker? addTrackerByProgramMint(String programMint) {
    // Add tracker if doesn't exist yet
    if (!trackers.containsKey(programMint)) {
      TokenInfo tokenInfo = getTokenInfo(programMint);

      trackers[programMint] = Tracker(tokenInfo.name, programMint, tokenInfo.symbol);

      return trackers[programMint];
    }
  }
}

/*
 * Fetch the USD value of a token using the Coingecko API
 */
Future<Map<String, double>> getTokenUsdValue(List<String> tokens) async {
  try {
    Map<String, String> headers = Map();
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';
    Http.Response response = await Http.get(
      Uri.http(
        'api.coingecko.com',
        '/api/v3/simple/price',
        {
          'ids': tokens.join(','),
          'vs_currencies': 'USD',
        },
      ),
      headers: headers,
    );

    final body = json.decode(response.body) as Map;
    Map<String, double> values = {};
    for (final token in body.keys) {
      double? usdTokenValue = body[token]['usd'];
      if (usdTokenValue != null) {
        values[token] = usdTokenValue;
      }
    }

    return values;
  } catch (err) {
    print(err);
    return {tokens[0]: 0};
  }
}
