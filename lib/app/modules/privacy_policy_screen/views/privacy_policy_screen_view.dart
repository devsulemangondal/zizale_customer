import 'package:customer/themes/common_ui.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PrivacyPolicyScreenView extends GetView {
  final String title;
  final String htmlData;

  const PrivacyPolicyScreenView({
    super.key,
    required this.title,
    required this.htmlData,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface.customAppBar(context, themeChange, title, backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: HtmlWidget(
              htmlData.toString(),
              textStyle: DefaultTextStyle.of(context).style,
              key: const Key('uniqueKey'),
            ),
          ),
        ),
      ),
    );
  }
}
