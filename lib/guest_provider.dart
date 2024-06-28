import 'package:flutter/material.dart';
import 'guest.dart';

class GuestProvider with ChangeNotifier {
  List<Guest> _guests = [];
  List<Guest> _filteredGuests = [];

  List<Guest> get guests => _filteredGuests;

  void setGuests(List<Guest> guests) {
    _guests = guests;
    _filteredGuests = List.from(_guests);
    notifyListeners();
  }

  void toggleGuestCheck(int index) {
    _filteredGuests[index].isChecked = !_filteredGuests[index].isChecked;
    notifyListeners();
  }

  void searchGuests(String query) {
    if (query.isEmpty) {
      _filteredGuests = List.from(_guests);
    } else {
      _filteredGuests = _guests
          .where(
              (guest) => guest.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
