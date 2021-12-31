import 'dart:io';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:anidefteri/servisler/storageservisi.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class YUklemesayfasii extends StatefulWidget {
  const YUklemesayfasii({Key key}) : super(key: key);

  @override
  _YUklemesayfasiiState createState() => _YUklemesayfasiiState();
}

class _YUklemesayfasiiState extends State<YUklemesayfasii> {
  File dosya = null;
  TextEditingController anikontrol = TextEditingController();
  TextEditingController konumkontrol = TextEditingController();
  bool yukleniyor = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yUklemebutonu() : secilenfotografveyaziyeri();
  }

  Scaffold yUklemebutonu() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yükleme"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Row(
        children: [
          InkWell(
            onTap: fotografcek,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                          image: AssetImage("assets/kamera/kamerafoto.jpg"),
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Text(
                    "Fotoğraf Çek",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: galeridensec,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                          image:
                              AssetImage("assets/galeri/dusukgalerifoto.jpg"),
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Text(
                    "Galeriden seç",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Scaffold secilenfotografveyaziyeri() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "Yükleme",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              dosya = null;
            });
          },
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 28.0,
              ),
              onPressed: anikaydet)
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Image.file(
                dosya,
                fit: BoxFit.cover,
              )),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: konumkontrol,
              decoration: InputDecoration(
                hintText: "Konumunuzu Girin",
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: anikontrol,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Anınızı Girin",
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }

  fotografcek() async {
    PickedFile cekilenfotograf = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    if (cekilenfotograf == null) {
      return;
    }
    setState(() {
      dosya = File(cekilenfotograf.path);
    });
  }

  galeridensec() async {
    PickedFile secilenfotograf = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 600,
        maxWidth: 800);
    if (secilenfotograf == null) {
      return;
    }
    setState(() {
      dosya = File(secilenfotograf.path);
    });
  }

  anikaydet() async {
    String aktifkullaniciid =
        Provider.of<Authenticationservisi>(context, listen: false)
            .aktifkullaniciid;
    setState(() {
      yukleniyor = true;
    });
    String gelenresimurl = await Storageservisi().aniresmiyukle(dosya);
    FirestoreServisi().aniekle(
        icerik: anikontrol.text,
        konum: konumkontrol.text,
        yayinlayanid: aktifkullaniciid,
        resimurl: gelenresimurl);
    setState(() {
      yukleniyor = false;
      anikontrol.clear();
      konumkontrol.clear();
      dosya = null;
    });
  }
}
