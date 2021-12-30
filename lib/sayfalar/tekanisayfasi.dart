import 'package:anidefteri/modeller/ani.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tekanisayfasi extends StatefulWidget {
  final Ani ani;
  const Tekanisayfasi({Key key, this.ani}) : super(key: key);

  @override
  _TekanisayfasiState createState() => _TekanisayfasiState();
}

class _TekanisayfasiState extends State<Tekanisayfasi> {
  String yenikonum;
  String yeniicerik;
  String aktfikullaniciid;
  @override
  void initState() {
    super.initState();
    yenikonum = widget.ani.konum;
    yeniicerik = widget.ani.icerik;
    aktfikullaniciid =
        Provider.of<Authenticationservisi>(context, listen: false)
            .aktifkullaniciid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "Anı",
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        actions: [
          InkWell(
            onTap: aniguncelle,
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
        padding: EdgeInsets.only(left: 5.0, right: 5.0),
        children: [
          SizedBox(
            height: 20.0,
          ),
          Hero(
            tag: widget.ani.id,
            child: InteractiveViewer(
              maxScale: 2.0,
              minScale: 0.2,
              boundaryMargin: EdgeInsets.all(30.0),
              child: Image(
                image: NetworkImage(widget.ani.fotourl),
                fit: BoxFit.cover,
                height: 300.0,
                width: 400.0,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          widget.ani.konum == null
              ? SizedBox(
                  height: 0.0,
                )
              : Center(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: widget.ani.konum.isEmpty
                        ? "konum yok"
                        : widget.ani.konum,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                        color: Colors.deepOrangeAccent, fontSize: 22.0),
                    onChanged: (value) {
                      setState(() {
                        yenikonum = value;
                      });
                    },
                  ),
                ),
          SizedBox(
            height: 25.0,
          ),
          Center(
              child: TextFormField(
            textAlign: TextAlign.center,
            initialValue: widget.ani.icerik.isEmpty
                ? "anı girilmemiş"
                : widget.ani.icerik,
            decoration: InputDecoration(border: InputBorder.none),
            maxLines: null,
            onChanged: (value) {
              setState(() {
                yeniicerik = value;
              });
            },
          )),
        ],
      ),
    );
  }

  aniguncelle() async {
    await FirestoreServisi().aniguncelle(
      anisahibiid: aktfikullaniciid,
      aniid: widget.ani.id,
      yeniicerik: yeniicerik,
      yenikonum: yenikonum,
    );
    Navigator.pop(context);
  }
}
