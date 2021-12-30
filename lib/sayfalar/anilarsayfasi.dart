import 'dart:ui';
import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:anidefteri/modeller/ani.dart';
import 'package:anidefteri/sayfalar/aniarama.dart';
import 'package:anidefteri/sayfalar/profilduzenlemesayfasi.dart';
import 'package:anidefteri/sayfalar/tekanisayfasi.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Anilarsayfasi extends StatefulWidget {
  const Anilarsayfasi({Key key}) : super(key: key);

  @override
  _AnilarsayfasiState createState() => _AnilarsayfasiState();
}

class _AnilarsayfasiState extends State<Anilarsayfasi> {
  String aktifkullaniciid;
  @override
  void initState() {
    super.initState();
    aktifkullaniciid =
        Provider.of<Authenticationservisi>(context, listen: false)
            .aktifkullaniciid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.search_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Aniarama(),
                ));
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "Anılarım",
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 30.0, color: Colors.white),
            onPressed: () {
              Authenticationservisi authenticationservisi =
                  Provider.of<Authenticationservisi>(context, listen: false);
              authenticationservisi.cikisyap();
            },
          )
        ],
      ),
      body: FutureBuilder<Kullanici>(
        future: FirestoreServisi().kullanicigetir(aktifkullaniciid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          Kullanici kullanici = snapshot.data;
          return ListView(
            children: [
              profilbilgileri(kullanici),
              SizedBox(
                height: 20.0,
              ),
              anilaringorunumu(),
            ],
          );
        },
      ),
    );
  }

  Widget profilbilgileri(Kullanici kullanici) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[100],
              blurRadius: 15.0,
              offset: Offset(5.0, 5.0),
            )
          ]),
      height: 150.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10.0,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profiliduzenle(
                      kullanici: kullanici,
                    ),
                  ));
            },
            child: Hero(
              tag: kullanici.id,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                backgroundImage: kullanici.fotoUrl.isEmpty
                    ? NetworkImage(
                        "https://cdn.pixabay.com/photo/2018/08/12/16/59/parrot-3601194_960_720.jpg")
                    : NetworkImage(kullanici.fotoUrl),
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Text(
            "${kullanici.kullaniciAdi}",
            style: TextStyle(color: Colors.black, fontSize: 20.0),
          )
        ],
      ),
    );
  }

  Widget anilaringorunumu() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreServisi().anilarigetir(aktifkullaniciid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length == 0) {
          return Center(
            child: Text("Henüz hiç anınız yok..."),
          );
        }
        List<Ani> fayanslar = snapshot.data.documents
            .map((doc) => Ani.dokumandanUret(doc))
            .toList();
        List<Widget> widgetfayanslarr = [];
        fayanslar.forEach((ani) {
          widgetfayanslarr.add(fayansolustur(ani));
        });
        return GridView.count(
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          crossAxisCount: 3,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 15.0,
          children: widgetfayanslarr,
        );
      },
    );
  }

  fayansolustur(Ani ani) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Tekanisayfasi(
                ani: ani,
              ),
            ));
      },
      onLongPress: () => anisilmesecnekleri(ani),
      child: Hero(
        tag: ani.id,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Image.network(
              ani.fotourl,
              fit: BoxFit.cover,
            ),
          ),
          semanticContainer: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Colors.green, width: 2.0)),
        ),
      ),
    );
  }

  anisilmesecnekleri(Ani ani) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Anıyı silmek istediğinize emin misiniz?"),
          children: [
            SimpleDialogOption(
              child: Text("Evet"),
              onPressed: () => anisil(ani),
            ),
            SimpleDialogOption(
              child: Text("Hayır"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  anisil(Ani anii) async {
    await FirestoreServisi().anisil(
        aniid: anii.id, anifotoid: anii.fotourl, kullaniciid: aktifkullaniciid);
    Navigator.pop(context);
  }
}
