import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentsRepository {
  String _url =
      'https://sandbox.api.payulatam.com/payments-api/4.0/service.cgi';

  Future<String> gatewayPayment() async {
    try {
      var uriResponse = await http.post(
        Uri.parse(_url),
        body: {
          "language": "es",
          "command": "GET_PAYMENT_METHODS",
          "merchant": {
            "apiLogin": "pRRXKOl8ikMmt9u",
            "apiKey": "4Vj8eK4rloUd272L48hsrarnUA",
          },
          "test": "true"
        },
      );
      // return json.decode(uriResponse.body);
      final decodeData = json.decode(uriResponse.body);
      return decodeData['url'];
    } catch (e) {
      return '';
    }
  }
}
