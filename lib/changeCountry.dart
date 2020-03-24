import './swiper.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


class OfferChanger extends StatefulWidget {
  OfferChangerState createState() => OfferChangerState();
}

class OfferChangerState extends State<OfferChanger> {
  // bool isSwitched = false;


initState(){
  super.initState();
}


Widget showCountries(){
  return CountryCodePicker(
         onChanged: _onCountryChange,
         // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
         initialSelection: 'IT',
         favorite: ['+256','UG'],
         // optional. Shows only country name and flag
         showCountryOnly: false,
         // optional. aligns the flag and the Text left
         alignLeft: false,
       );
}


void _onCountryChange(CountryCode countryCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
     Fluttertoast.showToast(
        msg: "Processing...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1000,
        // backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    print(prefs.getString('immutableCountryCode'));
    print(countryCode.code);
    print(countryCode.code.toString() == prefs.getString('immutableCountryCode'));
  if(countryCode.code.toString() == prefs.getString('immutableCountryCode')){
    prefs.setBool('international',  false);
    prefs.setString('countryCode', prefs.getString('immutableCountryCode'));
    Fluttertoast.showToast(
        msg: "Updated!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }else{
   prefs.setString('countryCode', countryCode.code);
   prefs.setBool('international',  true);
   Fluttertoast.showToast(
        msg: "Updated!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  
  }

  // void _disableInternational() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(mounted){
  //     Firestore.instance.collection('users').document(prefs.getString('uid')).setData({
  //     'request_made': false
  //   },merge: true).then((onValue){
  //     print('reset');
  //   });
  //   }
  //   prefs.setBool('international',  true);
  // }

   void restoreDefault() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String defaultCode = prefs.getString('immutableCountryCode') ?? 'UG';
    prefs.setBool('international',  false);
    prefs.setString('countryCode', defaultCode);
  }

  // _loader() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isSwitched = prefs.getBool('international') ?? false;
  //   });
  // }

// Widget changeSwitcher(){
//   return Switch(
//   value: isSwitched,
//   onChanged: (value) {
//     setState(() {
//       isSwitched = value;
//     });
//     restoreDefault();
//   },
//   activeTrackColor: Colors.lightGreenAccent, 
//   activeColor: Colors.green,
// );
// }

  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Change Country',
       style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 17),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0
      ),
      body:   WillPopScope(child: Column(children: <Widget>[
        Padding(child: InkWell(child: ListTile(
        dense: false,
        subtitle: Text('Tap flag to change country',style: TextStyle(fontSize: 14.0),),
        trailing:  showCountries(),
          //leading: SizedBox(child: showCountries(),width: 56.0,),
          title: Text('Book from other countries',style: TextStyle(fontSize: 14),),


        )),padding: EdgeInsets.only(top: 13.0)),
        Divider(endIndent: 10,indent: 10,)
       
      ],),onWillPop: (){
           Navigator.push(
            context, MaterialPageRoute(builder: (context) => Swiper()));
            return Future.value(false);
        },)
    );
  }
}
