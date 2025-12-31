// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/notification_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:googleapis_auth/auth_io.dart'; // For OAuth 2.0
import 'package:http/http.dart' as http;

class SendNotification {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Load service account JSON
  static Future getServiceAccountJson() async {
    final response = await http.get(Uri.parse(Constant.jsonFileURL.toString()));
    return json.decode(response.body);
  }

  // Get Access Token for FCM REST API
  static Future<String> getAccessToken() async {
    final jsonData = await getServiceAccountJson();
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonData);
    final client = await clientViaServiceAccount(serviceAccountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  // Send One Notification
  static Future<void> sendOneNotification({
    required String token,
    required String title,
    required String body,
    required String type,
    required bool isPayment,
    required bool isSaveNotification,
    required Map<String, dynamic> payload,
    String? orderId,
    String? ownerId,
    String? customerId,
    String? driverId,
    String? senderId,
    bool isNewOrder = false,
  }) async {
    // Save notification in Firestore if required
    NotificationModel notificationModel = NotificationModel();
    if (orderId != null) {
      notificationModel.id = Constant.getUuid();
      notificationModel.type = type;
      notificationModel.title = title;
      notificationModel.description = body;
      notificationModel.orderId = orderId;
      notificationModel.ownerId = ownerId;
      notificationModel.customerId = customerId;
      notificationModel.driverId = driverId;
      notificationModel.senderId = senderId;
      notificationModel.createdAt = Timestamp.now();

      if (isSaveNotification) {
        await FireStoreUtils.setNotification(notificationModel);
      }
    }

    // Prepare payload
    final mergedPayload = {
      ...orderId != null ? notificationModel.toNotificationJson() : payload,
      'isNewOrder': isNewOrder ? 'true' : 'false',
    };

    // Prepare message for FCM
    final message = {
      'token': token,
      'data': mergedPayload, // Always include data
      'android': {
        'notification': {
          'channel_id': isNewOrder ? 'orders_channel' : 'default_channel',
          'title': title,
          'body': body,
          'sound': isNewOrder ? 'order_sound' : 'default',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      'apns': {
        'headers': {'apns-priority': '10'},
        'payload': {
          'aps': {
            'alert': {'title': title, 'body': body}, // Required for iOS display
            'sound': isNewOrder ? 'order_sound.wav' : 'default',
            'content-available': 1, // Optional: for background updates
          },
        },
      },
    };

    try {
      final accessToken = await getAccessToken();

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'message': message}),
      );

      log('✅ Notification Response: ${response.body}');
    } catch (e) {
      log('❌ Error sending notification: $e');
    }
  }
}