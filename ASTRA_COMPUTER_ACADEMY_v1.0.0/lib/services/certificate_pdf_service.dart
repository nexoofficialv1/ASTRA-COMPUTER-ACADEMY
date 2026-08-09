import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificatePdfService {
  const CertificatePdfService();

  Future<String> exportFromPng({
    required Uint8List pngBytes,
    required String verificationId,
  }) async {
    final document = pw.Document();
    final image = pw.MemoryImage(pngBytes);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final root = await getApplicationDocumentsDirectory();
    final folder = Directory('${root.path}${Platform.pathSeparator}AstraCertificates');
    if (!await folder.exists()) await folder.create(recursive: true);

    final safeId = verificationId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final file = File('${folder.path}${Platform.pathSeparator}$safeId.pdf');
    await file.writeAsBytes(await document.save(), flush: true);
    return file.path;
  }
}
