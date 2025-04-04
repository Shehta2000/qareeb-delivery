import 'dart:async';
import 'dart:developer';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../util/app_constants.dart';


class CallHelper {
  @pragma('vm:entry-point')
  static Future<void> makeFakeCall({
    String? title,
    String avatarUrl = '',
    String description = '',
    bool isAudioCall = true,
    int callingDurationSeconds = 3 * 60,
  }) async {
    final params = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      // 'nameCaller': (title == null || title.isEmpty) ? 'you_have_new_order'.tr : title,
      // 'nameCaller': 'you_have_new_order'.tr,
      'nameCaller': 'لديك طلب جديد من قريب',
      'appName': AppConstants.appName,
      'avatar': avatarUrl,
      'handle': description,
      'type': isAudioCall ? 0 : 1, // 0: audio call & 1: video call
      'textAccept': 'فتح التطبيق',
      'textDecline': 'كتم',
      'textMissedCall': '',
      'textCallback': '',
      'duration': callingDurationSeconds * 1000,
      'extra': <String, dynamic>{'userId': '1a2b3c4d'},
      'headers': <String, dynamic>{
        'apiKey': 'Abc@123!',
        'platform': 'flutter',
      },
      'android': <String, dynamic>{
        'isCustomNotification': false,
        'isShowLogo': false,
        'isShowCallback': false,
        'isShowMissedCallNotification': true,
        // 'ringtonePath': 'system_ringtone_default',
        'backgroundColor': '#0955fa',
        // 'backgroundUrl': 'https://i.pravatar.cc/500',
        'actionColor': '#0955fa',
      },
      // 'ios': <String, dynamic>{
      //   'iconName': 'CallKitLogo',
      //   'handleType': 'generic',
      //   'supportsVideo': true,
      //   'maximumCallGroups': 2,
      //   'maximumCallsPerCallGroup': 1,
      //   'audioSessionMode': 'default',
      //   'audioSessionActive': true,
      //   'audioSessionPreferredSampleRate': 44100.0,
      //   'audioSessionPreferredIOBufferDuration': 0.005,
      //   'supportsDTMF': true,
      //   'supportsHolding': true,
      //   'supportsGrouping': false,
      //   'supportsUngrouping': false,
      //   'ringtonePath': 'system_ringtone_default',
      // }
    };

    // handle listener
    callListener();
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  @pragma('vm:entry-point')
  static StreamSubscription callListener() {
    return FlutterCallkitIncoming.onEvent.listen((event) async {
      switch (event?.name) {
        case CallEvent.ACTION_CALL_INCOMING:
          log('incoming call event: ${DateTime.now()}');
          // incoming call event methods here
          break;

        case CallEvent.ACTION_CALL_START:
          log('call started');
          // when call started event methods here
          break;

        case CallEvent.ACTION_CALL_ACCEPT:
        // when call is accepted
        // you can send api request here if you want
          log('call accepted');
          break;

        case CallEvent.ACTION_CALL_DECLINE:
        // when call is declined
          log('call declined');
          break;

        case CallEvent.ACTION_CALL_ENDED:
        // when call is ended
          break;

        case CallEvent.ACTION_CALL_TIMEOUT:
        // when the call is timed out
          log('timeout call event: ${DateTime.now()}');
          break;

      /// ANDROID ONLY
        case CallEvent.ACTION_CALL_CALLBACK:
        // when the callback
          break;
        case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
          break;
        case CallEvent.ACTION_CALL_TOGGLE_HOLD:
          break;
        case CallEvent.ACTION_CALL_TOGGLE_MUTE:
          break;
        case CallEvent.ACTION_CALL_TOGGLE_DMTF:
          break;
        case CallEvent.ACTION_CALL_TOGGLE_GROUP:
          break;
        case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          break;
      }
    });
  }

  static endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }
}
