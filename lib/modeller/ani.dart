import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Ani {
  final String id;
  final String yayinlayanid;
  final String fotourl;
  final String icerik;
  final String konum;
  final String olusturulmazamani;

  Ani({
    @required this.id,
    this.yayinlayanid,
    this.fotourl,
    this.icerik,
    this.konum,
    this.olusturulmazamani,
  });

  factory Ani.dokumandanUret(DocumentSnapshot doc) {
    return Ani(
        id: doc.documentID,
        yayinlayanid: doc['yayinlayanid'],
        fotourl: doc['fotourl'],
        icerik: doc['icerik'],
        konum: doc['konum'],
        olusturulmazamani: doc["olusturulmazamani"]);
  }
}
