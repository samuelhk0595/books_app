import 'package:flutter/material.dart';

class MultiListener extends Listenable {
  MultiListener({
    required this.firstListener,
    required this.secondListener,
  });

  Listenable firstListener;
  Listenable secondListener;

  @override
  void addListener(VoidCallback listener) {
    firstListener.addListener(listener);
    secondListener.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    firstListener.removeListener(listener);
    secondListener.removeListener(listener);
  }
}
