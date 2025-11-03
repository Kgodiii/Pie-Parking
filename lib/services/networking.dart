import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NetworkingHelper{

  NetworkingHelper({required this.urlSuffix});

  final String urlSuffix;

  Future getData() async {

    var url = Uri.https('pieparking.co.za', urlSuffix);
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    http.Response response = await http.get(url, headers: {'Authorization' : 'Bearer $key'});

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future getDataFromId(String id) async {

    var url = Uri.https('pieparking.co.za', urlSuffix).replace(queryParameters: {
      'id': id,
    });
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    http.Response response = await http.get(url, headers: {'Authorization' : 'Bearer $key'});

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future postSignUpData(String firstname, String lastname, String username, String email, String password) async{

    var url = Uri.https('pieparking.co.za', urlSuffix);
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    String dataJson = jsonEncode(<String, String>{
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'email': email,
      'password': password,
    });

    http.Response response = await http.post(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 201){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future postLoginData(String username, String password) async{

    var url = Uri.https('pieparking.co.za', urlSuffix).replace(queryParameters: {
      'login': "true",
    });
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    String dataJson = jsonEncode(<String, String>{
      'username': username,
      'password': password,
    });

    http.Response response = await http.post(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future putGateOpen(String gateId) async{

    var url = Uri.https('pieparking.co.za', urlSuffix).replace(queryParameters: {
      'id': gateId,
      'open': "true",
    });
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    http.Response response = await http.put(url, headers: {'Authorization' : 'Bearer $key'});

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future postCreateSession(String userId, String locationId) async{

    var url = Uri.https('pieparking.co.za', urlSuffix);
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    String dataJson = jsonEncode(<String, String>{
      'userId': userId,
      'locationId': locationId,
    });

    http.Response response = await http.post(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 201){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future putPaySession(String sessionId) async{

    var url = Uri.https('pieparking.co.za', urlSuffix).replace(queryParameters: {
      'id': sessionId,
      'paid': "true",
    });
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    final now = DateTime.now();
    final formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

    String dataJson = jsonEncode(<String, String>{
      'timePaid': formattedDate,
    });

    http.Response response = await http.put(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future putEndSession(String sessionId) async{

    var url = Uri.https('pieparking.co.za', urlSuffix).replace(queryParameters: {
      'id': sessionId,
      'exit': "true",
    });
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    final now = DateTime.now();
    final formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

    String dataJson = jsonEncode(<String, String>{
      'timeOut': formattedDate,
    });

    http.Response response = await http.put(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future postCreateTransaction(String gatewayId, String amount, String sessionId, String userId, String locationId) async{

    var url = Uri.https('pieparking.co.za', urlSuffix);
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    String dataJson = jsonEncode(<String, String>{
      'gatewayId': gatewayId,
      'amount': amount,
      'sessionId': sessionId,
      'userId': userId,
      'locationId': locationId,
    });

    http.Response response = await http.post(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 201){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
    }

  }

  Future postPaymentComplete(String transactionId, String uuid) async{

    var url = Uri.https('pieparking.co.za', urlSuffix).replace(queryParameters: {
      'id': transactionId,
      'payment': 'complete',
    });
    var key = '7e7fe8897ec74c80b7151a3b347772933396ca9a56b80a061b1b4fec33e223ba';

    String dataJson = jsonEncode(<String, String>{
      'gatewayId': uuid,
    });

    http.Response response = await http.post(url, headers: {'Authorization' : 'Bearer $key'}, body: dataJson);

    if(response.statusCode == 200){
      String data = response.body;

      return jsonDecode(data);

    }else{
      print(response.statusCode);
      print(response.body);
    }

  }

}