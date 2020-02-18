import 'package:flutter/material.dart';
import './swiper.dart';
import './app_services/localizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';


class SuccessWidget extends StatefulWidget {
SuccessWidgetState createState() => SuccessWidgetState();
}

class SuccessWidgetState extends State<SuccessWidget> {
String _firebaseUID;
bool isBooked;

cancelRequest() {
    if (isBooked && _firebaseUID != null && mounted) {
      Toast.show('Processing...please wait', context, duration: 7);

      Firestore.instance
          .collection('orders')
          .document('${_firebaseUID}')
          .delete()
          .then((onvalue) {
        Firestore.instance
            .collection('saloonServiceProvider')
            .document('${_firebaseUID}')
            .setData({'isRequested': false}, merge: true).then((newval) {
          Toast.show('Uploded successfully', context,
              duration: 5, backgroundColor: Colors.green);
          cancelBooked();
        });
      }).catchError((err) {
        Toast.show('Oops something went wrong!', context,
            duration: 5, backgroundColor: Colors.red);
      });
    }
  }

  cancelBooked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isBooked', false);
  }

  localStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firebaseUID = prefs.getString('lastOrderedServiceProviderId');
      isBooked = prefs.getBool('isBooked');
    });
    }
  
  initState(){
localStorage();
super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 100),
            child: Column(
              children: <Widget>[
                SizedBox(height: 60.0,),
                Icon(Icons.check_circle_outline,
                    size: 60.0, color: Colors.yellow[800]),
                SizedBox(height: 8.0,),
                Text(DemoLocalizations.of(context).requestSent,
                    style: TextStyle(
                      fontSize: 30.0,
                    )),
                SizedBox(height: 8.0),
                Text(
                  DemoLocalizations.of(context).successMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17.0),
                ),
                SizedBox(height: 30.0,),
                Center(
                    child: RaisedButton(
                        onPressed: (){
                         Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text(
                          DemoLocalizations.of(context).okay,
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),

                        ),shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),color: Colors.yellow[800]
                    ))
                        
                                  ],
            ),
          )),
      backgroundColor: Colors.white,
    );
  }
}
