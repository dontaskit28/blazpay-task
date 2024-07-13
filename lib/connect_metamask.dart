import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:url_launcher/url_launcher.dart';

const String projectId = "a65a1eb1e7fa9091e64026c4f11201cb";

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  SessionData? session;
  late Web3App wcClient;
  String chainId = 'ep155:11155111';
  String? walletAddress;

  Future<void> initWalletConnect() async {
    wcClient = await Web3App.createInstance(
      relayUrl: 'wss://relay.walletconnect.com',
      projectId: projectId,
      metadata: const PairingMetadata(
        name: 'BlazPay Router Swap',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
        redirect: Redirect(
          universal: 'https://walletconnect.com',
        ),
      ),
    );
  }

  Future<ConnectResponse?> connectWallet() async {
    try {
      ConnectResponse resp = await wcClient.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: [chainId],
            methods: [
              'personal_sign',
              'eth_signTransaction',
              'eth_accounts',
            ],
            events: ['chainChanged'],
          ),
        },
      );
      return resp;
    } catch (e) {
      debugPrint("Error connecting to wallet $e");
      return null;
    }
  }

  Future<SessionData?> authorize(
    ConnectResponse resp,
    String unSignedMessage,
  ) async {
    SessionData? sessionData;
    try {
      sessionData = await resp.session.future;
    } catch (err) {
      debugPrint("Catch wallet authorize error $err");
    }
    return sessionData;
  }

  onDisplayUri(Uri uri) async {
    await launchUrl(uri);
  }

  Future<String?> signTransaction(
    ConnectResponse resp,
    String walletAddress,
    String topic,
    String unSignedMessage,
  ) async {
    String? signature;
    try {
      Uri? uri = resp.uri;
      if (uri != null) {
        final res = await wcClient.request(
          topic: topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: 'personal_sign',
            params: [unSignedMessage, walletAddress],
          ),
        );
        signature = res.toString();
      }
    } catch (err) {
      debugPrint("Catch SendMessageForSigned error $err");
    }
    return signature;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await initWalletConnect();
                ConnectResponse? resp = await connectWallet();
                if (resp != null) {
                  Uri? uri = resp.uri;
                  if (uri != null) {
                    onDisplayUri(uri);
                  }
                  session = await authorize(resp, 'Hello World');
                  // setState(() {});
                  if (session != null) {
                    final String walletAddress = NamespaceUtils.getAccount(
                      session!.namespaces.values.first.accounts.first,
                    );
                    this.walletAddress = walletAddress;
                    debugPrint('Wallet address: $walletAddress');
                    onDisplayUri(uri!);
                    String? sigFromWallet = await signTransaction(
                      resp,
                      walletAddress,
                      session!.topic,
                      'Hello World',
                    );

                    if (sigFromWallet != null) {
                      debugPrint('Signature from wallet: $sigFromWallet');
                    }
                    await wcClient.disconnectSession(
                      topic: session!.topic,
                      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
                    );
                  }
                }
              },
              child: const Text('Connect to MetaMask'),
            ),
            if (session != null) ...[
              ElevatedButton(
                onPressed: () async {},
                child: const Text('Sign Transaction'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
