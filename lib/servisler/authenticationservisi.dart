import 'package:anidefteri/modeller/Kullanici.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authenticationservisi {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String aktifkullaniciid;
  Kullanici _kullaniciolustur(FirebaseUser firebaseUser) {
    return firebaseUser == null
        ? null
        : Kullanici.firebasedenUret(firebaseUser);
  }

  Stream<Kullanici> get giristakibi {
    return _firebaseAuth.onAuthStateChanged.map(_kullaniciolustur);
  }

  Future<Kullanici> maililekayit(String eposta, String sifre) async {
    AuthResult giriskarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciolustur(giriskarti.user);
  }

  Future<Kullanici> maililegiris(String eposta, String sifre) async {
    AuthResult giriskarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciolustur(giriskarti.user);
  }

  Future<Kullanici> googleilegiris() async {
    GoogleSignInAccount googlehesapkarti = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleyetkikarti =
        await googlehesapkarti.authentication;
    AuthCredential onaylatilmisgoogleyetkikarti =
        GoogleAuthProvider.getCredential(
            idToken: googleyetkikarti.idToken,
            accessToken: googleyetkikarti.accessToken);
    AuthResult giriskarti =
        await _firebaseAuth.signInWithCredential(onaylatilmisgoogleyetkikarti);
    return _kullaniciolustur(giriskarti.user);
  }

  Future<void> cikisyap() {
    return _firebaseAuth.signOut();
  }
}
