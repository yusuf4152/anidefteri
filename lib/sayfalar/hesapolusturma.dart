import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:anidefteri/servisler/authenticationservisi.dart';
import 'package:anidefteri/servisler/firestoreservisi.dart';
import 'package:flutter/material.dart';

class Hesapolusturma extends StatefulWidget {
  const Hesapolusturma({Key key}) : super(key: key);

  @override
  _HesapolusturmaState createState() => _HesapolusturmaState();
}

class _HesapolusturmaState extends State<Hesapolusturma> {
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldstate = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String eposta;
  String sifre;
  String kullaniciadi;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldstate,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "Hesap oluştur",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: Form(
                key: formstate,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Kullanıcı adınızı giriniz",
                        labelText: "Kullanıcı adı",
                        prefixIcon: Icon(Icons.person_outline_outlined),
                      ),
                      validator: (girilenkullaniciadi) {
                        if (girilenkullaniciadi.isEmpty) {
                          return "Kullanıcı adı boş bırakılamaz";
                        } else if (girilenkullaniciadi.trim().length < 3 ||
                            girilenkullaniciadi.trim().length > 10) {
                          return "Kullanıcı adı 3 karakterden az veya 10 karakterden fazla olamaz";
                        } else
                          return null;
                      },
                      onSaved: (girilenkullaniciadi) {
                        kullaniciadi = girilenkullaniciadi;
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: "Email giriniz",
                          labelText: "Email",
                          prefixIcon: Icon(Icons.mail_outline)),
                      validator: (girilenemail) {
                        if (girilenemail.isEmpty) {
                          return "Email alanı boş bırakılamaz";
                        }
                        if (!girilenemail.contains("@")) {
                          return "Girilen email,email formatına uygun olmalıdır";
                        } else
                          return null;
                      },
                      onSaved: (girilenemail) {
                        eposta = girilenemail;
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: "Şifrenizi giriniz",
                          labelText: "Şifre",
                          prefixIcon: Icon(Icons.lock)),
                      validator: (girilensifre) {
                        if (girilensifre.isEmpty) {
                          return "Şifre alanı boş bırakılamaz";
                        }
                        if (girilensifre.trim().length < 8) {
                          return " Şifre 8 karakterden az olamaz";
                        }
                        return null;
                      },
                      onSaved: (girilensifre) {
                        sifre = girilensifre;
                      },
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                  ],
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 50.0, right: 50.0),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(30.0)),
            child: FlatButton(
                onPressed: _kayitolustur,
                color: Colors.blue,
                child: Text(
                  "Hesap oluştur",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
          )
        ],
      ),
    );
  }

  void _kayitolustur() async {
    if (formstate.currentState.validate()) {
      formstate.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await Authenticationservisi().maililekayit(eposta, sifre);
        if (kullanici != null) {
          await FirestoreServisi().kullaniciolustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciadi: kullaniciadi);
        }
        Navigator.pop(context);
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
    String hatamesaji;
    if (hatakodu == "ERROR_INVALID_EMAIL") {
      hatamesaji = "Geçersiz bir email";
    } else if (hatakodu == "ERROR_WEAK_PASSWORD") {
      hatamesaji = "Şifreniz zayıf bir şifredir";
    } else if (hatakodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hatamesaji = "Bu email kullanılmıştır";
    }
    SnackBar snackBar = SnackBar(content: Text(hatamesaji));
    scaffoldstate.currentState.showSnackBar(snackBar);
  }
}
