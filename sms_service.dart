import 'package:telephony/telephony.dart';
import '../database/db_helper.dart';

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  // This is a top-level function that runs in the background.
  // We need to initialize the db instance explicitly here if needed,
  // but db_helper singleton works as long as path is resolved.
  if (message.body != null && message.body!.contains('HAYLEYS QTN')) {
    final dateStr = DateTime.now().toIso8601String();
    await DatabaseHelper.instance.insertSms(
      message.address ?? 'Unknown',
      message.body!,
      dateStr,
    );
  }
}

class SmsService {
  static final SmsService instance = SmsService._internal();

  factory SmsService() {
    return instance;
  }

  SmsService._internal();

  final Telephony telephony = Telephony.instance;

  Future<void> init() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != null && permissionsGranted) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          // Handle foreground message
          if (message.body != null && message.body!.contains('HAYLEYS QTN')) {
            final dateStr = DateTime.now().toIso8601String();
            await DatabaseHelper.instance.insertSms(
              message.address ?? 'Unknown',
              message.body!,
              dateStr,
            );
          }
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    }
  }
}
