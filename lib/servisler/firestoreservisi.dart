import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:anidefteri/modeller/ani.dart';
import 'package:anidefteri/servisler/storageservisi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class FirestoreServisi {
  final Firestore _firestore = Firestore.instance;
  DateTime zaman = DateTime.now();
  Future<void> kullaniciolustur(
      {String id,
      String kullaniciadi,
      String email,
      String fotourl = ""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "kullaniciadi": kullaniciadi,
      "email": email,
      "kullaniciid": id,
      "fotourl": fotourl,
      "olusturulmazamani": zaman,
      "hakkinda": ""
    });
  }

  Future<Kullanici> kullanicigetir(String id) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection("kullanicilar").document(id).get();
    if (!documentSnapshot.exists) {
      return null;
    } else {
      return Kullanici.dokumandanUret(documentSnapshot);
    }
  }

  Future<void> kullaniciguncelle(
      {String kullaniciadi,
      String hakkinda,
      String kullaniciid,
      String fotourl = ""}) {
    _firestore.collection("kullanicilar").document(kullaniciid).updateData({
      "kullaniciadi": kullaniciadi,
      "hakkinda": hakkinda,
      "fotourl": fotourl
    });
  }

  Future<void> aniekle(
      {String yayinlayanid, String resimurl, String icerik, String konum}) {
    _firestore
        .collection("anilar")
        .document(yayinlayanid)
        .collection("kullanicininanilari")
        .add({
      "yayinlayanid": yayinlayanid,
      "fotourl": resimurl,
      "icerik": icerik,
      "konum": konum.toLowerCase(),
      "olusturlmazamani": zaman,
    });
  }

  Stream<QuerySnapshot> anilarigetir(String aktifkullaniciid) {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection("anilar")
        .document(aktifkullaniciid)
        .collection("kullanicininanilari")
        .orderBy("olusturlmazamani", descending: true)
        .snapshots();
    return snapshot;
  }

  Stream<QuerySnapshot> sorguluanilarigetir(String kullaniciid, String mesaj) {
    Stream<QuerySnapshot> sorgular = _firestore
        .collection("anilar")
        .document(kullaniciid)
        .collection("kullanicininanilari")
        .where("konum", isEqualTo: mesaj.toLowerCase())
        .snapshots();
    return sorgular;
  }

  Future<void> aniguncelle(
      {String anisahibiid,
      String aniid,
      String yenikonum,
      String yeniicerik}) async {
    await _firestore
        .collection("anilar")
        .document(anisahibiid)
        .collection("kullanicininanilari")
        .document(aniid)
        .updateData({
      "konum": yenikonum.toLowerCase(),
      "icerik": yeniicerik,
    });
  }

  Future<void> anisil(
      {String kullaniciid, String anifotoid, String aniid}) async {
    // aniyi anılar koleksiyonundan sil
    DocumentSnapshot doc = await _firestore
        .collection("anilar")
        .document(kullaniciid)
        .collection("kullanicininanilari")
        .document(aniid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    // aninin fotosunu strogeden sil
    Storageservisi().aniresmisil(anifotoid);
  }
}
