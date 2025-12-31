import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/themes/screen_size.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;
  final bool? isProfile;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.errorWidget,
    this.color,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
        fit: fit ?? BoxFit.fill,
        height: height ?? ScreenSize.height(8, context),
        width: width ?? ScreenSize.width(15, context),
        imageUrl: imageUrl,
        color: color,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Shimmer.fromColors(
              baseColor: AppThemeData.grey300,
              highlightColor: AppThemeData.grey200,
              child: Container(
                height: height ?? ScreenSize.height(8, context),
                width: width ?? ScreenSize.width(15, context),
                color: AppThemeData.grey300,
              ),
            ),
        errorWidget: (context, url, error) => Container(
          height: height ?? ScreenSize.height(8, context),
          width: width ?? ScreenSize.width(15, context),
          color: themeChange.isDarkTheme() ? AppThemeData.grey800 : AppThemeData.grey200,
          child: errorWidget ??
              Image.asset(
                isProfile! ? Constant.userPlaceHolder : Constant.placeLogo,
                height: height ?? ScreenSize.height(8, context),
                width: width ?? ScreenSize.width(15, context),
              ),
        ),
      ),
    );
  }
}
