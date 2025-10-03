import 'dart:io';
import 'package:biux/data/models/bike.dart';
import 'package:biux/data/repositories/bikes/bike_repository_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:biux/core/config/strings.dart';

class BikeFirebaseRepository extends BikeRepositoryAbstract {
  static final collection = 'bikes';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future getBike() {
    // TODO: implement getBike
    throw UnimplementedError();
  }

  @override
  Future<Bike> getBikeRoad(String id) async {
    late Bike bike;
    try {
      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get();
      final data = result.docs
          .map(
            (e) => Bike.fromjson(
              e.data(),
            ),
          )
          .first;
      return data;
    } catch (e) {
      return Bike();
    }
  }

  @override
  Future createDatesBike(Bike bike) async {
    try {
      await firestore.collection(collection).add(bike.toJson()).then(
      (DocumentReference doc) {
        String docId = doc.id;
        firestore.collection(collection).doc(docId).update(
          {
            AppStrings.idText: docId,
          },
        );
      },
    );
    } catch (e) {}
  }

  @override
  Future<Bike> updateDatesBike(Bike bike) async {
    try {
      await firestore
          .collection(collection)
          .doc(bike.id.toString())
          .update(bike.toJson());

      await firestore
          .collection(collection)
          .doc(bike.id.toString())
          .update(bike.toJson());

      final result = await firestore
          .collection(collection)
          .where('id', isEqualTo: bike.id.toString())
          .get();
      return Bike.fromjson(
        result.docs.first.data(),
      );
    } catch (e) {
      return Bike();
    }
  }

  @override
  Future uploadBike(
    String id,
    File photoBikeComplete,
    File photoInvoice,
    File photoFrontal,
    File photoGroupBike,
    File photoSerial,
    File photoOwnershipCard,
  ) async {
    await this.uploadImageBike(
      imageFolder: '1111',
      nameImage: 'photo-bike-complete',
      image: photoBikeComplete,
      name: 'photoBikeComplete',
      id: id,
    );

    await this.uploadImageBike(
      imageFolder: '1111',
      nameImage: 'photo-invoice',
      image: photoInvoice,
      name: 'photoInvoice',
      id: id,
    );

    await this.uploadImageBike(
      imageFolder: '1111',
      nameImage: 'photo-frontal',
      image: photoFrontal,
      name: 'photoFrontal',
      id: id,
    );

    await this.uploadImageBike(
      imageFolder: '1111',
      nameImage: 'photo-groupBike',
      image: photoGroupBike,
      name: 'photoGroupBike',
      id: id,
    );

    await this.uploadImageBike(
      imageFolder: '1111',
      nameImage: 'photo-serial',
      image: photoSerial,
      name: 'photoSerial',
      id: id,
    );

    await this.uploadImageBike(
      imageFolder: '1111',
      nameImage: 'photo-ownership-card',
      image: photoOwnershipCard,
      name: 'photoOwnershipCard',
      id: id,
    );
  }

  Future uploadImageBike({
    required String imageFolder,
    required String nameImage,
    required File image,
    required String name,
    required String id,
  }) async {
    try {
      Reference ref = FirebaseStorage.instance.ref('$imageFolder/$nameImage');
      UploadTask uploadTask = ref.putFile(image);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      await this.updateImage(name, downloadUrl, id);
    } catch (e) {}
  }

  Future updateImage(String name, String urlImage, String id) async {
    var reference = FirebaseFirestore.instance.collection(collection);
    reference.doc(id).update({
      name: urlImage,
    });
  }
}
