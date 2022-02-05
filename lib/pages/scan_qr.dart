import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrPage extends StatelessWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late bool hasScanned = false;

  ScanQrPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scanArea =
        (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
            ? 250.0
            : 300.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Solana Pay QR')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                controller.scannedDataStream.listen((scanData) {
                  if (hasScanned == false) {
                    hasScanned = true;
                    Navigator.pop(context, scanData);
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 5,
                borderLength: 30,
                borderWidth: 15,
                cutOutSize: scanArea,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
