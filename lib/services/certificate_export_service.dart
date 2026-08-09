import 'certification_repository.dart';

class CertificateExportService {
  const CertificateExportService();

  String toPlainText(CertificateRecord certificate) {
    final date = certificate.issuedAt;
    final dateText = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return '''ASTRA COMPUTER ACADEMY\nCERTIFICATE OF COMPLETION\n\nThis certifies that\n${certificate.learnerName}\n\nhas successfully completed\n${certificate.certificateTitle}\n\nFinal Score: ${certificate.finalScore}%\nIssued: $dateText\nVerification ID: ${certificate.verificationId}\n\nOffline certificate record. Online verification can be added in a future sync version.''';
  }

  String toHtml(CertificateRecord certificate) {
    final text = toPlainText(certificate);
    final escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\n', '<br>');
    return '''<!doctype html><html><head><meta charset="utf-8"><title>ASTRA Certificate</title></head><body style="font-family:Arial,sans-serif;text-align:center;padding:48px"><div style="border:3px solid #333;padding:42px;max-width:800px;margin:auto"><h1>ASTRA COMPUTER ACADEMY</h1><p>$escaped</p></div></body></html>''';
  }
}
