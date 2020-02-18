import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DefaultPlaceholder extends StatelessWidget {
 
 Widget build(BuildContext context) {
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
              builder: (context) => IconButton(
                    icon: new Icon(
                      Icons.more_horiz,
                      size: 30.0,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  )),
          centerTitle: true,
          title: Text(
            'Rexa',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Merienda',
                color: Colors.black,
                fontSize: 20.0,
                letterSpacing: 0.8),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            IconButton(
                    icon: Icon(Icons.star_border),
                    onPressed: () {
                  print('loading...');
                    }),
            new IconButton(
                    icon: Icon(Icons.live_tv),
                    onPressed: () {
                     print('loading...');
                    })
          ],
        ),
       
        body: Center(child: SpinKitDoubleBounce(
  color: Colors.blue,
  size: 66.0,
),),
        backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
      ),
    );
  }

  
}
