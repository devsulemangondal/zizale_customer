import 'package:customer/app/widget/global_widgets.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContainerCustom extends StatelessWidget {
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final Color? borderColor;

  const ContainerCustom({
    super.key,
    this.alignment = Alignment.center,
    this.padding,
    this.borderColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
        // margin: EdgeInsets.only(top: 10),
        alignment: alignment,
        padding: padding ?? paddingEdgeInsets(),
        decoration: BoxDecoration(
          color: themeChange.isDarkTheme() ? AppThemeData.surface1000 : AppThemeData.surface50,
          borderRadius: BorderRadius.circular(12)
        ),
        
        child: child);
  }
}



class ContainerCustomSub extends StatelessWidget {
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final Color? borderColor;
  final double? height;
  final double? width;

  const ContainerCustomSub({
    super.key,
    this.alignment = Alignment.center,
    this.padding,
    this.margin,
    this.borderColor,
    this.child,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
        height: height,
        width: width,
        margin: margin ?? paddingEdgeInsets(horizontal: 0, vertical: 8),
        alignment: alignment,
        padding: padding ?? paddingEdgeInsets(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeChange.isDarkTheme() ? AppThemeData.primaryBlack : AppThemeData.grey100,
        ),
        child: child);
  }
}

