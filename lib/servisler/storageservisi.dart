import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Storageservisi {
  StorageReference _storageservisi = FirebaseStorage().ref();
  // storage ref bize depolama alanının referansını döner
  String resimid;
  Future<String> aniresmiyukle(File file) async {
    resimid = Uuid().v4();
    StorageUploadTask yuklemeyoneticisi =
        _storageservisi.child("resimler/anilar/ani_$resimid.jpg").putFile(file);
    StorageTaskSnapshot snapshot = await yuklemeyoneticisi.onComplete;
    String resimurl = await snapshot.ref.getDownloadURL();
    return resimurl;
  }

  Future<String> kullaniciresmiyukle(File file) async {
    resimid = Uuid().v4();
    StorageUploadTask yuklemeyoneticisi = _storageservisi
        .child("resimler/kullanicilar/kullanici_$resimid.jpg")
        .putFile(file);
    StorageTaskSnapshot snapshot = await yuklemeyoneticisi.onComplete;
    String resimurl = await snapshot.ref.getDownloadURL();
    return resimurl;
  }

  aniresmisil(String aniid) {
    RegExp kural = RegExp(r"ani_.+\.jpg");
    var eslesengonderi = kural.firstMatch(aniid);
    String dosyaadi = eslesengonderi[0];
    if (dosyaadi != null) {
      _storageservisi.child("resimler/anilar/$dosyaadi").delete();
    }
  }
}
