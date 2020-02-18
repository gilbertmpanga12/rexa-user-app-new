import 'package:flutter/material.dart';
import './viewList.dart';
import './app_services/localizer.dart';

class NotAvailableWidget extends StatelessWidget {
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
                 'Service provider already booked try another one',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17.0),
                ),
                SizedBox(height: 30.0,),
                Center(
                    child: RaisedButton(
                        onPressed: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ViewList()));
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
