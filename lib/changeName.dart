import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import './userprofile.dart';
import 'dart:async';

class ChangeName extends StatefulWidget {
  ChangeNameState createState() => ChangeNameState();
}

class ChangeNameState extends State<ChangeName> {

String  _fullName;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
String _firebaseUID;

localStorage() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _firebaseUID = prefs.getString('uid');
}
initState(){
  localStorage();
  super.initState();
}


  Widget _buildFullNameField() {
    return TextFormField(
        textCapitalization: TextCapitalization.words,
        maxLines: 2,
        decoration: InputDecoration(
            labelText: 'Username',
            icon: Icon(
              Icons.person,
              color: Colors.yellow[800],
            )),
        onSaved: (String value) {
          _fullName = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'Full  names';
          } else {
            return null;
          }
        });
  }


  submitPaymentMethod() async{
     if (!_formKey.currentState.validate()) {
      return null;
    }
    _formKey.currentState.save();
     Toast.show('Updating...', context, duration: 5);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fullName', _fullName);
  }

  build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
          title: Text(
            'Edit Username',
            style: TextStyle(fontSize: 25.0,letterSpacing: .4,
              color: Colors.black,fontFamily: 'Rukie',fontWeight: FontWeight.w600),
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
              SizedBox(height: 45.0,),
            _buildFullNameField(),
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
              submitPaymentMethod();
            Firestore.instance.collection('users').document('${_firebaseUID}').updateData({
              'fullName': _fullName
            }).then((resp){

                try{
                  Toast.show('Uploded successfully', context,
                duration: 5, backgroundColor: Colors.green);
if(mounted){
                  setState(() {
                    _fullName = '';
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
    ), onWillPop: (){
       Navigator.popAndPushNamed(context, '/profile');
      return Future.value(false);
    },);
  }
}
