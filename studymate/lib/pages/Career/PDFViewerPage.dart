import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart' as sfpdf;
import 'package:share_plus/share_plus.dart' as share;

class PDFViewerPage extends StatefulWidget {
  final String filePath;

  const PDFViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  final GlobalKey<sfpdf.SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated CV'),
        backgroundColor: const Color(0xFF165D96),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              // Share the PDF file using the alias
              await share.Share.shareXFiles(
                [share.XFile(widget.filePath)],
                text: 'My Generated CV',
              );
            },
          ),
        ],
      ),
      body: sfpdf.SfPdfViewer.file(
        io.File(widget.filePath),
        key: _pdfViewerKey,
      ),
    );
  }
}