import 'package:excel/excel.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'guest.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ExcelService {
  Future<List<Guest>> readGuestsFromExcel(File file) async {
    final bytes = await file.readAsBytes(); // Use async read
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
          isChecked:
              (row[1]?.value ?? 'false').toString().toLowerCase() == 'true',
        ));
      }
    }

    return guests;
  }

  Future<void> exportGuestsToExcel(BuildContext context, List<Guest> guests) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add the title row
    sheetObject.appendRow([
      const TextCellValue('Gast'),
      const TextCellValue('Anwesend'),
    ]);

    for (var guest in guests) {
      sheetObject.appendRow([
        TextCellValue(guest.name),
        TextCellValue(guest.isChecked ? 'true' : 'false'),
      ]);
    }

    var bytes = excel.encode()!;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Request permissions
    if (androidInfo.version.sdkInt.toInt() <= 29) {
      var status2 = await Permission.storage.request();
      if (status2.isGranted) {
        // Prompt user to select a file location to save the exported file
        String? outputPath = await FilesystemPicker.open(
          title: 'Save to folder',
          context: context,
          rootDirectory: Directory('/storage/emulated/0'), // Example root directory
          fsType: FilesystemType.folder,
          pickText: 'Save file to this folder',
        );
        if (outputPath != null) {
          final file = File('$outputPath/export.xlsx');
          await file.writeAsBytes(bytes, flush: true);
        }
      } else {
        // Handle permission denied
        throw Exception("Storage permission denied");
      }
    } else if (androidInfo.version.sdkInt.toInt() >= 30) {
      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        // Prompt user to select a file location to save the exported file
        String? outputPath = await FilesystemPicker.open(
          title: 'Save to folder',
          context: context,
          rootDirectory: Directory('/storage/emulated/0'), // Example root directory
          fsType: FilesystemType.folder,
          pickText: 'Save file to this folder',
        );
        if (outputPath != null) {
          final file = File('$outputPath/export.xlsx');
          await file.writeAsBytes(bytes, flush: true);
        }
      } else {
        // Handle permission denied
        throw Exception("Storage permission denied");
      }
    }
  }

  Future<File> getAssetExcelFile(String path) async {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/test.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
