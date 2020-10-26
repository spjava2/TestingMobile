import 'package:e_shop/Config/config.dart';
import 'package:flutter/foundation.dart';

class CartItemCounter extends ChangeNotifier {
  int counter = EcommerceApp.sharedPreferences
          .getStringList(EcommerceApp.userCartList)
          .length -
      1;

  int get count => counter;

  dispayResult() async {
    int counter = EcommerceApp.sharedPreferences
            .getStringList(EcommerceApp.userCartList)
            .length -
        1;

    await Future.delayed(const Duration(microseconds: 100), () {
      notifyListeners();
    });
  }
}
