import 'package:flutter/material.dart';

class FTPDat with ChangeNotifier {
  final List<Map<String, dynamic>> _selPax = [];
  final Set<String> _selFT = {}; // New field to track selected trucks

  List<Map<String, dynamic>> get selPax => _selPax;

  double get totProis {
    return _selPax.fold(0.0, (sum, itm) => sum + (itm['prois'] ?? 0.0));
  }

  bool isFTSel(String FTname) {
    return _selFT.contains(FTname);
  }

  void addPax(Map<String, dynamic> pax) {
    _selPax.add(pax);
    _selFT.add(pax['ft']);
    notifyListeners();
  }

  void rmvPax(int index) {
    _selFT.remove(_selPax[index]['ft']);
    _selPax.removeAt(index);
    notifyListeners();
  }

  void clrPax() {
    //Clear all selected packages
    _selFT.clear();
    _selPax.clear();
    notifyListeners();
  }

  bool hasPax() => _selPax.isNotEmpty;
}
