import 'package:anidefteri/sayfalar/anilarsayfasi.dart';
import 'package:anidefteri/sayfalar/yuklemesayfasii.dart';
import 'package:flutter/material.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({Key key}) : super(key: key);

  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int mevcutsayfa = 0;
  PageController sayfakontrol;
  @override
  void initState() {
    super.initState();
    sayfakontrol = PageController();
  }

  @override
  void dispose() {
    sayfakontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (gelensayfasayisi) {
          setState(() {
            mevcutsayfa = gelensayfasayisi;
          });
        },
        controller: sayfakontrol,
        children: [
          YUklemesayfasii(),
          Anilarsayfasi(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: mevcutsayfa,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_sharp),
            title: Text("Anı yükle"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              title: Text("Anılarım")),
        ],
        onTap: (tiklanansayi) {
          setState(() {
            sayfakontrol.jumpToPage(tiklanansayi);
          });
        },
      ),
    );
  }
}
