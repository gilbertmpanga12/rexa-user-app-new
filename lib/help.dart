import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



class HelpWid extends StatefulWidget {
  HelpWidState createState() => HelpWidState();
}

class HelpWidState extends State<HelpWid> {


initState(){
  super.initState();
}



  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Help',
             style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 17),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0
      ),
      body: Center(
        child: Padding(
          child: Column(
            children: <Widget>[
              SizedBox(height: 55.0,),
            Text(
              'For any questions or feedback please contact us',
              style: TextStyle(fontSize: 19.0,fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
              SizedBox(height: 18.0,),
              InkWell(
                onTap: (){
                  launch("tel://+256706073735");
                },
                child: Text('+256706073735',style: TextStyle(fontSize: 20.0),),
              ),

             InkWell(
               child:  Text('+256774629181',style: TextStyle(fontSize: 20.0),),
               onTap: (){
                 launch("tel://+256774629181");
               },
             ),
              SizedBox(height: 6.0,),

              Text('OR'),
              InkWell(
                child: Text('elyferexa@gmail.com', style: TextStyle(fontSize: 18.0),),
                onTap: (){
                  launch("mailto:elyferexa@gmail.com");
                },
              )
            ],
          ),
          padding: EdgeInsets.all(26.0),
        ),
      ),
    );
  }
}
