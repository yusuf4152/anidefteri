import 'dart:io';
import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:anidefteri/servisler/storageservisi.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Profiliduzenle extends StatefulWidget {
  final Kullanici kullanici;
  const Profiliduzenle({Key key, this.kullanici}) : super(key: key);

  @override
  _ProfiliduzenleState createState() => _ProfiliduzenleState();
}

class _ProfiliduzenleState extends State<Profiliduzenle> {
  File secilenfoto;
  String yenikullaniciadi;
  bool yukleniyor = false;
  @override
  void initState() {
    super.initState();
    yenikullaniciadi = widget.kullanici.kullaniciAdi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "profili düzenle",
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          InkWell(
            onTap: kaydet,
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.update_rounded,
                    color: Colors.white,
                    size: 26.0,
                  ),
                  Text(
                    "güncelle",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 20.0,
          ),
          InkWell(
            onTap: fotografsec,
            child: Hero(
              tag: widget.kullanici.id,
              child: Container(
                margin: EdgeInsets.only(left: 50.0, right: 50.0),
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60.0),
                  color: Colors.blue,
                  image: DecorationImage(
                      image: secilenfoto == null
                          ? widget.kullanici.fotoUrl.isEmpty
                              ? NetworkImage(
                                  "https://cdn.pixabay.com/photo/2018/08/12/16/59/parrot-3601194_960_720.jpg")
                              : NetworkImage(widget.kullanici.fotoUrl)
                          : FileImage(secilenfoto),
                      fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: TextFormField(
              initialValue: widget.kullanici.kullaniciAdi,
              style: TextStyle(color: Colors.deepOrange, fontSize: 20.0),
              textAlign: TextAlign.center,
              decoration: InputDecoration(labelText: "kullanici adi"),
              onChanged: (value) {
                setState(() {
                  yenikullaniciadi = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  kaydet() async {
    setState(() {
      yukleniyor = true;
    });
    String aktifkullaniciid =
        Provider.of<Authenticationservisi>(context, listen: false)
            .aktifkullaniciid;
    String fotourl = widget.kullanici.fotoUrl;
    if (secilenfoto != null) {
      String yenifotourl =
          await Storageservisi().kullaniciresmiyukle(secilenfoto);
      setState(() {
        fotourl = yenifotourl;
      });
    }
    setState(() {
      yukleniyor = false;
    });
    FirestoreServisi().kullaniciguncelle(
      fotourl: fotourl,
      hakkinda: "",
      kullaniciadi: yenikullaniciadi,
      kullaniciid: aktifkullaniciid,
    );

    Navigator.pop(context);
  }

  fotografsec() async {
    PickedFile secilenfotograf = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 600,
        maxWidth: 800);
    setState(() {
      secilenfoto = secilenfotograf != null ? File(secilenfotograf.path) : null;
    });
  }
}
