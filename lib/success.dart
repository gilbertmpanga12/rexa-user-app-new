import 'package:flutter/material.dart';
import './app_services/localizer.dart';



class SuccessWidget extends StatefulWidget {
SuccessWidgetState createState() => SuccessWidgetState();
}

class SuccessWidgetState extends State<SuccessWidget> {

  initState(){

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
                Text('Request sent successfully',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold
                    )),
                SizedBox(height: 8.0),
                Text(
                  DemoLocalizations.of(context).successMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0),
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
