import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/yonlendirme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/galeri/dusukgalerifoto.jpg"), context);
    precacheImage(AssetImage("assets/kamera/kamerafoto.jpg"), context);
    return Provider<Authenticationservisi>(
      create: (context) => Authenticationservisi(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Yonlendirme(),
      ),
    );
  }
}
