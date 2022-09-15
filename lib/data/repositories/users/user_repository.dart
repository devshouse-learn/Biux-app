import 'dart:convert';
import 'dart:io';
import 'package:biux/data/models/city.dart';
import 'package:biux/data/models/user.dart';
import 'package:biux/data/models/user_membership.dart';
import 'package:biux/data/local_storage/localstorage.dart';
import 'package:biux/data/local_storage/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final URL_BASE = "https://biux-prod.ibacrea.com/api/v1/usuarios";
  final URLT = "biux-prod.ibacrea.com";

  Future<List<BiuxUser>> getUsers(int limit, int offset) async {
    var url = '$URL_BASE?limit=$limit&offset=$offset';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List usersJson = responseData["data"];
    List<BiuxUser> users =
        usersJson.map((usersJson) => BiuxUser.fromJsonMap(usersJson)).toList();

    if (response.statusCode == 200) {
      //200 Created
      //parse json
      return users;
    } else {
      throw Exception('Failed to submit Contact the Devolopers please ');
    }
  }

  Future<bool> login(
    String user,
    String password,
  ) async {
    var uriResponse = await http
        .post(Uri.parse("https://biux-prod.ibacrea.com/api/v1/authenticate"),
            body: jsonEncode({
              "username": user,
              "password": password,
            }),
            headers: {
          'Content-type': 'application/json',
        });

    if (uriResponse.statusCode == 200) {
      final data = json.decode(uriResponse.body);
      String token = data["token"];
      LocalStorage().saveToken(token);
      await LocalStorage().saveUser(user);

      await setLoginToken(token);
      return true;
    } else {
      return false;
    }
  }

  Future<List<BiuxUser>> getUsernames() async {
    var url = '$URL_BASE?&fields=usuario';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List usersJson = responseData["data"];

    List<BiuxUser> users =
        usersJson.map((usersJson) => BiuxUser.fromJsonMap(usersJson)).toList();

    if (response.statusCode == 200) {
      //200 Created
      //parse json
      return users;
    } else {
      throw Exception('Failed to submit Contact the Devolopers please ');
    }
  }

  Future uploadPhoto(
    String id,
    File filePhoto,
  ) async {
    Dio dio = new Dio();
    // dio.options.headers["content-Type"] = "multipart/form-data";
    dio.options.headers["authorization"] = await LocalStorage().getToken();

    FormData formData = FormData.fromMap({
      "filePhoto": await MultipartFile.fromFile(
        filePhoto.path,
      ),
    });

    Response response = await dio.patch(
      'https://biux-prod.ibacrea.com/api/v1/usuarios/$id',
      data: formData,
    );
  }

  Future uploadProfileCover(
    String id,
    File fileProfileCover,
  ) async {
    Dio dio = new Dio();
    // dio.options.headers["content-Type"] = "multipart/form-data";
    dio.options.headers["authorization"] = await LocalStorage().getToken();

    FormData formData = FormData.fromMap({
      "fileProfileCover": await MultipartFile.fromFile(
        fileProfileCover.path,
      ),
    });

    Response response = await dio.patch(
      'https://biux-prod.ibacrea.com/api/v1/usuarios/$id',
      data: formData,
    );
  }

  // Future subirPortada(int id, File fileFoto, File filePortada) async {
  //   Dio dio = new Dio();
  //   // dio.options.headers["content-Type"] = "multipart/form-data";
  //   dio.options.headers["authorization"] = await LocalStorage().obtenerToken();

  //   FormData formData = FormData.fromMap({
  //     "fileFoto": await MultipartFile.fromFile(
  //       fileFoto.path,
  //     ),
  //     "filePortada": await MultipartFile.fromFile(
  //       filePortada.path == "" ? "" : filePortada.path,
  //     ),
  //   });

  //   Response response = await dio.patch(
  //       'https://biux-prod.ibacrea.com/api/v1/usuarios/$id',
  //       data: formData);
  // }

  Future sendEmail(String user) async {
    Dio dio = new Dio();
    // dio.options.headers["content-Type"] = "multipart/form-data";
    //  dio.options.headers["authorization"] = await LocalStorage().obtenerToken();

    FormData formData = new FormData.fromMap({
      "user": user,
    });

    Response response = await dio.post(
      'https://biux-prod.ibacrea.com/api/v1/usuarios/sendEmailPasswordRecovery',
      data: formData,
    );
  }

  Future<BiuxUser> getPerson(String nUsername) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var url =
        '$URL_BASE?usuario=$nUsername&fields=nombres,apellidos,celular,ciudadId,ciudad,correoElectronico,fechaNacimiento,foto,portada,usuario,genero,grupoDestacado.id,id,instagram,facebook,premium';

    var response = await http.get(Uri.parse(url), headers: headers);
    var userVoid = BiuxUser();
    Map<String, dynamic> responseData = json.decode(response.body);

    List personsJson = responseData["data"].toList();
    if (response.statusCode == 200) {
      return BiuxUser.fromJsonMap(personsJson.first);
    } else {
      return userVoid;
    }
  }

  Future<BiuxUser> getUser(String username) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var userVoid = BiuxUser();
    var url = '$URL_BASE?usuario=$username';
    var response = await http.get(Uri.parse(url), headers: headers);

    Map<String, dynamic> responseData = json.decode(response.body);
    List groupJson = responseData["data"].toList();
    if (groupJson.isNotEmpty) {
      return BiuxUser.fromJsonMap(groupJson.first);
    } else {
      return userVoid;
    }
  }

  Future<BiuxUser> getValidationEmails(String email) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    var emailVoid = BiuxUser();
    var url = '$URL_BASE?correoElectronico=$email';
    var response = await http.get(Uri.parse(url), headers: headers);

    Map<String, dynamic> responseData = json.decode(response.body);

    List personsJson = responseData["data"].toList();

    if (personsJson.isEmpty) {
      return emailVoid;
    } else {
      return BiuxUser.fromJsonMap(personsJson.first);
    }
  }

  Future<BiuxUser> getValidationUser(String email) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    var emailVoid = BiuxUser();
    var url = '$URL_BASE?usuario=$email';
    var response = await http.get(Uri.parse(url), headers: headers);

    Map<String, dynamic> responseData = json.decode(response.body);

    List personsJson = responseData["data"].toList();

    if (personsJson.isEmpty) {
      return emailVoid;
    } else {
      return BiuxUser.fromJsonMap(personsJson.first);
    }
  }

  Future<BiuxUser> getValidationFacebook(String facebook) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    var facebookVoid = BiuxUser();
    var url = '$URL_BASE?facebook=$facebook';
    var response = await http.get(Uri.parse(url), headers: headers);

    Map<String, dynamic> responseData = json.decode(response.body);

    List personsJson = responseData["data"].toList();

    if (personsJson.isEmpty) {
      return facebookVoid;
    } else {
      return BiuxUser.fromJsonMap(personsJson.first);
    }
  }

  Future<City> getCityId(String cityName) async {
    var url = 'https://biux-prod.ibacrea.com/api/v1/ciudades?nombre=$cityName';

    var response = await http.get(Uri.parse(url));
    var cityVoid = City();
    Map<String, dynamic> responseData = json.decode(response.body);

    List groupJson = responseData["data"].toList();

    if (groupJson.isNotEmpty) {
      return City.fromJson(json: groupJson.first);
    } else {
      return cityVoid;
    }
  }

  Future<BiuxUser> updateUser(BiuxUser user) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var body = jsonEncode(user.toJson());

    var url = '$URL_BASE/${user.id}';
    final http.Response response =
        await http.patch(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return BiuxUser.fromJsonMap(json.decode(response.body));
    } else {
      throw Exception('Fallo en actualizar usuario');
    }

    //Map<String, dynamic> responseData = json.decode(response.body);
    //return Usuario.fromJsonMap(responseData);

    //return Usuario.fromJsonMap(personasJson.first);
  }

  Future<UserMembership> getMembershipPerson(int id) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var url =
        'https://biux-prod.ibacrea.com/api/v1/usuariosMembresias?usuario.id=$id&estadoMembresia=true';

    var response = await http.get(Uri.parse(url), headers: headers);

    Map<String, dynamic> responseData = json.decode(response.body);

    List personsJson = responseData["data"].toList();

    return UserMembership.fromJsonMap(personsJson.first);
  }

  Future<List<UserMembership>> getMembershipList() async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };
    var url =
        'https://biux-prod.ibacrea.com/api/v1/usuariosMembresias?estadoMembresia=true';

    var response = await http.get(Uri.parse(url), headers: headers);
    Map<String, dynamic> responseData = json.decode(response.body);
    List userMembership = responseData["data"].toList();
    List<UserMembership> finalUserMembresia = userMembership
        .map((userMembresia) => UserMembership.fromJsonMap(userMembresia))
        .toList();
    return finalUserMembresia;
  }

  Future<List<City>> getCities() async {
    var url =
        'https://biux-prod.ibacrea.com/api/v1/ciudades?departamento.paisId=47&export=true';
    var response = await http.get(Uri.parse(url));
    Map responseData = json.decode(response.body);
    List listCities = responseData["data"];
    List<City> cities =
        listCities.map((groupJson) => City.fromJson(json: groupJson)).toList();

    return cities;
  }

  Future<City> getSpecifiCities(String id) async {
    var url = 'https://biux-prod.ibacrea.com/api/v1/ciudades?id=$id';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> responseData = json.decode(response.body);
    List groupJson = responseData["data"].toList();
    return City.fromJson(json: groupJson.first);
  }

  Future<UserMembership> getMembership(UserMembership userMembership) async {
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: await LocalStorage().getToken(),
    };

    var body = jsonEncode(userMembership.toJson());

    var url = 'https://biux-prod.ibacrea.com/api/v1/usuariosMembresias';
    final http.Response response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return UserMembership.fromJsonMap(json.decode(response.body));
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}
