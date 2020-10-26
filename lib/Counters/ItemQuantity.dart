import 'package:flutter/foundation.dart';

class ItemQuantity with ChangeNotifier {
  int numberOfItems = 0;

  display(int no) {
    numberOfItems = no;
    notifyListeners();
  }
}
