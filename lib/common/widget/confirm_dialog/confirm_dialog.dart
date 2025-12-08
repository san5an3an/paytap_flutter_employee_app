import 'package:flutter/material.dart';
import 'package:paytap_app/common/utils/styles/global_color.dart';
import 'package:paytap_app/common/utils/styles/global_text_style.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String type;
  final String confirmBtnLabel;
  final String? cancelBtnLabel;
  final Color? confirmBtnColor;
  final bool autoBtnClose;
  final void Function()? confirmBtnOnPressed;
  final void Function()? cancelBtnOnPressed;

  const ConfirmDialog({
    super.key,
    this.type = 'single', // single, multiple
    this.title = '',
    this.content = '',
    this.confirmBtnLabel = '확인',
    this.cancelBtnLabel = "취소",
    this.confirmBtnOnPressed,
    this.confirmBtnColor,
    this.cancelBtnOnPressed,
    this.autoBtnClose = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: GlobalColor.bk08,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340, minWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                title,
                style: GlobalTextStyle.title02.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Text(
                content,
                style: GlobalTextStyle.body02.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (type == 'multiple') ...[
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (cancelBtnOnPressed != null) {
                            cancelBtnOnPressed!();
                          }
                          if (autoBtnClose) {
                            Navigator.of(context).pop(false);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: GlobalColor.bk06,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(
                          cancelBtnLabel!,
                          style: GlobalTextStyle.body02M.copyWith(
                            color: GlobalColor.bk01,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (type == 'multiple') ...[const SizedBox(width: 8)],
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (confirmBtnOnPressed != null) {
                          confirmBtnOnPressed!();
                        }
                        if (autoBtnClose) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmBtnColor ?? GlobalColor.brand01,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(
                        confirmBtnLabel,
                        style: GlobalTextStyle.body02M.copyWith(
                          color: GlobalColor.bk08,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
