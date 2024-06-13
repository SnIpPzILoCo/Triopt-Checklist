import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'guest_provider.dart';
import 'guest.dart';
import 'excel_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GuestProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GuestListScreen(),
    );
  }
}

class GuestListScreen extends StatelessWidget {
  final ExcelService excelService = ExcelService();

  Future<void> importGuests(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final guests = await excelService.readGuestsFromExcel(file);
      context.read<GuestProvider>().setGuests(guests);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () => importGuests(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Guest',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context.read<GuestProvider>().searchGuests(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<GuestProvider>(
              builder: (context, guestProvider, child) {
                return ListView.builder(
                  itemCount: guestProvider.guests.length,
                  itemBuilder: (context, index) {
                    final guest = guestProvider.guests[index];
                    return ListTile(
                      title: Text(guest.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
