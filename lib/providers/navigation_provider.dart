import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {

  int _currentViewIndex = 0;
  final _controller = PageController(
    initialPage: 0,
    keepPage: true
  );

  NavigationProvider();

  void setView(int newViewIndex) {
    onViewChanged(newViewIndex);
    _controller.jumpToPage(_currentViewIndex);

  }

  void onViewChanged(int newViewIndex) {
    _currentViewIndex = newViewIndex;
    notifyListeners();
  }

  get getPageController {
    return _controller;
  }

  get currentViewIndex {
    return _currentViewIndex;
  }

}