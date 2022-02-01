import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrPage extends StatelessWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController? controller;
  late Barcode? result = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Solana Pay QR')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  if (result == null) {
                    result = scanData;
                    Navigator.pop(context, scanData);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
