import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<FirebaseUser> signInWithGoogle() async {
  try{
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult user = await _auth.signInWithCredential(credential);

    assert(!user.user.isAnonymous);
    assert(await user.user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.user.uid == currentUser.uid);

    return user.user;
  }

  catch(error){
    throw error;
  }
}