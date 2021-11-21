import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:apple_sign_in/apple_sign_in.dart';

// class AppleSignInAvailable {
//   AppleSignInAvailable(this.isAvailable);
//   final bool isAvailable;

//   static Future<AppleSignInAvailable> check() async {
//     return AppleSignInAvailable(await AppleSignIn.isAvailable());
//   }
// }

class UserDetails {
  final String phoneNumber;
  final String fullName;
  final String email;
  final String location;
  final String profilePicture;
  final String accountType;
  UserDetails(
      {this.phoneNumber,
      this.fullName,
      this.email,
      this.location,
      this.profilePicture,
      this.accountType});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
        phoneNumber: json['phoneNumber'],
        fullName: json['phoneNumber'],
        email: json['email'],
        location: json['location'],
        profilePicture: json['profilePicture'],
        accountType: json['accountType']);
  }
}

class UserNew {
  final bool isNew;
  UserNew({this.isNew});
  factory UserNew.fromJson(Map<String, dynamic> json) {
    return UserNew(isNew: json['isNew']);
  }
}

class AuthService {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  Observable<FirebaseUser> user;
  AuthService() {
    user = Observable(_firebaseAuth.onAuthStateChanged);
  }

  // Future<FirebaseUser> signInWithApple({List<Scope> scopes = const []}) async {
  //   // 1. perform the sign-in request
  //   //  final isReady =  await AppleSignInAvailable.check();
  //   //  print(isReady.isAvailable);

  //   //   if(isReady.isAvailable){
  //   //     final result = await AppleSignIn.performRequests(
  //   //       [AppleIdRequest(requestedScopes: scopes)]);
  //   //   // 2. check the result
  //   //   switch (result.status) {
  //   //     case AuthorizationStatus.authorized:
  //   //       final appleIdCredential = result.credential;
  //   //       final oAuthProvider = OAuthProvider(providerId: 'apple.com');
  //   //       final credential = oAuthProvider.getCredential(
  //   //         idToken: String.fromCharCodes(appleIdCredential.identityToken),
  //   //         accessToken:
  //   //             String.fromCharCodes(appleIdCredential.authorizationCode),
  //   //       );
  //   //       final authResult = await _firebaseAuth.signInWithCredential(credential);
  //   //       final firebaseUser = authResult.user;

  //   //       if (scopes.contains(Scope.fullName)) {
  //   //         final updateUser = UserUpdateInfo();
  //   //         updateUser.displayName =
  //   //             '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
  //   //         await firebaseUser.updateProfile(updateUser);
  //   //       }
  //   //       return firebaseUser;
  //   //     case AuthorizationStatus.error:
  //   //       print(result.error.toString());
  //   //       throw PlatformException(
  //   //         code: 'ERROR_AUTHORIZATION_DENIED',
  //   //         message: result.error.toString(),
  //   //       );

  //   //     case AuthorizationStatus.cancelled:
  //   //       throw PlatformException(
  //   //         code: 'ERROR_ABORTED_BY_USER',
  //   //         message: 'Sign in aborted by user',
  //   //       );
  //   //   }
  //   //   }else{
  //   //     print(isReady.isAvailable);
  //   //     // print(isReady.)
  //   //     print('IOS AUTH NOT AVATILABLE');
  //   //   }
  //   //return null;
  // }

  void signOut() async {
    await _firebaseAuth.signOut();
  }
}

final AuthService authService = AuthService();
