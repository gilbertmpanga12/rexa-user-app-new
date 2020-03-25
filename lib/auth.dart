import 'dart:async';
// added new changes +++
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:apple_sign_in/scope.dart';

import './swiper.dart';
import './terms_and_conditions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'app_services/auth_service.dart';


class UserNew {
  final bool isNew;
  UserNew({this.isNew});
  factory UserNew.fromJson(Map<String, dynamic> json){
    return UserNew(
        isNew: json['isNew']
    );
  }

}

class SignIn extends StatefulWidget{
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String authId = randomAlpha(10);
  String _textCtaUser = 'SIGN IN';
  double _sizedBoxHeight;
  bool showSpinner = false;
  double paddingTitle;
  var location = new Location();
  bool isNew;
  String _defaultCode;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  // String _message = '';
  bool _verificationId = false;
  bool showSmsCode = false;
  String smsTxt = 'Enter SMS Code';
  int times = 0;
  Timer clocker;
  Timer clockerOverDialog;
  bool isSmsfied;
  Timer autoVerifier;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isSms = false;
  String fcm_token;

  _getLocation() async {
    var currentLocation;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    fcm_token = status.subscriptionStatus.userId;
    prefs.setString('fcm_token', status.subscriptionStatus.userId);

    try {
      currentLocation  = await location.getLocation();
      prefs.setDouble('lat', currentLocation.latitude);
      prefs.setDouble('long', currentLocation.longitude);
      isNew = prefs.getBool('isNew');
    } catch (e) {
      print('Failed to get location');
    }
  }

Widget defaultButtonText() {
    return showSpinner ? SizedBox(child: 
    CircularProgressIndicator(backgroundColor: Colors.white,),
    height: 17.5,width: 17.5,) : Row(
                    children: <Widget>[
                 Text('$_textCtaUser',
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.6,
                          fontFamily: 'NunitoSans'
                          )
                )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  );
  }

  Widget defaultButtonTextSms(){
    return isSms ? SizedBox(child: 
    CircularProgressIndicator(backgroundColor: Colors.white,),
    height: 17.5,width: 17.5,) : Text('$smsTxt',style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,fontSize:18.0, fontFamily: 'NunitoSans'),textAlign: TextAlign.center,);
  }


Widget showCountries(){
  return Container(child: CountryCodePicker(
    padding: EdgeInsets.only(right: 16.0),
         onChanged: _onCountryChange,
         // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
         initialSelection: 'IT',
         favorite: ['+256','UG'],
         // optional. Shows only country name and flag
         showCountryOnly: true,
         // optional. aligns the flag and the Text left
         alignLeft: false
       ),margin: EdgeInsets.only(top:8.0),);
}


void _onCountryChange(CountryCode countryCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
    this._defaultCode = countryCode.toString();
    print(this._defaultCode);
    prefs.setString('countryCode', countryCode.code);
    prefs.setString('iso_code', countryCode.toString());
    prefs.setString('immutableCountryCode', countryCode.code);
    
  }

  void initState(){
    _getLocation();
    super.initState();
  }

  @override
  void dispose(){
  clockRemover();
    super.dispose();
  }



  Future<dynamic> errorDialog(String  errorMessage) async{
     try {
        await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                         shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20.0))
),
                  title: Text('Oops something went wrong'),
                  content: Container(child: Text('$errorMessage'),width: 200.0,),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        clockRemover();
                       setState(() {
                         _textCtaUser = 'SIGN IN';
                         smsTxt = 'Enter SMS Code';
                         this._verificationId = null;
                       });
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                    )
                  ],
                );
              });
  setState(() {
  showSpinner = false;
  _verificationId = false;
 _phoneNumberController.clear();
    });
     }catch(e){
setState(() {
  showSpinner = false;
  _verificationId = false;
 _phoneNumberController.clear();
    });
     }
  }

setClocks() async{
  clockerOverDialog =  Timer(const Duration(minutes: 9), (){
errorDialog('Timeout for entering SMS code expired');
    }); // fires when code expired
    try{
      if(mounted){
    clocker =    Timer.periodic(const Duration(seconds: 1), (e){
print('yes');
      if(times < 559){
        setState(() {
        times++;
      }); // fires after 120 seconds
        
     }else{
       e.cancel();
     }
      
     
    });
      }
    }catch(e){
      print(e);
    }
}

  void verifyPhoneNumber(String phoneNumber) async {
    if(mounted){
   setState(() {
  showSpinner = true;
  });
  }
    try{
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final AuthCredential userCreadentialize = GoogleAuthProvider.getCredential(
     accessToken: googleAuth.accessToken,
     idToken: googleAuth.idToken,
   );
    _auth.signInWithCredential(userCreadentialize).then((AuthResult user){
    prefs.setString('token', '${googleAuth.idToken}');
    prefs.setString('customNumber', phoneNumber);
    prefs.setString('email', '${user.user.email}');
    prefs.setString('uid', phoneNumber);
    prefs.setString('phoneNumber', phoneNumber);// causes chat bug if missing
    prefs.setString('profilePicture', '${user.user.photoUrl}');
    prefs.setString('fullName', '${user.user.displayName}');
    // prefs.setString('fcm_token', newuser.data['fcm_token']);
    Firestore.instance.collection('users').document(phoneNumber).get().then((newuser){
      if(newuser.exists){
        prefs.setBool('isNewUser', false);
        prefs.setBool('isSignedIn', true);
        prefs.setString('iso_code', newuser.data['iso_code']);
        prefs.setString('fullName', newuser.data['fullName']); 
        prefs.setString('countryCode', newuser.data['country_code']);
        prefs.setString('profilePicture', newuser.data['profilePicture']);
        prefs.setDouble('long', newuser.data['longitude']);
        prefs.setDouble('lat', newuser.data['latitude']); // fcm_token
        prefs.setString('fcm_token', newuser.data['fcm_token']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Swiper()));
      }else{

    http.get(
    'https://young-tor-95342.herokuapp.com/verify-user/${_phoneNumberController.text}/$_defaultCode').then((res){
     
      if(res.statusCode == 200 || res.statusCode == 201){
         if(mounted){
   setState(() {
  showSpinner = false;
  _verificationId = true;
  });
  }
  setClocks();
      }else{
       return errorDialog('Oops something went wrong! Try again');
      }
    });
      }
    }).catchError((onError){
      return errorDialog(onError.message);
    });

    }).catchError((onError){
      if(mounted){
       setState(() {
      showSpinner = false;
      });
   }
   return errorDialog(onError.message);
    });
    }catch(e){

 if(mounted){
   setState(() {
  showSpinner = false;
  _verificationId = true;
  });
  }      
return errorDialog(e.message);
    }
  }


  void clockRemover(){
if(autoVerifier != null){
    autoVerifier.cancel();
  }
  if(clockerOverDialog != null){
    clockerOverDialog.cancel();
  }
  if(clocker != null){
    clocker.cancel();
  }
  }

  

  void _signInWithPhoneNumber() async {
     if(mounted){
   setState(() {
  isSms = true;
  });
  }
   try{
     http.get(
    'https://young-tor-95342.herokuapp.com/confirm-user/${_phoneNumberController.text}/$_defaultCode/${_smsController.text}/$fcm_token').then((res){
      if(res.statusCode == 200 || res.statusCode == 201){
     if(mounted){
   setState(() {
  isSms = false;
  });
  }
  clockRemover();
  // prefs.setBool('isNewUser', true);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TermsWid()));
      }else{
         if(mounted){
   setState(() {
  isSms = false;
  });
  }
        errorDialog('Oops something went wrong! Try again');
      }
    });
   }catch (e){
    if(mounted){
   setState(() {
  isSms = false;
  });
  }
errorDialog('Check your internet connection and try again');
   }
    
  }

  
  


  dynamicHeightSetter(){
    setState(() {
      paddingTitle = 5.0;
      _sizedBoxHeight = 180.0;
    });
  }

  setBiggerHeight(){
    setState(() {
      paddingTitle = 26.0;
      _sizedBoxHeight = 250.0;
    });
  }

Widget buildSmsTitle(){
  return  Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
   BackButton(onPressed: (){
            setState(() {
              _verificationId = false;
            });
      },),
    Container(
    alignment: Alignment.topLeft,
                    child: Text(
                      'Confirm code sent via SMS',
                      style: TextStyle(fontSize: 30.0, fontFamily: 'NunitoSans',fontWeight: FontWeight.w300),
                    ),
                    padding: EdgeInsets.only(left: 15.0,right: 39.0,top:76.0),
       )
  ],);
}

  Widget buildDefaultTitle(){
    return Container(
                child: Text('Rexa',
                    style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.black,
                        fontFamily: 'Monoton')),
              );
    }
  
  Widget buildDefaltSubTitle(){
    return Container(alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(left:44.5,right:46.5,top: 10.0,),
                      child: Text('Get Started With Your Rexa Account',
                        style: TextStyle(

                          fontSize: 14.0,
                          color: Color(0xFF404040),
                          fontWeight: FontWeight.w100,fontFamily: 'NunitoSans',),textAlign: TextAlign.center,))
              );
  }

   Future<void> _signInWithApple(BuildContext context, String phoneNumber) async {
   if(mounted){
   setState(() {
  showSpinner = true;
  });
  }
    
   SharedPreferences prefs = await SharedPreferences.getInstance();
   try {
    final user = await authService.signInWithApple(
        scopes: [Scope.email, Scope.fullName]);
   prefs.setString('token', '${user.getIdToken()}');
    prefs.setString('customNumber', phoneNumber);
    prefs.setString('email', '${user.email}');
    prefs.setString('uid', phoneNumber);
    prefs.setString('phoneNumber', phoneNumber);// causes chat bug if missing
    prefs.setString('profilePicture', '${user.photoUrl}');
    prefs.setString('fullName', '${user.displayName}');
    // prefs.setString('fcm_token', newuser.data['fcm_token']);
    Firestore.instance.collection('users').document(phoneNumber).get().then((newuser){
      if(newuser.exists){
        prefs.setBool('isNewUser', false);
        prefs.setBool('isSignedIn', true);
        prefs.setString('iso_code', newuser.data['iso_code']);
        prefs.setString('fullName', newuser.data['fullName']); 
        prefs.setString('countryCode', newuser.data['country_code']);
        prefs.setString('profilePicture', newuser.data['profilePicture']);
        prefs.setDouble('long', newuser.data['longitude']);
        prefs.setDouble('lat', newuser.data['latitude']); // fcm_token
        prefs.setString('fcm_token', newuser.data['fcm_token']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Swiper()));
      }else{

    http.get(
    'https://young-tor-95342.herokuapp.com/verify-user/${_phoneNumberController.text}/$_defaultCode').then((res){
     
      if(res.statusCode == 200 || res.statusCode == 201){
         if(mounted){
   setState(() {
  showSpinner = false;
  _verificationId = true;
  });
  }
  setClocks();
      }else{
        errorDialog('Oops something went wrong! Try again');
      }
    });
      }
    });
  
  } catch (e) {
    errorDialog(e.toString());
  }
}



  Widget buildVerifyForm(){
    return Column(
            children: <Widget>[
              ListTile(title: Text('Select Country Code',style: TextStyle(fontSize: 12.0,
                    fontWeight: FontWeight.w400,fontFamily: 'NunitoSans'),textAlign: TextAlign.center,),subtitle: showCountries(),),

             
ListTile(
 
  title: TextFormField(

          keyboardType: TextInputType.phone,
          controller: _phoneNumberController,
          decoration:
              InputDecoration(labelText: 'Phone number',
                hintText: 'Mobile Number'
                ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Phone number required';
            }
            return null;
          },
        ),),
InkWell(
      onTap: () {
        verifyPhoneNumber('${_defaultCode + _phoneNumberController.text.substring(1,)}');
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        height: 50,
        width: MediaQuery.of(context).size.width -51,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color(0xffffffff).withAlpha(100),
                  offset: Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.blueAccent),
        child: defaultButtonText(),
      ),
    ),
    SizedBox(height: 2,),
SizedBox(height: 3,),
Theme.of(context).platform == TargetPlatform.iOS ?_divider(): SizedBox.shrink(),
SizedBox(height: 3,),
    Theme.of(context).platform == TargetPlatform.iOS ? Container(child: AppleSignInButton( 
  style: ButtonStyle.black,
  type: ButtonType.signIn,
  onPressed: () => _signInWithApple(context, '${_defaultCode + _phoneNumberController.text.substring(1,)}'),
),width: MediaQuery.of(context).size.width -51,): SizedBox.shrink(),
                      // semiChecker()
        Align(child: Padding(child: RichText(
                  textAlign: TextAlign.center,
  text: TextSpan(
    text: '©2020 elyfez Technologies. All rights reserved',
    // style: DefaultTextStyle.of(context).style,
    style: TextStyle(
                color: Colors.black,
                fontSize: 10,height: 1,
                decoration: TextDecoration.none,
                fontFamily: 'NunitoSans',
              ),
    children: <TextSpan>[
      TextSpan(text: ' Katumba', style: TextStyle(fontWeight: FontWeight.bold)),

    ],
  ),
),padding: EdgeInsets.only(top: 20.0,left: 3.0,right: 3.0),),alignment: Alignment.bottomCenter,)

              

            ],
          );
  }

  Widget buildConfirmForm(){
    return Column(
            children: <Widget>[
              SizedBox(height: 15.0,),
             ListTile(
 subtitle: Text('Time remaining $times', style: TextStyle(color: Colors.black54,height: 1.9)),
  title: TextFormField(
    keyboardType: TextInputType.number,
          controller: _smsController,
          decoration:
              InputDecoration(labelText: 'Enter SMS Code',
              
                hintText: '6-digit code sent via SMS'
                ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Phone number';
            }
            return null;
          },
        ),),
Container(child:InkWell(
      onTap: () {
      _signInWithPhoneNumber();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color(0xffffffff).withAlpha(100),
                  offset: Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.blueAccent),
        child: defaultButtonTextSms(),
      ),
    ),width: MediaQuery.of(context).size.width - 50,margin: EdgeInsets.only(top: 1.9,bottom: 33)),
        // Align(child: Padding(child: Text('©2019 elyfez Technologies  All rights reserved "Katumba"',
        //               style: TextStyle(
        //                 fontSize: 13.6,
        //                 fontFamily: '',
        //                 color:Colors.black87,
        //               fontWeight: FontWeight.w300),textAlign: TextAlign.center,
        //               ),padding: EdgeInsets.only(top: 27.0,left: 40.0,right: 40.0),),alignment: Alignment.bottomCenter,)

              

            ],
          );
  }


  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }


  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
  // print('full width ${MediaQuery.of(context).size.width} and height is ${MediaQuery.of(context).size.height}');
    return WillPopScope(child: Scaffold(
      body:SingleChildScrollView(
        child:Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white])),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          
           _verificationId  ?   buildSmsTitle() : buildDefaultTitle() ,
          _verificationId  ? SizedBox.shrink() : buildDefaltSubTitle(),
          SizedBox(height:  120.0,),
       _verificationId  ?  buildConfirmForm() : buildVerifyForm()

          
        ],
      )
            
            ))),onWillPop: (){
              SystemNavigator.pop();
            },);
    
  }

}
