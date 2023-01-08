import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  CollectionReference database = FirebaseFirestore.instance.collection('user');
  late QuerySnapshot querySnapshot;

  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //
  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  //
  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth?.accessToken,
  //     idToken: googleAuth?.idToken,
  //   );
  //
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }




  final userReference = FirebaseFirestore.instance.collection('user');


  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flop[]\w
    final GoogleSignInAccount? googleUser =
    await GoogleSignIn(scopes: <String>["email"]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // saveUserInfoFirestore();
    DocumentSnapshot documentSnapshot =
    await userReference.doc(googleUser.email).get();
    print('google - login');
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  userstart() {
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) async {
      print('회원 관리');
      if (!doc.exists) {
        userReference.doc(FirebaseAuth.instance.currentUser!.uid).set({
          'profileName': FirebaseAuth.instance.currentUser!.displayName!,
          'url': FirebaseAuth.instance.currentUser!.photoURL!,
          'email': FirebaseAuth.instance.currentUser!.email,
          'status_message': 'I promise to take the test honestly before GOD.',
          'uid': FirebaseAuth.instance.currentUser!.uid
        }).whenComplete(() {
          print('완료');
        });
      } else {
        print('이미 있는 아이디');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(20,0,20,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon/icon.png', width: 220,),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: OutlinedButton(
                onPressed: () async {
                  signInWithGoogle();
                  await Future.delayed(Duration(seconds:10));
                  userstart();
                  // Future.delayed(decoration:5);
                  // final UserCredential userCredential = await signInWithGoogle();
                  //
                  // User? user = userCredential.user;
                  //
                  // if (user != null) {
                  //   int i;
                  //   querySnapshot = await database.get();
                  //
                  //   for (i = 0; i < querySnapshot.docs.length; i++) {
                  //     var a = querySnapshot.docs[i];
                  //
                  //     if (a.get('uid') == user.uid) {
                  //       break;
                  //     }
                  //   }
                  //
                  //   if (i == (querySnapshot.docs.length)) {
                  //     database.doc(user.uid).set({
                  //       'email': user.email.toString(),
                  //       'name': user.displayName.toString(),
                  //       'uid': user.uid,
                  //     });
                  //   }
                  //   if (user != null)
                  //     Get.to(Login());
                  // }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icon/google.png', width: 20,),
                    Text("  Sign in with Google",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),),

                  ],
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),),
            )
          ],
        ),
      ),
    );
  }
}