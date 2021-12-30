import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:anidefteri/sayfalar/anasayfa.dart';
import 'package:anidefteri/sayfalar/girissayfasi.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Authenticationservisi _authenticationservisi =
        Provider.of(context, listen: false);
    return StreamBuilder<Kullanici>(
      stream: _authenticationservisi.giristakibi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          _authenticationservisi.aktifkullaniciid = snapshot.data.id;
          print(snapshot.data.id);
          return Anasayfa();
        }

        return Girissayfasi();
      },
    );
  }
}
