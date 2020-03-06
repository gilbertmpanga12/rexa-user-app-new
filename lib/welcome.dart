import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import './app_services/localizer.dart';



class CountryCodes {
  String name;
  String dial_code;
  String code;
}

class Welcome extends StatefulWidget {
  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends State<Welcome> {
  String _defaultGender = 'Female';
  String _fullName;
  String _location;
  String _phoneNumber;
  String _email;
  String _profilePicture;
  String _uid;
  String _nin;
  String _defaultCode = '+256';
  String _token;
  String _date;
  int birthday;
 final dateController = TextEditingController(text: '');
 String userIs13 = 'You must be above 13 years to use this app';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget _buildGenderTextField(){
    return DropdownButtonFormField(
        decoration:
        InputDecoration(icon: Icon(Icons.info,color: Colors.blue[300],)),
        value: _defaultGender,
        items: <String>[
          DemoLocalizations.of(context).female,
          DemoLocalizations.of(context).male
        ].map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String newValue) {
          setState(() {
            _defaultGender = newValue;
          });
        },
        validator: (String value) {
          if (value.isEmpty) {
            return DemoLocalizations.of(context).gender_required;
          } else {
            return null;
          }
        });
  }



  Widget _buildFullNameField() {
    return TextFormField(
        textCapitalization: TextCapitalization.words,
        maxLines: 2,
        decoration: InputDecoration(
            labelText: 'Full Names',
            icon: Icon(
              Icons.person,
              color: Colors.blue[300],
            )),
        onSaved: (String value) {
          _fullName = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return 'Username required';
          } else {
            return null;
          }
        });
  }



Widget _buildDate() {
    return TextFormField(
keyboardType: TextInputType.datetime,
      controller: dateController,
      onTap: (){
      showDatePicker(
      context: context,
      firstDate:  DateTime(1971),
      lastDate: DateTime(2045),
      initialDate: DateTime.now()
      ).then((onValue){
        birthday = DateTime.now().year - onValue.year;
        setState(() {
          _date = '${onValue.day}/${onValue.month}/${onValue.year}';
          dateController.text = _date;
        });
        print(_date);
      });
    },

        textCapitalization: TextCapitalization.words,
        maxLines: 2,
        decoration: InputDecoration(
            labelText: 'Birth Date',
            icon: Icon(
              Icons.calendar_today,
              color: Colors.blue[300],
            )),
        onSaved: (String value) {
          _date = value;
        },

        validator: (String value){
          if(value.isEmpty){
            return 'Birth date required';
          }else if(value.length == 8){
            var islength8 = DateTime.now().year - int.parse(value.substring(4,8));
            if(islength8 < 13){
              return userIs13;
            }
          }else if(value.length == 9){
            var islength9 = DateTime.now().year - int.parse(value.substring(5,9));
            if(islength9 < 13){
              return userIs13;
            }
          }else if(value.length == 10){
            var islength10 = DateTime.now().year - int.parse(value.substring(6,10));
            if(islength10 < 13){
              return userIs13;
            }
          }  else {
            return null;
          }
        }
        );
  }



 
  Widget _buildLocationField() {
    return TextFormField(
        maxLines: 2,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            labelText: DemoLocalizations.of(context).Location,
            icon: Icon(
              Icons.location_on,
              color: Colors.blue[300],
            )),
        onSaved: (String value) {
          _location = value;
        },
        validator: (String value) {
          if (value.isEmpty) {
            return DemoLocalizations.of(context).location_required;
          } else {
            return null;
          }
        });
  }



  _submitForm() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var fcmToken = status.subscriptionStatus.userId;
    if (!_formKey.currentState.validate()) {
      return null;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
               shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
              content: Row(
                children: <Widget>[
                  Container(
                    child: CircularProgressIndicator(),
                    margin: EdgeInsets.only(right: 10.0),
                  ),
                  Container(
                    child: Text(
                      'Processing...',
                      style: TextStyle(fontSize: 17.0),
                    ),
                  )
                ],
              ),
            );
          });
      _formKey.currentState.save();
      prefs.setString('actual_fullname', '$_fullName');
      prefs.setString('fullName',_fullName[0].toUpperCase() + _fullName.substring(1,));
      prefs.setString('profilePicture', 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697');

      await Firestore.instance.collection('users')
      .document(prefs.get('uid')).setData({
       'phoneNumber': prefs.get('uid'),
        'fullName': _fullName,
        'email': prefs.getString('email'),
        'gender': _defaultGender,
        'location': _location,
        'profilePicture': 'https://firebasestorage.googleapis.com/v0/b/esalonbusiness-d3f3d.appspot.com/o/avatar.png?alt=media&token=53503121-c01f-4450-a5cc-cf25e76f0697',
        'uid': '+256785442776',
        'longitude': prefs.getDouble('long'),
        'latitude': prefs.getDouble('lat'),
        'nin': 'N/A',
        'country_code': prefs.get('countryCode'),
        'actual_name':  _fullName,
        'fcm_token': fcmToken,
        'chatCount': 0,
        'iso_code': prefs.get('iso_code'),
        'request_made': false,
        'about': 'Status not available',
        'cancel_request': false,
        'ratingCount': 0,
        'tvCount': 0,
        'birthday': _date,
        'current_status': 'Online'
      }).then((onValue){
        Navigator.of(context, rootNavigator: true).pop('dialog');
          prefs.setBool('isSignedIn', true); // set to true finally for new users
          prefs.setBool('isNew', false); // set new status to false
          Navigator.pushReplacementNamed(
          context, '/home');
      });
    } catch (err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
               shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
              title: Text('Oops something went wrong'),
              content: Row(
                children: <Widget>[
                  Container(
                    child: Text(
                      'Please try again or contact support team',
                      style: TextStyle(fontSize: 17.0),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                )
              ],
            );
          });
    }
  }

@override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    dateController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: ListView.builder(
              itemCount: 1,
              // itemExtent: ,
              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
              itemBuilder: (BuildContext context, int index){
                return Column(children: <Widget>[
                  SizedBox(
                    height: 66.0,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      DemoLocalizations.of(context).welcome,
                      style: TextStyle(fontSize: 26.7,fontFamily: 'NunitoSans',wordSpacing: -1),
                    ),
                    margin: EdgeInsets.only(bottom: 10.0, top: 2.0),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  _buildFullNameField(),
                  
                  SizedBox(
                    height: 39.0,
                  ),
                  _buildGenderTextField(),
                  
                  SizedBox(
                    height: 38.0,
                  ),
                  _buildDate(),
                  SizedBox(
                    height: 38.0,
                  ),
                 
               
                  _buildLocationField(),
                   InkWell(child: Container(
                     margin: EdgeInsets.only(top:30),
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
        child: Text(
          'Finish',
          style: TextStyle(fontSize: 21, color: Colors.white,fontWeight: FontWeight.w700,fontFamily: 'NunitoSans'),
        ),
      ),onTap: (){
             _submitForm();
      },)
                ],);
              },
            ),
          ),
        ),
     
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

}
