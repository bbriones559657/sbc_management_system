import 'package:flutter/foundation.dart';

class InventoryRefreshController extends ChangeNotifier {
  void refresh() => notifyListeners();
}
