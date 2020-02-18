import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './userprofile.dart';

class ChangeAbout extends StatefulWidget {
  ChangeAboutState createState() => ChangeAboutState();
}

class ChangeAboutState extends State<ChangeAbout> {

String  about;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
String _firebaseUID;

localStorage() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _firebaseUID = prefs.getString('uid');
  });
}

  
Widget _buildAboutField() {
    return TextFormField(
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(
            labelText: 'About',
            icon: Icon(
              Icons.person,
              color: Colors.yellow[800],
            )),
        onSaved: (String value) {
          about = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'About required';
          } else {
            return null;
          }
        });
  }


    initState(){
      localStorage();
      super.initState();
    }

  submitPaymentMethod2() async{
   if (!_formKey.currentState.validate()) {
      return null;
    }
    _formKey.currentState.save();
    Toast.show('Updating...', context, duration: 5);
  }

  build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
          title: Text(
            'Edit Name',
            style: TextStyle(
              fontSize: 25.0,letterSpacing: .4,
              color: Colors.black,fontFamily: 'Rukie',fontWeight: FontWeight.w600
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 1.0
      ),
      body: Form(
        child: Center(
        child: Padding(
          child: Column(
            children: <Widget>[
              SizedBox(height: 55.0,),
            _buildAboutField(),
            // RaisedButton(child: ,)
            ],
          ),
          padding: EdgeInsets.all(26.0),
        ),
      ),
      key: _formKey,
      ),
      bottomNavigationBar: FlatButton(
            onPressed: () {
            submitPaymentMethod2();
            Firestore.instance.collection('users').document('${_firebaseUID}').updateData({
              'about': about
            }).then((resp){
                
                try{
                  Toast.show('Uploded successfully', context,
                duration: 5, backgroundColor: Colors.green);
if(mounted){
                  setState(() {
                    about = '';
                  _formKey.currentState.reset();
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()));
                }
                }catch(err){
                  print('reversed');
                }
            }).catchError((err){
Toast.show('Oops something went wrong', context,
                duration: 5, backgroundColor: Colors.red);
            });
            
            },
            child: Padding(
              child: Row(
                children: <Widget>[
                  Text(
                    'SAVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 29.0,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              padding: EdgeInsets.only(top: 11.0, bottom: 11.0),
            ),
            color: Colors.black),
    ),onWillPop: (){
      Navigator.popAndPushNamed(context, '/profile');
      return Future.value(false);
    },);
  }
}
