import 'package:excel/excel.dart';
import 'dart:io';
import 'guest.dart';

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
}
