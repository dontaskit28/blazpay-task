import 'dart:async';
import 'dart:math';

import 'package:blazpay_task/api.dart';
import 'package:blazpay_task/constants.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CoinModel firstCoin = allCoins.first;
  CoinModel secondCoin = allCoins[1];

  Timer? _debounce;
  final TextEditingController _firsController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  Map<String, dynamic>? quote;

  bool _isSendingTransaction = false;

  @override
  void initState() {
    super.initState();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (_firsController.text.isNotEmpty) {
          fetchQuote();
        }
      },
    );
  }

  fetchQuote() async {
    if (_firsController.text.isEmpty) return;
    setState(() {
      _secondController.text = "fetching...";
    });
    final response = await ApiService().getQuote(
      fromTokenAdress: firstCoin.address,
      toTokenAddress: secondCoin.address,
      amount: (double.tryParse(_firsController.text) ?? 0) *
          pow(
            10,
            firstCoin.decimals,
          ),
      fromTokenChainId: "43113",
      toTokenChainId: "43113",
      partnerId: 50,
    );
    if (response != null) {
      setState(() {
        quote = response;
      });
      final amount = response["destination"]["tokenAmount"];
      _secondController.text =
          ((double.tryParse(amount) ?? 0) / pow(10, secondCoin.decimals))
              .toString();
    } else {
      _secondController.text = "error getting quote";
    }
  }

  sendTransaction() async {
    if (quote == null) return;
    setState(() {
      _isSendingTransaction = true;
    });
    final response = await ApiService().getTransaction(
      quote: quote!,
      senderAddress: "0x04be89d8D900721b013cAd1825f11236B70C5385",
      receiverAddress: "0x04be89d8D900721b013cAd1825f11236B70C5385",
    );
    if (response != null) {
      print(response);
    }
    setState(() {
      _isSendingTransaction = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _firsController.dispose();
    _secondController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firsController,
                            decoration: InputDecoration(
                              labelText: "Enter amount",
                              border: const OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: DropdownButtonHideUnderline(
                                child: DropdownButton2<CoinModel>(
                                  items: allCoins
                                      .map(
                                        (CoinModel coin) =>
                                            DropdownMenuItem<CoinModel>(
                                          value: coin,
                                          child: Row(
                                            children: [
                                              Image.network(
                                                coin.image,
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                coin.symbol,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != firstCoin) {
                                      setState(() {
                                        firstCoin = value!;
                                      });
                                      fetchQuote();
                                    } else {
                                      setState(() {
                                        firstCoin = value!;
                                      });
                                    }
                                    if (secondCoin == firstCoin) {
                                      setState(() {
                                        secondCoin = allCoins.firstWhere(
                                          (element) => element != firstCoin,
                                        );
                                      });
                                    }
                                  },
                                  value: firstCoin,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _onChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _secondController,
                            decoration: InputDecoration(
                              labelText: "Enter amount",
                              border: const OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: DropdownButtonHideUnderline(
                                child: DropdownButton2<CoinModel>(
                                  items: allCoins
                                      .map(
                                        (CoinModel coin) =>
                                            DropdownMenuItem<CoinModel>(
                                          value: coin,
                                          child: Row(
                                            children: [
                                              Image.network(
                                                coin.image,
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                coin.symbol,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != secondCoin) {
                                      setState(() {
                                        secondCoin = value!;
                                      });
                                      fetchQuote();
                                    } else {
                                      setState(() {
                                        secondCoin = value!;
                                      });
                                    }
                                    if (firstCoin == secondCoin) {
                                      setState(() {
                                        firstCoin = allCoins.firstWhere(
                                          (element) => element != secondCoin,
                                        );
                                      });
                                    }
                                  },
                                  value: secondCoin,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (quote != null) ...[
                      Row(
                        children: [
                          Text(
                            "Path: ${quote?["source"]["tokenPath"]}",
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_isSendingTransaction) {
                              sendTransaction();
                            }
                          },
                          child: _isSendingTransaction
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Swap",
                                  style: TextStyle(fontSize: 20),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
