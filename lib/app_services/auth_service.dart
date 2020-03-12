import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class UserDetails {
  final String phoneNumber;
  final String fullName;
  final String email;
  final String location;
  final String profilePicture;
  final String accountType;
  UserDetails({this.phoneNumber,this.fullName,this.email,this.location,
    this.profilePicture, this.accountType});

  factory UserDetails.fromJson(Map<String, dynamic> json){
    return UserDetails(
        phoneNumber: json['phoneNumber'],
        fullName: json['phoneNumber'],
        email: json['email'],
        location: json['location'],
        profilePicture: json['profilePicture'],
        accountType: json['accountType']
    );
  }

}

class UserNew {
  final bool isNew;
  UserNew({this.isNew});
  factory UserNew.fromJson(Map<String, dynamic> json){
    return UserNew(
      isNew: json['isNew']
    );
  }

}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Observable<FirebaseUser> user;
  AuthService(){
    user = Observable(_auth.onAuthStateChanged);
  }




  void signOut() async {
 await _auth.signOut();
  }

}

final AuthService authService = AuthService();