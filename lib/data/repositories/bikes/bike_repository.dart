import 'dart:convert';
import 'dart:io';
import 'package:biux/data/models/bike.dart';
import 'package:biux/data/models/trademark_bike.dart';
import 'package:biux/data/models/type_bike.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class BikeRepository {
  final urlBase = "https://biux-prod.ibacrea.com/api/v1/bicicletas";
  Future<Bike> getBikeRoad(int id) async {
    var url = '$urlBase?usuario.id=$id';
    var bikeVoid = Bike(
      description: "",
      storeBuy: "",
      dateBuy: "",
      photoBikeComplete: "",
      photoInvoice: "",
      photoFrontal: "",
      photoSerial: "",
      typeBike: TypeBike(),
      photoGroupBike: "",
      photoOwnershipCard: "",
      id: '',
      trademarkBike: TrademarkBike(),
    );
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    Map<String, dynamic> responseData = json.decode(response.body);
    Map bikesJson = responseData["data"][0];
    Bike bike = Bike.fromjson(bikesJson);
    if (bikeVoid.description != "") {
      return bike;
    } else {
      return bikeVoid;
    }
  }

  Future getBike() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'aplication/json',
    };
    var response = await http.get(
      Uri.parse(urlBase),
      headers: headers,
    );
    return response;
  }

  Future uploadBike(
    String id,
    File photoBikeComplete,
    File photoInvoice,
    File photoFrontal,
    File photoGroupBike,
    File photoSerial,
    File photoOwnershipCard,
  ) async {
    Dio dio = new Dio();
    //  dio.options.headers["content-Type"] = "multipart/form-data";
    // dio.options.headers["authorization"] = await LocalStorage().getToken();
    FormData formData = FormData.fromMap(
      {
        "photoBikeComplete": await MultipartFile.fromFile(
          photoBikeComplete.path,
        ),
        "photoInvoice": await MultipartFile.fromFile(
          photoInvoice.path,
        ),
        "photoFrontal": await MultipartFile.fromFile(
          photoFrontal.path,
        ),
        "photoGroupBike": await MultipartFile.fromFile(
          photoGroupBike.path,
        ),
        "photoSerial": await MultipartFile.fromFile(
          photoSerial.path,
        ),
        "photoOwnershipCard": await MultipartFile.fromFile(
          photoOwnershipCard.path,
        ),
      },
    );
    await dio.patch(
      'https://biux-prod.ibacrea.com/api/v1/bicicletas/$id/subirFotos',
      data: formData,
    );
  }

  Future sendDatesBike(Bike bike) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = jsonEncode(bike.toJson());
    final http.Response response = await http.post(
      Uri.parse(urlBase),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      Map responseData = json.decode(response.body);
      int id = responseData["id"];
      return id;
    } else {}
  }

  Future<Bike> updateDatesBike(Bike bike) async {
    final urlBase2 = "https://biux-prod.ibacrea.com/api/v1/bicicletas";
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      // HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var body = jsonEncode(bike.toJson());
    var url = '$urlBase2/${bike.id}';
    final http.Response response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return Bike.fromjson(json.decode(response.body));
    } else {
      throw Exception('Fallo en actualizar bicicleta');
    }
    //Map<String, dynamic> responseData = json.decode(response.body);
    //return Usuario.fromJsonMap(responseData);
    //return Usuario.fromJsonMap(personasJson.first);
  }
}
