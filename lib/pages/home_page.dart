import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;

class HomePage extends StatelessWidget {
  Future<File> generarPdf() async {
    // Crear documento PDF
    final pdf = pw.Document();

    // Agregando contenido
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hola, este es un pdf creado en flutter!"),
          );
        },
      ),
    );

    // Obtener la ruta de almacenamiento local
    final output = await getApplicationDocumentsDirectory();

    // usando path para generar correctamente la ruta
    final filePath = path.join(output.path, "example.pdf");
    final file = File(filePath);

    // Guardar el archivo
    await file.writeAsBytes(await pdf.save());
    print("PDF guardado en ${file.path}");
    return file;
  }

  void openPdfFile(File filePdf) async {
    try {
      print("Intentando abrir el pdf");
      final result = await OpenFilex.open(filePdf.path);
      print("Resultado al abrir: $result");
    } catch (e) {
      print("Errrorrr: $e");
    }
  }

  Widget _buildButton(String text, VoidCallback action) {
    return ElevatedButton(onPressed: action, child: Text(text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton("Generar PDF", () async {
              final pdfFile = await generarPdf();
              openPdfFile(pdfFile);
            }),
          ],
        ),
      ),
    );
  }
}
