// ignore_for_file: deprecated_member_use

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/owner_model.dart';
import 'package:customer/app/models/vendor_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/order_status.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/themes/app_theme_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackOrderController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<OrderModel> orderModel = OrderModel().obs;

  Rx<TextEditingController> otherReasonController = TextEditingController().obs;

  RxInt selectedIndex = 0.obs;
  List<dynamic> cancelReason = Constant.cancellationReason;

  Rx<OwnerModel> ownerModel = OwnerModel().obs;
  Rx<VendorModel> restaurantModel = VendorModel().obs;
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;

  @override
  void onInit() {
    getArguments();
    addMarkerSetup();
    super.onInit();
  }

  Future<void> getRestaurantAndOwnerData(String restaurantID) async {
    try {
      restaurantModel.value = (await FireStoreUtils.getRestaurant(restaurantID))!;
      final owner = await FireStoreUtils.getOwnerProfile(restaurantModel.value.ownerId.toString());
      if (owner != null) {
        ownerModel.value = owner;
      }
    } catch (e, stack) {
      developer.log(
        'Error getting restaurant and owner data: ',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> getArguments() async {
    try {
      dynamic arguments = Get.arguments;
      if (arguments != null) {
        orderModel.value = arguments["bookingModel"];
        if (orderModel.value.id != null && orderModel.value.id!.isNotEmpty) {
          await getRestaurantAndOwnerData(orderModel.value.vendorId!);

          FireStoreUtils.fireStore.collection(CollectionName.orders).doc(orderModel.value.id).snapshots().listen((orderEvent) {
            if (orderEvent.exists) {
              orderModel.value = OrderModel.fromJson(orderEvent.data()!);
              if (orderModel.value.driverId != null && orderModel.value.driverId!.isNotEmpty) {
                FireStoreUtils.fireStore.collection(CollectionName.driver).doc(orderModel.value.driverId).snapshots().listen((event) async {
                  if (event.exists) {
                    driverUserModel.value = DriverUserModel.fromJson(event.data()!);

                    if (orderModel.value.orderStatus == OrderStatus.orderPending) {
                      addMarker(
                        latitude: orderModel.value.vendorAddress!.location!.latitude,
                        longitude: orderModel.value.vendorAddress!.location!.longitude,
                        id: "restaurant",
                        descriptor: pickUpIcon!,
                        rotation: 0.0,
                      );
                      isLoading.value = false;
                      update();
                    } else if (orderModel.value.orderStatus == OrderStatus.driverAccepted || orderModel.value.orderStatus == OrderStatus.orderOnReady) {
                      getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: orderModel.value.vendorAddress!.location!.latitude,
                        destinationLongitude: orderModel.value.vendorAddress!.location!.longitude,
                      );
                      isLoading.value = false;
                      update();
                    } else if (orderModel.value.orderStatus == OrderStatus.driverPickup) {
                      getPolyline(
                        sourceLatitude: orderModel.value.customerAddress!.location!.latitude,
                        sourceLongitude: orderModel.value.customerAddress!.location!.longitude,
                        destinationLatitude: driverUserModel.value.location!.latitude,
                        destinationLongitude: driverUserModel.value.location!.longitude,
                      );
                      isLoading.value = false;
                      update();
                    }
                  }
                });
              }
            }
          });
        } else {
          isLoading.value = false;
        }
      }
      isLoading.value = false;
    } catch (e, stack) {
      developer.log(
        'Error getting arguments: ',
        error: e,
        stackTrace: stack,
      );
      isLoading.value = false;
    }
  }

  Future<bool> cancelBooking(OrderModel bookingModels) async {
    try {
      OrderModel booking = bookingModels;
      booking.orderStatus = OrderStatus.orderCancel;
      booking.cancelledBy = FireStoreUtils.getCurrentUid();
      booking.cancelledReason = cancelReason[selectedIndex.value] != "Other"
          ? cancelReason[selectedIndex.value].toString()
          : "${cancelReason[selectedIndex.value].toString()} : ${otherReasonController.value.text}";
      bool? isCancelled = await FireStoreUtils.setOrder(booking);
      return (isCancelled);
    } catch (e, stack) {
      developer.log(
        'Error cancelling booking: ',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.googleMapKey);

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  GoogleMapController? mapController;

  void getPolyline({
    required double? sourceLatitude,
    required double? sourceLongitude,
    required double? destinationLatitude,
    required double? destinationLongitude,
  }) async {
    try {
      if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(sourceLatitude, sourceLongitude),
            destination: PointLatLng(destinationLatitude, destinationLongitude),
            mode: TravelMode.driving,
          ),
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          ShowToastDialog.showToast("Unable to fetch route points.".tr);
        }

        addMarker(
          latitude: sourceLatitude,
          longitude: sourceLongitude,
          id: "pickUp",
          descriptor: pickUpIcon!,
          rotation: 0.0,
        );

        addMarker(
          latitude: destinationLatitude,
          longitude: destinationLongitude,
          id: "drop",
          descriptor: dropIcon!,
          rotation: 0.0,
        );

        addPolyLine(polylineCoordinates);
      }
    } catch (e, stack) {
      developer.log(
        'Error getting polyline: ',
        error: e,
        stackTrace: stack,
      );
    }
  }

  BitmapDescriptor? pickUpIcon;
  BitmapDescriptor? dropIcon;

  Future<void> addMarkerSetup() async {
    try {
      final Uint8List pickUpUint8List = await Constant().getBytesFromAsset('assets/images/ig_pick_up_bike.png', 80);
      final Uint8List dropUint8List = await Constant().getBytesFromAsset('assets/icons/ic_drop_in_map.png', 80);
      pickUpIcon = BitmapDescriptor.fromBytes(pickUpUint8List);
      dropIcon = BitmapDescriptor.fromBytes(dropUint8List);
    } catch (e, stack) {
      developer.log(
        'Error loading marker icons: ',
        error: e,
        stackTrace: stack,
      );
    }
  }

  void addMarker({
    required double? latitude,
    required double? longitude,
    required String id,
    required BitmapDescriptor descriptor,
    required double? rotation,
  }) {
    try {
      MarkerId markerId = MarkerId(id);
      Marker marker = Marker(
        markerId: markerId,
        icon: descriptor,
        position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
        rotation: rotation ?? 0.0,
      );
      markers[markerId] = marker;
    } catch (e, stack) {
      developer.log(
        'Error adding marker: ',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> addPolyLine(List<LatLng> polylineCoordinates) async {
    try {
      PolylineId id = const PolylineId("poly");
      Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        consumeTapEvents: true,
        color: AppThemeData.primary500,
        startCap: Cap.roundCap,
        width: 4,
      );
      polyLines[id] = polyline;
      updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
    } catch (e, stack) {
      developer.log(
        'Error adding polyline: ',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    try {
      if (mapController == null) return;

      LatLngBounds bounds;

      if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
        bounds = LatLngBounds(southwest: destination, northeast: source);
      } else if (source.longitude > destination.longitude) {
        bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude),
        );
      } else if (source.latitude > destination.latitude) {
        bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude),
        );
      } else {
        bounds = LatLngBounds(southwest: source, northeast: destination);
      }

      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);
      await checkCameraLocation(cameraUpdate, mapController);
    } catch (e, stack) {
      developer.log("Error updating camera location: ", error: e, stackTrace: stack);
    }
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    try {
      mapController.animateCamera(cameraUpdate);

      LatLngBounds l1 = await mapController.getVisibleRegion();
      LatLngBounds l2 = await mapController.getVisibleRegion();

      if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
        return checkCameraLocation(cameraUpdate, mapController);
      }
    } catch (e, stack) {
      developer.log("Error checking camera location: ", error: e, stackTrace: stack);
    }
  }
}
