import 'package:aplicacion_manga/providers/mangas_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class OnlineViewScreen extends StatefulWidget {
  final String pdfUrl;
  final String mangaTitle;

  const OnlineViewScreen({required this.pdfUrl, required this.mangaTitle});

  @override
  _OnlineViewScreenState createState() => _OnlineViewScreenState();
}

class _OnlineViewScreenState extends State<OnlineViewScreen> {
  String? _pdfPath;

  @override
  void initState() {
    _downloadPDF();
    super.initState();
  }

  Future<void> _downloadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = Directory('/storage/emulated/0/Download/');
      await dir.create(recursive: true);

      final pdfFile = File('${dir.path}/${widget.mangaTitle}.pdf');
      await pdfFile.writeAsBytes(response.bodyBytes);

      setState(() {
        _pdfPath = pdfFile.path;
      });
    } catch (error) {
      print('Error al descargar el PDF: $error');
      Fluttertoast.showToast(msg: 'Error al descargar el PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pdfPath == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ver PDF en línea'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ver PDF en línea'),
        ),
        body: PDFView(
          filePath: _pdfPath!,
          onError: (error) {
            print('Error al cargar el PDF: $error');
          },
          onPageError: (page, error) {
            print('Error en la página $page del PDF: $error');
          },
        ),
      );
    }
  }
}
