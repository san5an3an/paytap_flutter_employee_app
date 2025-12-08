import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';

/// 전역 텍스트 스타일 정의 클래스
/// 프로젝트에서 텍스트 스타일을 사용할 때는 반드시 이 클래스를 import하여 사용해야 함
class GlobalTextStyle {
  static TextStyle get title01 => TextStyle(
    height: 30 / 30, // 30px line-height for 30px font size
    fontSize: 30,
  );

  static TextStyle get title01B => TextStyle(
    height: 35 / 30, // 35px line-height for 30px font size
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: GlobalColor.bk01,
  );
  static TextStyle get title02 => TextStyle(
    height: 30 / 25, // 30px line-height for 25px font size
    fontSize: 25,
    color: GlobalColor.bk01,
  );

  static TextStyle get title03 => TextStyle(
    height: 30 / 20, // 30px line-height for 20px font size
    fontSize: 20,
    color: GlobalColor.bk01,
  );
  static TextStyle get title03B => TextStyle(
    height: 30 / 20, // 30px line-height for 20px font size
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: GlobalColor.bk01,
  );
  static TextStyle get title04B => TextStyle(
    height: 20 / 18, // 20px line-height for 18px font size
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: GlobalColor.bk01,
  );
  static TextStyle get title04M => TextStyle(
    height: 20 / 18, // 20px line-height for 18px font size
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: GlobalColor.bk01,
  );

  static TextStyle get title04 => TextStyle(
    height: 20 / 18, // 20px line-height for 18px font size
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: GlobalColor.bk01,
  );

  static TextStyle get body01 => TextStyle(
    height: 20 / 16, // 20px line-height for 16px font size
    fontSize: 16,
    color: GlobalColor.bk01,
  );

  static TextStyle get body01M => TextStyle(
    height: 20 / 16, // 20px line-height for 16px font size
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: GlobalColor.bk01,
  );
  static TextStyle get body01B => TextStyle(
    height: 20 / 16, // 20px line-height for 16px font size
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: GlobalColor.bk01,
  );

  static TextStyle get body02 => TextStyle(
    height: 20 / 15, // 20px line-height for 15px font size
    fontSize: 15,
    color: GlobalColor.bk01,
  );
  static TextStyle get body02M => TextStyle(
    height: 20 / 15, // 20px line-height for 15px font size
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: GlobalColor.bk01,
  );

  static TextStyle get small01 => TextStyle(
    height: 20 / 13, // 20px line-height for 13px font size
    fontSize: 13,
  );
  static TextStyle get small01M => TextStyle(
    height: 20 / 13, // 20px line-height for 13px font size
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: GlobalColor.bk01,
  );

  static TextStyle get small02 => TextStyle(
    height: 20 / 11, // 20px line-height for 11px font size
    fontSize: 11,
    color: GlobalColor.bk01,
  );
}
