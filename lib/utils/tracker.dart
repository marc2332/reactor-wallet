import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:solana/solana.dart';

/*
 * Types of accounts
 */
enum AccountType {
  // ignore: constant_identifier_names
  Wallet,
  // ignore: constant_identifier_names
  Client,
}

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

/*
 * Info about a token
 */
class TokenInfo {
  late String name;
  late String logoUrl = "";
  late String symbol;
  late String mintAddress;
  late int decimals;

  TokenInfo({
    required this.name,
    required this.symbol,
    this.decimals = 1,
  });
  TokenInfo.withInfo(
    this.mintAddress,
    this.name,
    this.logoUrl,
    this.symbol,
    this.decimals,
  );
}

/*
 * Centralized token trackers list
 */
class TokenTrackers {
  // List of Token trackers
  late Map<String, Tracker> trackers = {
    SystemProgram.programId: Tracker('solana', SystemProgram.programId, "SOL"),
  };

  late Map<String, TokenInfo> tokensList = {};

  Future<void> loadTokenList() async {
    var tokensFile = await rootBundle.loadString('assets/tokens_list.json');
    Map tokensList = json.decode(tokensFile);
    for (final token in tokensList["tokens"]) {
      this.tokensList[token['address']] = TokenInfo.withInfo(
          token["address"], token["name"], token["logoURI"], token["symbol"], token["decimals"]);
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

  TokenInfo? getTokenInfo(String programId) {
    if (tokensList.containsKey(programId)) {
      return tokensList[programId]!;
    }
    return null;
  }

  TokenInfo addTrackerByProgramMint(String programMint, {required TokenInfo defaultValue}) {
    TokenInfo tokenInfo = getTokenInfo(programMint) ?? defaultValue;

    // Add tracker if doesn't exist yet
    if (!trackers.containsKey(programMint)) {
      trackers[programMint] = Tracker(tokenInfo.name, programMint, tokenInfo.symbol);
    }

    return tokenInfo;
  }
}

/*
 * Fetch the USD value of a token using the Coingecko API
 */
Future<Map<String, double>> getTokenUsdValue(List<String> tokens) async {
  try {
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Access-Control-Allow-Origin'] = '*';
    http.Response response = await http.get(
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
    return {tokens[0]: 0};
  }
}
