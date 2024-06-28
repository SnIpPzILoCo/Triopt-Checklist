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
    const Color seedColor = Colors.blue; // Define your seed color here

    return MaterialApp(
      title: 'Triopt Checklist App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorScheme.fromSeed(seedColor: seedColor).primary,
          titleTextStyle: TextStyle(
            color: ColorScheme.fromSeed(seedColor: seedColor).onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorScheme.fromSeed(seedColor: seedColor).primary),
          ),
          labelStyle: TextStyle(
              color: ColorScheme.fromSeed(seedColor: seedColor).primary),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.green;
              }
              return Colors.white; // Use a different color when not selected
            },
          ),
        ),
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
    if (mounted) {
      Provider.of<GuestProvider>(context, listen: false).setGuests(guests);
    }
  }

  Future<void> exportGuests() async {
    try {
      final guests = Provider.of<GuestProvider>(context, listen: false).guests;
      final directory = await excelService.exportGuestsToExcel(context, guests);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Exportiert nach: ${directory.path}/export.xlsx')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Export: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triopt Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: exportGuests,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Suche',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                labelStyle: TextStyle(color: colorScheme.primary),
              ),
              onChanged: (query) {
                Provider.of<GuestProvider>(context, listen: false)
                    .searchGuests(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<GuestProvider>(
              builder: (context, guestProvider, child) {
                return ListView.builder(
                  itemCount: guestProvider.guests.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Gast',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  'Anwesend',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
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
                              child: Text(
                                guest.name,
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
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
                        tileColor: index % 2 == 0
                            ? colorScheme.primaryContainer.withOpacity(0.1)
                            : colorScheme.secondaryContainer.withOpacity(0.1),
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
