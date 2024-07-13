import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://k8-testnet-pf.routerchain.dev/api/v2/";
  Future getQuote({
    required String fromTokenAdress,
    required String toTokenAddress,
    required double amount,
    required String fromTokenChainId,
    required String toTokenChainId,
    required int partnerId,
  }) async {
    try {
      Uri url = Uri.parse("${baseUrl}quote");
      url = url.replace(queryParameters: {
        "fromTokenAddress": fromTokenAdress,
        "toTokenAddress": toTokenAddress,
        "amount": amount.toStringAsFixed(0),
        "fromTokenChainId": fromTokenChainId,
        "toTokenChainId": toTokenChainId,
        "partnerId": partnerId.toString(),
      });
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future getTransaction({
    required Map<String, dynamic> quote,
    required String senderAddress,
    required String receiverAddress,
  }) async {
    try {
      Uri url = Uri.parse("${baseUrl}transaction");
      Map<String, dynamic> body = {
        "senderAddress": senderAddress,
        "receiverAddress": receiverAddress,
      };
      body.addAll(json.decode(jsonEncode(quote)));
      var response = await http.post(
        url,
        body: json.encode(body),
        headers: {
          "Content-Type": "application/json",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
