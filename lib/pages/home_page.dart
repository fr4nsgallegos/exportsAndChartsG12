import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
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
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "Hola, este es un pdf creado en flutter!",
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text("Factura:"),
                pw.Text("Cliente: Juan Perez"),
                pw.Text("Fecha: 27/05/2025"),
              ],
            ),
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

  Future<File> generarTablePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ["Producto", "Cantidad", "Precio"],
            data: [
              ["Laptop", "1", "\$14500"],
              ["Mouse", "2", "\$500"],
              ["Teclado", "3", "\$300"],
            ],
          );
        },
      ),
    );
    // Obtener la ruta de almacenamiento local
    final output = await getApplicationDocumentsDirectory();

    // usando path para generar correctamente la ruta
    final filePath = path.join(output.path, "exampleWithTable.pdf");
    final file = File(filePath);

    // Guardar el archivo
    await file.writeAsBytes(await pdf.save());
    print("PDF guardado en ${file.path}");
    return file;
  }

  Future<File> generarPdfConImagen() async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(
      (await rootBundle.load("assets/images/peru.jpeg")).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  "PDF CON IMÁGEN",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  "Este es un ejemplo de parrafo para el pdf creado con imágen4es",
                  style: pw.TextStyle(color: PdfColors.blue),
                ),
                pw.SizedBox(height: 32),
                pw.Image(image, width: 200, height: 200, fit: pw.BoxFit.cover),
              ],
            ),
          );
        },
      ),
    );
    // Obtener la ruta de almacenamiento local
    final output = await getApplicationDocumentsDirectory();

    // usando path para generar correctamente la ruta
    final filePath = path.join(output.path, "exampleWithImage.pdf");
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
            _buildButton("Generar PDF con tabla", () async {
              final pdfFile = await generarTablePdf();
              openPdfFile(pdfFile);
            }),
            _buildButton("Generar PDF con imágen", () async {
              final pdfFile = await generarPdfConImagen();
              openPdfFile(pdfFile);
            }),
          ],
        ),
      ),
    );
  }
}
