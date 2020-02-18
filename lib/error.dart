import 'package:flutter/material.dart';
import './viewList.dart';

class FailedWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 100),
            child: Column(
              children: <Widget>[
                SizedBox(height: 60.0,),
                Icon(Icons.highlight_off,
                    size: 60.0, color: Colors.red),
                SizedBox(height: 8.0,),
                Text('Oops Something went wrong!',
                    style: TextStyle(
                      fontSize: 30.0,
                    )),
                SizedBox(height: 8.0),
                Text(
                  'Please check your network',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17.0),
                ),
                SizedBox(height: 30.0,),
                Center(
                    child: RaisedButton(
                        onPressed: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewList()));
                        },
                        child: Text(
                          'OK',
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



