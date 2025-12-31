import 'package:customer/app/widget/text_widget.dart';
import 'package:customer/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class PriceRowView extends StatelessWidget {
  final String price;
  final String title;
  final Widget? titleWidget; // <-- new
  final Color priceColor;
  final Color titleColor;
  final String? fontFamily;
  final bool isTitleUnderLine;

  const PriceRowView({
    super.key,
    required this.title,
    required this.price,
    required this.priceColor,
    required this.titleColor,
    this.titleWidget,
    this.fontFamily = FontFamily.regular,
    this.isTitleUnderLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: titleWidget ??
              SizedBox(
                child: TextCustom(
                  title: title,
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  fontFamily: fontFamily,
                  color: titleColor,
                  isUnderLine: isTitleUnderLine,
                ),
              ),
        ),
        SizedBox(
          child: TextCustom(
            title: price,
            fontSize: 14,
            fontFamily: fontFamily,
            color: priceColor,
          ),
        ),
      ],
    );
  }
}
