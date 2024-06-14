import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'guest.dart';
import 'package:path_provider/path_provider.dart';

//TODO: IMPORTANT! Find a way to make the code work at line 29.
class ExcelService {
  Future<List<Guest>> readGuestsFromExcel(File file) async {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    List<Guest> guests = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      for (var row in sheet!.rows) {
        guests.add(Guest(name: row[0]!.value.toString()));
      }
    }

    return guests;
  }

  Future<File> exportGuestsToExcel(List<Guest> guests) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    for (var i = 0; i < guests.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByString('A$i'));
      cell.value = TextCellValue(guests[i].toString());
    }

    var bytes = excel.encode();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/exported_guest_list.xlsx');
    file.writeAsBytesSync(bytes!);
    return file;
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
