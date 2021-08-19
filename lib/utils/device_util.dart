import 'package:flutter/cupertino.dart';

class Device {
  static Device _instance = Device._();

  Device._();

  Device.init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screen = mediaQuery.size;
    _shortestSide = mediaQuery.size.shortestSide;
    _longestSide = mediaQuery.size.longestSide;
    _systemBarHeight = mediaQuery.padding.top;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _orientation = mediaQuery.orientation;
    // _pixelRatio = mediaQuery.devicePixelRatio;
    _instance = this;
  }

  late double _pixelRatio;
  late Size _screen;
  late double _shortestSide;
  late double _longestSide;
  late double _systemBarHeight;
  late double _textScaleFactor;
  late Orientation _orientation;

  static Size get screen => _instance._screen;
  static double get width => _instance._screen.width;
  static double get height => _instance._screen.height;
  static double get shortestSide => _instance._shortestSide;
  static double get longestSide => _instance._longestSide;
  static double get systemBarHeight => _instance._systemBarHeight;
  static double get textScaleFactor => _instance._textScaleFactor;
  // static double get pixelRatio => _instance._pixelRatio;
  static Orientation get orientation => _instance._orientation;
  static bool get isPortrait => _instance._orientation == Orientation.portrait;
}
