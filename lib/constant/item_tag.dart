import 'dart:developer' as developer;

import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemTag {
  static const String newProduct = "New";
  static const String popular = "Popular";
  static const String spicy = "Spicy";
  static const String bestSeller = "Bestseller";
  static const String seasonal = "Seasonal";
  static const String vegan = "Vegan";
  static const String chefSpecial = "Chef's Special";
  static const String recommended = "Recommended";
  static const String glutenFree = "Gluten-Free";
  static const String healthy = "Healthy";

  static String getItemTagTitle(String status) {
    try {
      String bookingStatus = '';
      if (status == newProduct) {
        bookingStatus = "New";
      } else if (status == popular) {
        bookingStatus = 'Popular';
      } else if (status == spicy) {
        bookingStatus = 'Spicy';
      } else if (status == bestSeller) {
        bookingStatus = 'Bestseller';
      } else if (status == seasonal) {
        bookingStatus = 'Seasonal';
      } else if (status == vegan) {
        bookingStatus = 'Vegan';
      } else if (status == chefSpecial) {
        bookingStatus = "Chef's Special";
      } else if (status == recommended) {
        bookingStatus = 'Recommended';
      } else if (status == glutenFree) {
        bookingStatus = "Gluten-Free";
      } else if (status == healthy) {
        bookingStatus = "Healthy";
      }
      return bookingStatus;
    } catch (e) {
      developer.log("Error getting item tag title for status '$status': $e");
      return '';
    }
  }

  static Color getItemTagTitleColor(String status, BuildContext context) {
    try {
      Color color = const Color(0xff9d9d9d);
      final themeChange = Provider.of<DarkThemeProvider>(context);

      if (status == newProduct) {
        color = themeChange.isDarkTheme() ? AppThemeData.success200 : AppThemeData.success400;
      } else if (status == popular) {
        color = themeChange.isDarkTheme() ? AppThemeData.pending200 : AppThemeData.pending400;
      } else if (status == spicy) {
        color = themeChange.isDarkTheme() ? AppThemeData.danger200 : AppThemeData.danger400;
      } else if (status == bestSeller) {
        color = themeChange.isDarkTheme() ? AppThemeData.secondary200 : AppThemeData.secondary400;
      } else if (status == seasonal) {
        color = themeChange.isDarkTheme() ? AppThemeData.pending200 : AppThemeData.pending400;
      } else if (status == vegan) {
        color = themeChange.isDarkTheme() ? AppThemeData.success200 : AppThemeData.success400;
      } else if (status == chefSpecial) {
        color = themeChange.isDarkTheme() ? AppThemeData.grey200 : AppThemeData.grey800;
      } else if (status == recommended) {
        color = themeChange.isDarkTheme() ? AppThemeData.info200 : AppThemeData.info400;
      } else if (status == glutenFree) {
        color = themeChange.isDarkTheme() ? AppThemeData.orange200 : AppThemeData.orange400;
      } else if (status == healthy) {
        color = themeChange.isDarkTheme() ? AppThemeData.success200 : AppThemeData.success400;
      }

      return color;
    } catch (e) {
      developer.log("Error determining color for status '$status': $e");
      return const Color(0xff9d9d9d); // Fallback color
    }
  }

  static Color getItemTagBackgroundColor(String status, BuildContext context) {
    try {
      Color color = const Color(0xff9d9d9d);
      final themeChange = Provider.of<DarkThemeProvider>(context);

      if (status == newProduct) {
        color = themeChange.isDarkTheme() ? AppThemeData.success600 : AppThemeData.success50;
      } else if (status == popular) {
        color = themeChange.isDarkTheme() ? AppThemeData.pending600 : AppThemeData.pending50;
      } else if (status == spicy) {
        color = themeChange.isDarkTheme() ? AppThemeData.danger600 : AppThemeData.danger50;
      } else if (status == bestSeller) {
        color = themeChange.isDarkTheme() ? AppThemeData.secondary600 : AppThemeData.secondary50;
      } else if (status == seasonal) {
        color = themeChange.isDarkTheme() ? AppThemeData.pending600 : AppThemeData.pending50;
      } else if (status == vegan) {
        color = themeChange.isDarkTheme() ? AppThemeData.success600 : AppThemeData.success50;
      } else if (status == chefSpecial) {
        color = themeChange.isDarkTheme() ? AppThemeData.grey600 : AppThemeData.grey50;
      } else if (status == recommended) {
        color = themeChange.isDarkTheme() ? AppThemeData.info600 : AppThemeData.info50;
      } else if (status == glutenFree) {
        color = themeChange.isDarkTheme() ? AppThemeData.orange600 : AppThemeData.orange50;
      } else if (status == healthy) {
        color = themeChange.isDarkTheme() ? AppThemeData.success600 : AppThemeData.success50;
      }

      return color;
    } catch (e) {
      developer.log("Error determining background color for status '$status': $e");
      return const Color(0xff9d9d9d); // Fallback default
    }
  }
}
