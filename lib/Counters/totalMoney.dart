import 'package:flutter/cupertino.dart';

class TotalAmount extends ChangeNotifier {
  double totalAmount = 0;

  displayResult(double no) async {
    totalAmount = no;
    await Future.delayed(const Duration(microseconds: 100));
    notifyListeners();
  }
}
