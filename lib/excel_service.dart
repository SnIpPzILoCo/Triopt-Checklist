import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'guest.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:downloadsfolder/downloadsfolder.dart';

class ExcelService {
  Future<List<Guest>> readGuestsFromExcel(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    List<Guest> guests = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      bool isFirstRow = true;
      for (var row in sheet!.rows) {
        if (isFirstRow) {
          isFirstRow = false;
          continue;
        }
        guests.add(Guest(
          name: row[0]?.value.toString() ?? '',
          isChecked:
              (row[1]?.value ?? 'FALSE').toString().toLowerCase() == 'TRUE',
        ));
      }
    }

    return guests;
  }

  Future<Directory> exportGuestsToExcel(
      BuildContext context, List<Guest> guests) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      const TextCellValue('Gast'),
      const TextCellValue('Anwesend'),
    ]);

    for (var guest in guests) {
      sheetObject.appendRow([
        TextCellValue(guest.name),
        TextCellValue(guest.isChecked ? 'TRUE' : 'FALSE'),
      ]);
    }

    var bytes = excel.encode()!;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var directory = await getDownloadDirectory();

    if (androidInfo.version.sdkInt.toInt() <= 32) {
      var status = await Permission.storage.request();

      if (status.isGranted) {
        final file = File('${directory.path}/export.xlsx');
        await file.writeAsBytes(bytes, flush: true);
      } else {
        throw Exception("Storage permission denied");
      }
    } else if (androidInfo.version.sdkInt.toInt() >= 33) {
      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        final file = File('${directory.path}/export.xlsx');
        await file.writeAsBytes(bytes, flush: true);
      } else {
        throw Exception("Storage permission denied");
      }
    }

    return directory;
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
