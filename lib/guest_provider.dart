import 'package:flutter/material.dart';
import 'guest.dart';

class GuestProvider with ChangeNotifier {
  List<Guest> _guests = [];
  List<Guest> _filteredGuests = [];

  List<Guest> get guests => _filteredGuests;

  void addGuest(Guest guest) {
    _guests.add(guest);
    _filteredGuests = List.from(_guests);
    notifyListeners();
  }

  void setGuests(List<Guest> guests) {
    _guests = guests;
    _filteredGuests = List.from(_guests);
    notifyListeners();
  }

  void clearGuests() {
    _guests.clear();
    _filteredGuests.clear();
    notifyListeners();
  }

  void searchGuests(String query) {
    if (query.isEmpty) {
      _filteredGuests = List.from(_guests);
    } else {
      _filteredGuests = _guests
          .where((guest) => guest.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
