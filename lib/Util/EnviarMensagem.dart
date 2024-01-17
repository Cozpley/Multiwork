import 'dart:convert';
import 'package:http/http.dart' as http;

class SendMessage{
  String _titulo;
  String _corpo;
  String _token;

  SendMessage(this._titulo, this._corpo, this._token);


  void send()async{
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAA-9JSv6w:APA91bGGyzKfF4Lam2TaplICpWUBOl8opzp9ATkqJEhS8pNkqbp9MK3idzBUiS3EbzpShr6M_ozb1FeZBnoHR0bUreoSgPeKeQ3b7r0w2-otfAWGPh_pNYKht-BdWBy-nNxukuIey8zO',
      },
      body: jsonEncode(
        {
          'notification': {
            'body': _corpo,
            'title': _titulo,
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'to': _token,
        },
      ),
    );
  }
}