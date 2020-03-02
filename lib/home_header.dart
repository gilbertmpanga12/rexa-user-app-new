import 'package:rexa/styles_beauty.dart';

import './strings.dart';
import 'package:flutter/material.dart';

import 'dimen.dart';

Widget homeHeader(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 50),
    height: Dimen.headerHeight,
    child: Stack(children: <Widget>[
      Theme.of(context).platform == TargetPlatform.iOS ? Positioned(child: BackButton(color: Colors.white,onPressed: () async{
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  StylesBeautyWidget()));
      },),left: 10.0,top: -14.0): SizedBox.shrink(),
      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(
            AppStrings.followingString,
            style: TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Text("|",
            style: TextStyle(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(AppStrings.forYouString,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        )
      ],
    )
    ],),
  );
}