import 'package:anidefteri/modeller/ani.dart';
import 'package:anidefteri/sayfalar/tekanisayfasi.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Aniarama extends StatefulWidget {
  const Aniarama({Key key}) : super(key: key);

  @override
  _AniaramaState createState() => _AniaramaState();
}

class _AniaramaState extends State<Aniarama> {
  bool anilargeldimi = false;
  TextEditingController mesaj;
  String aktifkullaniciid;
  @override
  void initState() {
    super.initState();
    mesaj = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue,
        title: TextFormField(
          controller: mesaj,
          style: TextStyle(color: Colors.white, fontSize: 18.0),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "aramak istediğiniz konumu girin",
            hintStyle: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10.0),
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  Icons.search_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    anilargeldimi = true;
                  });
                },
              )),
        ],
      ),
      body: !anilargeldimi
          ? Center(
              child: Text("anilari konumlarina göre arayabilirsiniz..."),
            )
          : anilarigoster(),
    );
  }

  anilarigoster() {
    String kullaniciid =
        Provider.of<Authenticationservisi>(context, listen: false)
            .aktifkullaniciid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreServisi().sorguluanilarigetir(kullaniciid, mesaj.text),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length == 0) {
          return Center(
            child: Text("arama sonucu bulunamadı"),
          );
        }
        List<Ani> anilarr = snapshot.data.documents
            .map((doc) => Ani.dokumandanUret(doc))
            .toList();
        return ListView.builder(
          padding: EdgeInsets.only(top: 10.0),
          itemCount: anilarr.length,
          itemBuilder: (context, index) {
            return anisatiri(anilarr[index]);
          },
        );
      },
    );
  }

  anisatiri(Ani ani) {
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
      child: Container(
        margin: EdgeInsets.only(left: 20.0, bottom: 40.0),
        child: Row(
          children: [
            Hero(
              tag: ani.id,
              child: Container(
                height: 120.0,
                width: 120.0,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                        image: NetworkImage(ani.fotourl), fit: BoxFit.cover)),
              ),
            ),
            SizedBox(
              width: 40.0,
            ),
            Text(
              ani.konum,
              style: TextStyle(color: Colors.deepOrange, fontSize: 18.0),
            )
          ],
        ),
      ),
    );
  }
}
