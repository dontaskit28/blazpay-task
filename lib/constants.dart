class CoinModel {
  final String name;
  final int decimals;
  final String address;
  final String symbol;
  final String image;

  CoinModel({
    required this.name,
    required this.decimals,
    required this.address,
    required this.symbol,
    required this.image,
  });
}

List<CoinModel> allCoins = [
  CoinModel(
    name: "USDT",
    decimals: 6,
    address: "0xb452b513552aa0B57c4b1C9372eFEa78024e5936",
    symbol: "USDT",
    image:
        "https://assets.coingecko.com/coins/images/325/small/Tether-logo.png",
  ),
  CoinModel(
    name: "ETH",
    decimals: 18,
    address: "0xce811501ae59c3E3e539D5B4234dD606E71A312e",
    symbol: "ETH",
    image: "https://assets.coingecko.com/coins/images/279/small/ethereum.png",
  ),
  CoinModel(
    name: "USDC",
    decimals: 6,
    address: "0x5425890298aed601595a70ab815c96711a31bc65",
    symbol: "USDC",
    image:
        "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
  ),
];
