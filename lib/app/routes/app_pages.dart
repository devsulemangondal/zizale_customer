import 'package:customer/app/modules/cuisine_screen/bindings/cuisine_screen_binding.dart';
import 'package:customer/app/modules/cuisine_screen/views/cuisine_screen_view.dart';
import 'package:get/get.dart';
import '../modules/add_review_screen/bindings/add_review_screen_binding.dart';
import '../modules/add_review_screen/views/add_review_screen_view.dart';
import '../modules/all_restaurant_screen/bindings/all_restaurant_screen_binding.dart';
import '../modules/all_restaurant_screen/views/all_restaurant_screen_view.dart';
import '../modules/coupon_screen/bindings/coupon_screen_binding.dart';
import '../modules/coupon_screen/views/coupon_screen_view.dart';
import '../modules/dashboard_screen/bindings/dashboard_screen_binding.dart';
import '../modules/dashboard_screen/views/dashboard_screen_view.dart';
import '../modules/driver_rating_screen/bindings/driver_rating_screen_binding.dart';
import '../modules/driver_rating_screen/views/driver_rating_screen_view.dart';
import '../modules/edit_profile_screen/bindings/edit_profile_screen_binding.dart';
import '../modules/edit_profile_screen/views/edit_profile_screen_view.dart';
import '../modules/favourites_screen/bindings/favourites_screen_binding.dart';
import '../modules/favourites_screen/views/favourites_screen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/intro_screen/bindings/intro_screen_binding.dart';
import '../modules/intro_screen/views/intro_screen_view.dart';
import '../modules/landing_screen/bindings/landing_screen_binding.dart';
import '../modules/landing_screen/views/landing_screen_view.dart';
import '../modules/language_screen/bindings/language_screen_binding.dart';
import '../modules/language_screen/views/language_screen_view.dart';
import '../modules/login_screen/bindings/login_screen_binding.dart';
import '../modules/login_screen/views/login_screen_view.dart';
import '../modules/my_address/bindings/my_address_binding.dart';
import '../modules/my_address/views/my_address_view.dart';
import '../modules/my_cart/bindings/my_cart_binding.dart';
import '../modules/my_cart/views/my_cart_view.dart';
import '../modules/my_wallet/bindings/my_wallet_binding.dart';
import '../modules/my_wallet/views/my_wallet_view.dart';
import '../modules/notification_screen/bindings/notification_screen_binding.dart';
import '../modules/notification_screen/views/notification_screen_view.dart';
import '../modules/order_detail_screen/bindings/order_detail_screen_binding.dart';
import '../modules/order_detail_screen/views/order_detail_screen_view.dart';
import '../modules/order_screen/bindings/order_screen_binding.dart';
import '../modules/order_screen/views/order_screen_view.dart';
import '../modules/profile_screen/bindings/profile_screen_binding.dart';
import '../modules/profile_screen/views/profile_screen_view.dart';
import '../modules/referral_screen/bindings/referral_screen_binding.dart';
import '../modules/referral_screen/views/referral_screen_view.dart';
import '../modules/restaurant_by_cuisine/bindings/restaurant_by_cuisine_binding.dart';
import '../modules/restaurant_by_cuisine/views/restaurant_by_cuisine_view.dart';
import '../modules/restaurant_detail_screen/bindings/restaurant_detail_screen_binding.dart';
import '../modules/restaurant_detail_screen/views/restaurant_detail_screen_view.dart';
import '../modules/search_food_screen/bindings/search_food_screen_binding.dart';
import '../modules/search_food_screen/views/search_food_view.dart';
import '../modules/select_address/bindings/select_address_binding.dart';
import '../modules/select_address/views/select_address_view.dart';
import '../modules/signup_screen/bindings/signup_screen_binding.dart';
import '../modules/signup_screen/views/signup_screen_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/top_rated_food/bindings/top_rated_food_binding.dart';
import '../modules/top_rated_food/views/top_rated_food_view.dart';
import '../modules/track_order/bindings/track_order_binding.dart';
import '../modules/track_order/views/track_order_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => LoginScreenView(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP_SCREEN,
      page: () => SignupScreenView(),
      binding: SignupScreenBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.INTRO_SCREEN,
      page: () => const IntroScreenView(),
      binding: IntroScreenBinding(),
    ),
    GetPage(
      name: _Paths.LANDING_SCREEN,
      page: () => const LandingScreenView(),
      binding: LandingScreenBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_SCREEN,
      page: () => const ProfileScreenView(),
      binding: ProfileScreenBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE_SCREEN,
      page: () => const EditProfileScreenView(),
      binding: EditProfileScreenBinding(),
    ),
    GetPage(
      name: _Paths.MY_WALLET,
      page: () => const MyWalletView(),
      binding: MyWalletBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_SCREEN,
      page: () => const DashboardScreenView(),
      binding: DashboardScreenBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_SCREEN,
      page: () => const OrderScreenView(),
      binding: OrderScreenBinding(),
    ),
    GetPage(
      name: _Paths.CUISINE_SCREEN,
      page: () => const CuisineScreenView(),
      binding: CuisineScreenBinding(),
    ),
    GetPage(
      name: _Paths.ALL_RESTAURANT_SCREEN,
      page: () => const AllRestaurantScreenView(),
      binding: AllRestaurantScreenBinding(),
    ),
    GetPage(
      name: _Paths.RESTAURANT_DETAIL_SCREEN,
      page: () => const RestaurantDetailScreenView(),
      binding: RestaurantDetailScreenBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL_SCREEN,
      page: () => const OrderDetailScreenView(),
      binding: OrderDetailScreenBinding(),
    ),
    GetPage(
      name: _Paths.ADD_REVIEW_SCREEN,
      page: () => const AddReviewScreenView(),
      binding: AddReviewScreenBinding(),
    ),
    GetPage(
      name: _Paths.MY_CART,
      page: () => const MyCartView(),
      binding: MyCartBinding(),
    ),
    GetPage(
      name: _Paths.COUPON_SCREEN,
      page: () => const CouponScreenView(),
      binding: CouponScreenBinding(),
    ),
    GetPage(
      name: _Paths.FAVOURITES_SCREEN,
      page: () => const FavouritesScreenView(),
      binding: FavouritesScreenBinding(),
    ),
    GetPage(
      name: _Paths.SELECT_ADDRESS,
      page: () => SelectAddressView(),
      binding: SelectAddressBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE_SCREEN,
      page: () => const LanguageScreenView(),
      binding: LanguageScreenBinding(),
    ),
    GetPage(
      name: _Paths.MY_ADDRESS,
      page: () => const MyAddressView(),
      binding: MyAddressBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_SCREEN,
      page: () => const NotificationScreenView(),
      binding: NotificationScreenBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_ORDER,
      page: () => const TrackOrderView(),
      binding: TrackOrderBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_FOOD_SCREEN,
      page: () => const SearchFoodScreenView(),
      binding: SearchFoodScreenBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_RATING_SCREEN,
      page: () => const DriverRatingScreenView(),
      binding: DriverRatingScreenBinding(),
    ),
    GetPage(
      name: _Paths.REFERRAL_SCREEN,
      page: () => const ReferralScreenView(),
      binding: ReferralScreenBinding(),
    ),
    GetPage(
      name: _Paths.TOP_RATED_FOOD,
      page: () => const TopRatedFoodView(),
      binding: TopRatedFoodBinding(),
    ),
    GetPage(
      name: _Paths.RESTAURANT_BY_CUISINE,
      page: () => const RestaurantByCuisineView(),
      binding: RestaurantByCuisineBinding(),
    ),
  ];
}
