import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'guest_provider.dart';
import 'excel_service.dart';

//TODO: Make Site prettier(Menu, Animations, Centering, Import/Export buttons etc.).
//TODO: Ignore or Solve Messages.
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GuestProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  GuestListScreen({super.key});

  Future<void> importGuests(BuildContext context) async {
    final file = await excelService.getAssetExcelFile('assets/test.xlsx');
    final guests = await excelService.readGuestsFromExcel(file);
    context.read<GuestProvider>().setGuests(guests);
  }

  Future<void> exportGuests(BuildContext context) async {
    final guests = context.read<GuestProvider>().guests;
    final file = await excelService.exportGuestsToExcel(guests);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => importGuests(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => exportGuests(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
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
