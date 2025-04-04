import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/chat_controller.dart';
import 'package:sixam_mart_delivery/controller/notification_controller.dart';
import 'package:sixam_mart_delivery/controller/order_controller.dart';
import 'package:sixam_mart_delivery/data/model/body/notification_body.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/helper/user_type.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'callkit_helper.dart';

class NotificationHelper {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (NotificationResponse load) async {
      try {
        if (load.payload!.isNotEmpty) {
          NotificationBody payload =
              NotificationBody.fromJson(jsonDecode(load.payload!));

          if (payload.notificationType == NotificationType.order) {
            Get.offAllNamed(RouteHelper.getOrderDetailsRoute(payload.orderId,
                fromNotification: true));
          } else if (payload.notificationType ==
              NotificationType.order_request) {
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          } else if (payload.notificationType == NotificationType.general) {
            Get.offAllNamed(
                RouteHelper.getNotificationRoute(fromNotification: true));
          } else {
            Get.offAllNamed(RouteHelper.getChatRoute(
                notificationBody: payload,
                conversationId: payload.conversationId,
                fromNotification: true));
          }
        }
      } catch (_) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            "onMessage: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
        print("onMessage message type:${message.data['type']}");
        print("onMessage message:${message.data}");
      }

      if (message.data['type'] == 'message' &&
          Get.currentRoute.startsWith(RouteHelper.chatScreen)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if (Get.find<ChatController>()
                  .messageModel!
                  .conversation!
                  .id
                  .toString() ==
              message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1,
              NotificationBody(
                notificationType: NotificationType.message,
                customerId: message.data['sender_type'] == UserType.user.name
                    ? 0
                    : null,
                vendorId: message.data['sender_type'] == UserType.vendor.name
                    ? 0
                    : null,
              ),
              null,
              int.parse(message.data['conversation_id'].toString()),
            );
          } else {
            NotificationHelper.showNotification(
                message, flutterLocalNotificationsPlugin);
          }
        }
      } else if (message.data['type'] == 'message' &&
          Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      } else {
        String? type = message.data['type'];

        if (type != 'assign' &&
            type != 'new_order' &&
            type != 'order_request') {
          NotificationHelper.showNotification(
              message, flutterLocalNotificationsPlugin);
          Get.find<OrderController>().getCurrentOrders();
          Get.find<OrderController>().getLatestOrders();
          Get.find<NotificationController>().getNotificationList();
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            "onOpenApp: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
        print("onOpenApp message type:${message.data['type']}");
      }
      try {
        if (/*message.data != null || */ message.data.isNotEmpty) {
          NotificationBody notificationBody = convertNotification(message.data);

          if (notificationBody.notificationType == NotificationType.order) {
            Get.toNamed(RouteHelper.getOrderDetailsRoute(
                int.parse(message.data['order_id'])));
          } else if (notificationBody.notificationType ==
              NotificationType.order_request) {
            Get.toNamed(RouteHelper.getMainRoute('order-request'));
          } else if (notificationBody.notificationType ==
              NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute());
          } else {
            Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: notificationBody,
                conversationId: notificationBody.conversationId));
          }
        }
      } catch (_) {}
    });
  }

  static Future<void> showNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if (!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      NotificationBody? notificationBody;

      title = message.notification!.title;
      body = message.notification!.body;
      notificationBody = convertNotification(message.data);

      if (GetPlatform.isAndroid) {
        image = (message.notification!.android!.imageUrl != null &&
                message.notification!.android!.imageUrl!.isNotEmpty)
            ? message.notification!.android!.imageUrl!.startsWith('http')
                ? message.notification!.android!.imageUrl
                : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.android!.imageUrl}'
            : null;
      } else if (GetPlatform.isIOS) {
        image = (message.notification!.apple!.imageUrl != null &&
                message.notification!.apple!.imageUrl!.isNotEmpty)
            ? message.notification!.apple!.imageUrl!.startsWith('http')
                ? message.notification!.apple!.imageUrl
                : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.apple!.imageUrl}'
            : null;
      }

      if (image != null &&
          image
              .isNotEmpty /*&& _notificationBody.notificationType != NotificationType.message*/) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(
              title, body, notificationBody, image, fln);
        } catch (e) {
          await showBigTextNotification(title, body!, notificationBody, fln);
        }
      } else {
        await showBigTextNotification(title, body!, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(
      String title,
      String body,
      NotificationBody notificationBody,
      FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'قريب مندوب',
      'قريب مندوب',
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics,
        payload: jsonEncode(notificationBody.toJson()));
  }

  static Future<void> showBigTextNotification(
      String? title,
      String body,
      NotificationBody? notificationBody,
      FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'قريب مندوب',
      'قريب مندوب',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String? title,
      String? body,
      NotificationBody? notificationBody,
      String image,
      FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'قريب مندوب',
      'قريب مندوب',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBody convertNotification(Map<String, dynamic> data) {
    if (data['type'] == 'general') {
      return NotificationBody(notificationType: NotificationType.general);
    } else if (data['type'] == 'new_order' ||
        data['type'] == 'New order placed' ||
        data['type'] == 'order_status') {
      return NotificationBody(
          orderId: int.parse(data['order_id']),
          notificationType: NotificationType.order);
    } else {
      return NotificationBody(
          orderId: (data['order_id'] != null && data['order_id'].isNotEmpty)
              ? int.parse(data['order_id'])
              : null,
          conversationId: (data['conversation_id'] != null &&
                  data['conversation_id'].isNotEmpty)
              ? int.parse(data['conversation_id'])
              : null);
    }
  }
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(
        "onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
  }
  // show native call dialog if notification type is order
  final data = message.data;
  if (data['type'] == 'updated' || data['type'] == 'New order placed') {
    CallHelper.makeFakeCall(title: message.data['title']);
  }
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}
