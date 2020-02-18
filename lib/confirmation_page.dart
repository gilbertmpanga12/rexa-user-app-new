import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './terms_and_conditions.dart';
import './swiper.dart';

class ConfirmationCode extends StatefulWidget {
  final String verificationId;

  ConfirmationCode({this.verificationId});

  @override
  ConfirmationCodeState createState() => ConfirmationCodeState();
}

class ConfirmationCodeState extends State<ConfirmationCode> {
  String _code;
  final TextEditingController _phoneNumberControllerx = TextEditingController();
  String _verifcationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String confirmText = 'Confirm';
  int times = 0;
  Timer clocker;
  Timer clockerOverDialog;
  Widget _buildConfirmCode() {
    return TextFormField(controller: _phoneNumberControllerx,
        maxLines: 2,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            labelText: 'Enter verification code from SMS',
            icon: Icon(
              Icons.location_on,
              color: Colors.yellow[800],
            )));
  }

  Future<dynamic> errorDialog(String  errorMessage) async{
     try {
        await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Oops!'),
                  content: Container(child: Text('$errorMessage'),width: 200.0,),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                       setState(() {
                       confirmText = 'Confirm';
                       });
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                    )
                  ],
                );
              });
  setState(() {
 confirmText = 'Confirm';
 _phoneNumberControllerx.clear();
    });
     }catch(e){
setState(() {
 confirmText = 'Confirm';
  _phoneNumberControllerx.clear();
    });
     }
  }

 

  void signInWithPhoneNumber(String _verificationId, String smsText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      confirmText = 'Processing...';
    });
  try{
   final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: smsText,
    );
    final  user =
        (await _auth.signInWithCredential(credential));
    final FirebaseUser currentUser = await _auth.currentUser();
   
    bool stamp = user.user.uid == currentUser.uid;
    prefs.setString('uid', currentUser.phoneNumber);
    prefs.setString('creationTime', currentUser.metadata.creationTime.toIso8601String());
    prefs.setString('lastTime', currentUser.metadata.lastSignInTime.toIso8601String());

    if(currentUser.metadata.creationTime == 
    currentUser.metadata.lastSignInTime && stamp){
      prefs.setBool('isSignedIn', true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TermsWid()));
      
    }else{
      prefs.setBool('isSignedIn', true);
      Firestore.instance.collection('users').document(currentUser.phoneNumber).get().then((onValue){
prefs.setString('actual_fullname', onValue.data['fullName']);
prefs.setString('profilePicture', onValue.data['profilePicture']);
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Swiper()));
      });
      
    }
  }catch(e){
errorDialog(e.message);

  }



  }

@override
  void initState() {
   _verifcationId = widget.verificationId;
 clockerOverDialog =  Timer(const Duration(minutes: 2), (){
errorDialog('Timeout for entering SMS code expired');
    });
    try{
      if(mounted){
    clocker =    Timer.periodic(const Duration(seconds: 1), (e){
print('yes');
      if(times < 120){
        setState(() {
        times++;
      });
        
     }else{
       e.cancel();
     }
      
     
    });
      }
    }catch(e){
      print(e);
    }
    super.initState();
  }


@override
dispose(){
  clockerOverDialog.cancel();
  clocker.cancel();
  super.dispose();
}


  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return WillPopScope(child: GestureDetector(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(10.0),
          child: ListView.builder(
              itemCount: 1,
              // itemExtent: ,
              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
              itemBuilder: (BuildContext context, int index){
                return Column(children: <Widget>[
                  SizedBox(
                    height: 38.0,
                  ),
                  Container(
                    child: Text(
                      'Confirm code sent via SMS',
                      style: TextStyle(fontSize: 30.0, fontFamily: 'NunitoSans',fontWeight: FontWeight.w300),
                    ),
                    margin: EdgeInsets.only(bottom: 10.0, top: 2.0),
                  ),
                  _buildConfirmCode(),
                  SizedBox(height: 10.0,),
                   Align(child: Padding(child: times < 78 ? Text('Time remaining $times',style: TextStyle(color: Colors.black54),) : Text('Time required for entering SMS code expired.',style: TextStyle(color: Colors.black54),),padding: EdgeInsets.only(left: 40.0,top: 3.0,bottom: 3.0),),alignment: Alignment.centerLeft,),
                  RaisedButton(color: Colors.blueAccent,child: Text('$confirmText',style: TextStyle(color: Colors.white)),onPressed: (){
                    signInWithPhoneNumber(_verifcationId, _phoneNumberControllerx.text);
                  },),
                 
                ],);
              },
            ),
        ),
        
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    ),onWillPop: (){
      Navigator.popAndPushNamed(context, '/');
      return Future.value(false);
    },);
  }

}
