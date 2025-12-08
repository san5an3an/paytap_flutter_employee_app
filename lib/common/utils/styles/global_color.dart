import 'package:flutter/material.dart';

/// 전역 색상 정의 클래스
/// 프로젝트에서 색상을 사용할 때는 반드시 이 클래스를 import하여 사용해야 함
class GlobalColor {
  static const Color brand01 = Color(0xff3366FF);
  static const Color brand02 = Color(0xff224488);
  static const Color brand03 = Color(0xff112255);
  static const Color brand04 = Color(0xff33CCFF);
  static const Color bk01 = Color(0xff333333);
  static const Color bk02 = Color(0xff666666);
  static const Color bk03 = Color(0xff999999);
  static const Color bk04 = Color(0xffCCCCCC);
  static const Color bk05 = Color(0xffDDDDDD);
  static const Color bk06 = Color(0xffEEEEEE);
  static const Color bk07 = Color(0xffF6F6F6);
  static const Color bk08 = Color(0xffFFFFFF);
  static const Color systemBlue = Color(0xff0099FF);
  static const Color systemRed = Color(0xffef3346);
  static const Color systemOrange = Color(0xffFF8800);
  static const Color systemGreen = Color(0xff009999);
  static const Color systemBackGround = Color(0xffF4F8FB);
  static const Color rev01 = Color(0xffFFFFFF);
  static const Color rev02 = Color(0xccFFFFFF);
  static const Color rev03 = Color(0x66FFFFFF);
  static const Color rev04 = Color(0x33FFFFFF);
  static const Color dim01 = Color(0x99000000);
  static const Color dim02 = Color(0x33000000);
  static const Color dim03 = Color(0x1A000000);

  static const Map<String, Color> colorMap = {
    'brand01': brand01,
    'brand02': brand02,
    'brand03': brand03,
    'brand04': brand04,
    'bk01': bk01,
    'bk02': bk02,
    'bk03': bk03,
    'bk04': bk04,
    'bk05': bk05,
    'bk06': bk06,
    'bk07': bk07,
    'bk08': bk08,
    'systemBlue': systemBlue,
    'systemRed': systemRed,
    'systemOrange': systemOrange,
    'systemGreen': systemGreen,
    'systemBackGround': systemBackGround,
    'rev01': rev01,
    'rev02': rev02,
    'rev03': rev03,
    'rev04': rev04,
    'dim01': dim01,
    'dim02': dim02,
    'dim03': dim03,
  };

  static Color? getColorByName(String? colorName) {
    return colorMap[colorName];
  }
}
