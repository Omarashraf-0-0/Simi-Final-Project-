import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart' as share;

class PDFViewerPage extends StatefulWidget {
  final String filePath;

  const PDFViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PDFViewController controller;
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated CV'),
        backgroundColor: const Color(0xFF165D96),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await share.Share.shareXFiles(
                [share.XFile(widget.filePath)],
                text: 'My Generated CV',
              );
            },
          ),
          if (pages > 0)
            Text(
              "${currentPage + 1} of $pages",
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            onRender: (pages) {
              setState(() {
                pages = pages!;
                isReady = true;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              controller = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page!;
              });
            },
          ),
          !isReady
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: const Color(0xFF165D96),
            onPressed: currentPage == 0
                ? null
                : () async {
                    await controller.setPage(currentPage - 1);
                  },
            child: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: const Color(0xFF165D96),
            onPressed: currentPage == pages - 1
                ? null
                : () async {
                    await controller.setPage(currentPage + 1);
                  },
            child: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}