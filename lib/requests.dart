import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './app_services/localizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';


class RequestsWid extends StatefulWidget {
  @override
  RequestsWidState createState() => RequestsWidState();
}

class RequestsWidState extends State<RequestsWid> {
  String profilePicture;
  String displayName;
  String phoneNumber;
  String _firebaseUID;
  String _fullName;
  String price;
  String serviceProvided;
  bool isBooked;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState() {
    // Timer.periodic(Duration.millisecondsPerSecond(29) , () {
    //  localStorage();
    // });
    localStorage();
    super.initState();
  }

  localStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture = prefs.getString('serviceProviderPicture');
      displayName = prefs.getString('serviceProviderName');
      phoneNumber = prefs.getString('providerphoneNumber'); // missing
      _firebaseUID = prefs.getString('lastOrderedServiceProviderId');
      price = prefs.getString('servicePrice');
      serviceProvided = prefs.getString('serviceProvided');
      isBooked = prefs.getBool('isBooked');
    });
  }

  cancelBooked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isBooked', false);
  }

  Widget showBooked() {
    return ListView(
      children: <Widget>[
        Form(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 17.0, left: 0, right: 20.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: InkWell(
                        child: CircleAvatar(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.yellow[700],
                      backgroundImage: new NetworkImage('${profilePicture}'),
                      radius: 75.0,
                    )),
                    margin: EdgeInsets.only(left: 18.0, bottom: 25.0),
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.yellow[800]),
                    title: Text('Requested Service',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        )),
                    subtitle: Text('${serviceProvided}',
                        style: TextStyle(
                          fontSize: 17.0,
                        )),
                  ),
                  Container(
                    child: Divider(
                      indent: 57.8,
                    ),
                    padding: EdgeInsets.only(left: 12.0),
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.monetization_on, color: Colors.yellow[800]),
                    title: Text(
                      'Price',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('${price}',
                        style: TextStyle(
                          fontSize: 17.0,
                        )),
                  ),
                  Container(
                    child: Divider(
                      indent: 57.8,
                    ),
                    padding: EdgeInsets.only(left: 12.0),
                  ),
              
                  ListTile(
                    onTap: (){
                      launch('${phoneNumber}');
                    },
                    leading: Icon(Icons.phone, color: Colors.yellow[800]),
                    title: Text(DemoLocalizations.of(context).telephone,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('${phoneNumber}',
                        style: TextStyle(
                          fontSize: 17.0,
                        )),
                  ),
                ],
              ),
            ),
          ),
          key: _formKey,
        )
      ],
    );
  }

  Widget notBooked() {
    return Center(
      child: Text('You have\'t yet made any requests'),
    );
  }

  Widget defaultView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Requests',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 1.5,
      ),
      body: Center(
        child: Text('You have\'t yet made any requests'),
      ),
    );
  }

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
          setState(() {
            isBooked = false;
          });
          cancelBooked();
        });
      }).catchError((err) {
        Toast.show('Oops something went wrong!', context,
            duration: 5, backgroundColor: Colors.red);
      });
    }
  }

  Widget build(BuildContext context) {
    try {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              '${isBooked ? displayName : 'Requests'}',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w900),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            centerTitle: true,
            elevation: 1.5,
          ),
          body: isBooked
              ? showBooked()
              : isBooked == false
                  ? notBooked()
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
          bottomNavigationBar: isBooked && mounted ? FlatButton(
              onPressed: () {
                cancelRequest();
              },
              child: Padding(
                child: Row(
                  children: <Widget>[
                    Text(
                      'CANCEL REQUEST',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                padding: EdgeInsets.only(top: 11.0, bottom: 11.0),
              ),
              color: Colors.blue[500]): Container(child: Text(''),),
        );
    } catch (err) {
      return defaultView();
    }
  }
}
