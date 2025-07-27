import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;

class HomePage extends StatelessWidget {
  // EXPORTACIÓN A PDF
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

  CellValue getCellValue(dynamic value) {
    if (value is String) {
      return TextCellValue(value);
    } else if (value is int) {
      return IntCellValue(value);
    } else if (value is double) {
      return DoubleCellValue(value);
    } else {
      return TextCellValue(value.toString());
    }
  }

  // EXPOTACIÓN A EXCEL
  void exporToExcel() async {
    // Crear el libro Excel
    var excel = Excel.createExcel(); //Esto crea el archivo excel vacio

    // Obteniendo la hoja activa o crear una nueva hoja
    Sheet sheetObject = excel["MySheet"];

    // Agregarmos datos a las celdas
    sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue(
      "NOMBRE",
    );
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = TextCellValue(
      "EDAD",
    );
    sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue(
      "PAÍS",
    );

    // Agregando filas dinámicamete
    List<List<dynamic>> data = [
      ["Carlos", 25, "Perú"],
      ["Ana", 32, "México"],
      ["Isaias", 63, "España"],
    ];

    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].length; j++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = getCellValue(
          data[i][j],
        );
      }
    }

    // Guardar excel
    var bytes = excel.encode();

    // Obteniendo el directorio de almacenamiento
    Directory? diretory = await getExternalStorageDirectory();
    String filePath = "${diretory!.path}/Reporte.xlsx";

    // Guardar el archivo
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytes(bytes!);
    print("Archivo guardado en: $filePath");

    OpenResult result = await OpenFilex.open(filePath);
    print("Estado de apertura: $result");
  }

  void exportMultipleSheets() async {
    var excel = Excel.createExcel();

    // Hoja1
    var sheet1 = excel["Hoja1"];
    sheet1.cell(CellIndex.indexByString("A1")).value = getCellValue("Producto");
    sheet1.cell(CellIndex.indexByString("B1")).value = getCellValue("Precio");
    sheet1.cell(CellIndex.indexByString("C1")).value = getCellValue("Cantidad");

    List<List<dynamic>> products = [
      ["Laptop", 1500.00, 10],
      ["Mouse", 30.50, 50],
      ["Teclado", 200.00, 44],
    ];

    for (int i = 0; i < products.length; i++) {
      for (int j = 0; j < products[i].length; j++) {
        sheet1
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = getCellValue(
          products[i][j],
        );
      }
    }

    // HOJA 2
    var sheet2 = excel["Hoja2"];
    sheet2.cell(CellIndex.indexByString("A1")).value = getCellValue("Nombre");
    sheet2.cell(CellIndex.indexByString("B1")).value = getCellValue("Correo");
    sheet2.cell(CellIndex.indexByString("C1")).value = getCellValue("Teléfono");

    List<List<dynamic>> users = [
      ["Jhon", "jobjhon@gmail.com", "955555555"],
      ["Frans", "Frans@frans.com", "8546546546"],
      ["Teresa", "t.tt@gmail.com", "8949868"],
    ];

    for (int i = 0; i < users.length; i++) {
      for (int j = 0; j < users[i].length; j++) {
        sheet2
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = getCellValue(
          users[i][j],
        );
      }
    }

    // Guardar excel
    var bytes = excel.encode();

    // Obteniendo el directorio de almacenamiento
    Directory? diretory = await getExternalStorageDirectory();
    String filePath = "${diretory!.path}/Reporte.xlsx";

    // Guardar el archivo
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytes(bytes!);
    print("Archivo guardado en: $filePath");

    OpenResult result = await OpenFilex.open(filePath);
    print("Estado de apertura: $result");
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
            _buildButton("Generar excel", () async {
              exporToExcel();
            }),
            _buildButton("Generar excel con varias hojas", () async {
              exportMultipleSheets();
            }),
          ],
        ),
      ),
    );
  }
}
