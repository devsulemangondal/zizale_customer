import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/global_controller.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app/modules/splash_screen/views/splash_screen_view.dart';
import 'services/localization_service.dart';
import 'themes/styles.dart';
import 'utils/dark_theme_provider.dart';
import 'utils/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Preferences.initPref();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    getSettingData();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  Future<void> getSettingData() async {
    await FireStoreUtils.getGlobalValueSetting().then((value) {
      if (value != null) {
        Constant.restaurantRadius = value.restaurantRadius!;
        Constant.restaurantDistanceType = value.distanceType!;
        Constant.driverDeliveryChargeModel = value.deliveryCharge;
      }
    });
    await FireStoreUtils.getPlatFormFeeSetting();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.isDarkThemee();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: ChangeNotifierProvider(
        create: (_) {
          return themeChangeProvider;
        },
        child: Consumer<DarkThemeProvider>(
          builder: (context, value, child) {
            return ScreenUtilInit(
                designSize: const Size(390, 844),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return GetMaterialApp(
                      title: 'Go4Food Customer'.tr,
                      debugShowCheckedModeBanner: false,
                      theme: Styles.themeData(
                          themeChangeProvider.darkTheme == 0
                              ? true
                              : themeChangeProvider.darkTheme == 1
                                  ? false
                                  : themeChangeProvider.getSystemThem(),
                          context),
                      localizationsDelegates: const [
                        CountryLocalizations.delegate,
                      ],
                      locale: LocalizationService.locale,
                      fallbackLocale: LocalizationService.locale,
                      translations: LocalizationService(),
                      builder: (context, child) {
                        return SafeArea(bottom: true, top: false, child: EasyLoading.init()(context, child));
                      },
                      initialRoute: AppPages.initial,
                      getPages: AppPages.routes,
                      home: GetBuilder<GlobalController>(
                          init: GlobalController(),
                          builder: (context) {
                            return const SplashScreenView();
                          }));
                });
          },
        ),
      ),
    );
  }
}
