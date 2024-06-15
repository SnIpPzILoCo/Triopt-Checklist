import 'package:excel/excel.dart';
import 'dart:io';
import 'guest.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelService {
  Future<List<Guest>> readGuestsFromExcel(File file) async {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    List<Guest> guests = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      bool isFirstRow = true;
      for (var row in sheet!.rows) {
        if (isFirstRow) {
          isFirstRow = false;
          continue; // Skip the first row (headline)
        }
        guests.add(Guest(
          name: row[0]?.value.toString() ?? '',
          isChecked: (row[1]?.value ?? 'false').toString().toLowerCase() == 'true',
        ));
      }
    }

    return guests;
  }

  Future<void> exportGuestsToExcel(List<Guest> guests) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add the title row
    sheetObject.appendRow([
      const TextCellValue('Guest Name'),
      const TextCellValue('Checked'),
    ]);

    for (var guest in guests) {
      sheetObject.appendRow([
        TextCellValue(guest.name),
        TextCellValue(guest.isChecked ? 'true' : 'false'),
      ]);
    }

    var bytes = excel.encode()!;

    // Request permissions
    if (await Permission.storage.request().isGranted) {
      // Prompt user to select a file location to save the exported file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'guest_list.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsBytes(bytes, flush: true);
      }
    } else {
      // Handle permission denied
      throw Exception("Storage permission denied");
    }
  }

  Future<File> getAssetExcelFile(String path) async {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/guest_list.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
