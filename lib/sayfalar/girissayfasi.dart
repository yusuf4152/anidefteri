import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:anidefteri/sayfalar/hesapolusturma.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Girissayfasi extends StatefulWidget {
  const Girissayfasi({Key key}) : super(key: key);

  @override
  _GirissayfasiState createState() => _GirissayfasiState();
}

class _GirissayfasiState extends State<Girissayfasi> {
  final GlobalKey<FormState> _formanahtari = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldstate = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String eposta, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldstate,
      body: Stack(
        children: [
          _sayfaninelemanlari(),
          yukleniyoranimasyonu(),
        ],
      ),
    );
  }

  Widget yukleniyoranimasyonu() {
    if (yukleniyor) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SizedBox(
        height: 0.0,
      );
    }
  }

  Widget _sayfaninelemanlari() {
    return Form(
      key: _formanahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 60.0),
        children: [
          SizedBox(
            height: 40.0,
          ),
          FlutterLogo(
            size: 100.0,
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: "Email adresinizi girin",
                prefixIcon: Icon(Icons.mail_outline),
                errorStyle: TextStyle(fontWeight: FontWeight.bold)),
            validator: (girdigideger) {
              if (girdigideger.isEmpty) {
                return "Email alanı boş bırakılamaz";
              }
              if (!girdigideger.contains("@")) {
                return "Email içinde @ olmalıdır";
              } else
                return null;
            },
            onSaved: (girdigideger) {
              eposta = girdigideger;
            },
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              errorStyle: TextStyle(fontWeight: FontWeight.bold),
              hintText: "Şifrenizi girin",
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (girdigideger) {
              if (girdigideger.isEmpty) {
                return "Şifre alanı boş bırakılamaz";
              }
              if (girdigideger.trim().length < 8) {
                return "Şifre alanı 8 karakterden az olamaz";
              } else
                return null;
            },
            onSaved: (girilensifre) {
              sifre = girilensifre;
            },
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                child: Text(
                  "Giriş yap",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _girisyap,
                color: Colors.blue,
              ),
              SizedBox(
                width: 20.0,
              ),
              FlatButton(
                child: Text(
                  "Hesap oluştur",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Hesapolusturma(),
                  ));
                },
                color: Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 30.0),
          Container(margin: EdgeInsets.only(left: 150.0), child: Text("veya")),
          SizedBox(
            height: 10.0,
          ),
          Container(
            margin: EdgeInsets.only(left: 80.0),
            child: GestureDetector(
              onTap: _googleilegiris,
              child: Text(
                "Google ile giriş yap",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _googleilegiris() async {
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await Authenticationservisi().googleilegiris();
      if (kullanici != null) {
        Kullanici kullanicivarmi =
            await FirestoreServisi().kullanicigetir(kullanici.id);
        if (kullanicivarmi == null) {
          await FirestoreServisi().kullaniciolustur(
              email: kullanici.email,
              id: kullanici.id,
              fotourl: kullanici.fotoUrl,
              kullaniciadi: kullanici.kullaniciAdi);
          print("kullanıcı kaydı oldu");
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      hatagoster(hata.code);
    }
  }

  void _girisyap() async {
    final Authenticationservisi _authenticationservisi =
        Provider.of(context, listen: false);

    if (_formanahtari.currentState.validate()) {
      _formanahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await _authenticationservisi.maililegiris(eposta, sifre);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        print(hata);
        hatagoster(hata.code);
      }
    }
  }

  hatagoster(String hatakodu) {
    String hata;
    if (hatakodu == "ERROR_INVALID_EMAIL") {
      hata = "Geçersiz bir emaildir";
    } else if (hatakodu == "ERROR_USER_NOT_FOUND") {
      hata = "Kullanıcı bulunamadı";
    } else if (hatakodu == "ERROR_USER_DISABLED") {
      hata = "Kullanıcı engellenmiş";
    } else if (hatakodu == "ERROR_WRONG_PASSWORD") {
      hata = "Yanlış şifre";
    }
    SnackBar snackBar = SnackBar(content: Text(hata));
    _scaffoldstate.currentState.showSnackBar(snackBar);
  }
}
