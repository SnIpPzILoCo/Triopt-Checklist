import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'guest_provider.dart';
import 'excel_service.dart';

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
      title: 'Triopt Cheklist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GuestListScreen(),
    );
  }
}

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  _GuestListScreenState createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final ExcelService excelService = ExcelService();

  @override
  void initState() {
    super.initState();
    loadGuests();
  }

  Future<void> loadGuests() async {
    final file = await excelService.getAssetExcelFile('assets/test.xlsx');
    final guests = await excelService.readGuestsFromExcel(file);
    Provider.of<GuestProvider>(context, listen: false).setGuests(guests);
  }

  Future<void> exportGuests() async {
    final guests = Provider.of<GuestProvider>(context, listen: false).guests;
    await excelService.exportGuestsToExcel(guests);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export fertig')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triopt Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportGuests,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Suche',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                Provider.of<GuestProvider>(context, listen: false).searchGuests(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<GuestProvider>(
              builder: (context, guestProvider, child) {
                return ListView.builder(
                  itemCount: guestProvider.guests.length + 1, // +1 for the title row
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Gast',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  'Anwesend',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final guest = guestProvider.guests[index - 1];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(guest.name),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Checkbox(
                                  value: guest.isChecked,
                                  onChanged: (bool? value) {
                                    guestProvider.toggleGuestCheck(index - 1);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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
