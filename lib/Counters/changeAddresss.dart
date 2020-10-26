import 'dart:developer';

import 'package:flutter/foundation.dart';

class AddressChanger extends ChangeNotifier {
  int counter = 0;

  displayResult(int v) {
    counter = v;
    notifyListeners();
  }
}
