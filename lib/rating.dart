import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './swiper.dart';

class RatingWidget extends StatefulWidget {
//  final String serviceProviderName;
//  final String servicePrice;
//  final String serviceContact;
//
//  RatingWidget({this.serviceContact,this.servicePrice,this.serviceProviderName});


  @override
  RatingState createState() => RatingState();
}

class RatingState extends State<RatingWidget> {
  String _token;
  String serviceProviderToken;
  String serviceProviderName;
  String serviceProviderImage;
  String serviceProviderPrice;
  String serviceProvided;
  String serviceProviderUid;
  String servicePrice;
  String serviceHours;
  String userId;
  int rating;
  int rating1 = 0;
  int rating2 = 0;
  int rating3 = 0;
  int rating4 = 0;
  int rating5 = 0;
  bool isBooked = false;
  final TextEditingController _rateCommentCtrl = TextEditingController();


  localStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serviceProviderToken = prefs.getString('serviceProviderToken');
      serviceProviderName = prefs.getString('serviceProviderName');
      serviceProviderImage = prefs.getString('serviceProviderPicture');
      serviceProviderPrice = prefs.getString('serviceProviderPrice');
      serviceProviderUid = prefs.getString('serviceProviderUid');
      serviceProvided = prefs.getString('serviceProvided');
      serviceHours = prefs.getString('serviceHours');
      isBooked = prefs.getBool('isBooked') == true;
      userId = prefs.getString('uid');
    });
  }

  void rateProvider(int counter) {
    rating = counter;
  }

  makeServiceRequest(String comment) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
                   shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20.0))
),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _payload = json.encode({
      'rating': rating,
      'serviceProviderToken': serviceProviderToken,
      'uid': serviceProviderUid,
      'userId': prefs.getString('uid'),
      'lastBalance': prefs.getString('serviceProviderPrice'),
      'raterComment': comment,
      'photoUrl': prefs.getString('profilePicture'),
      'commenter_name': prefs.getString('fullName'),
      'comment_length': comment.length,
      'rating': rating
    });
   Firestore.instance.collection('users').document(prefs.getString('uid')).setData({
   'ratingCount': 0
 },merge: true).then((onValue){
http.post(
        'https://young-tor-95342.herokuapp.com/api/rate-salon-provider',
        body: _payload,
        headers: {
          "accept": "application/json",
          "content-type": "application/json"
        }).then((response){
if (response.statusCode == 200 || response.statusCode == 201) {
      prefs.setBool('showResults', true);
      prefs.setBool('isBooked', false);
     Navigator.push(context, MaterialPageRoute(builder: (context) => Swiper()));
     removeNots();
    } else {
      print(response.body);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Swiper()));
      throw Exception('Oops something wrong');
    }
        });
    
 });

    
  }


 removeNots() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
 await Firestore.instance.collection('users').document(prefs.getString('uid')).setData({
   'ratingCount': 0
 },merge: true);
  }
  
  void initState() {
    localStorage();
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black87,
          elevation: 0.0,iconTheme: IconThemeData(color: Colors.white),
          title: isBooked == false ? Text(
            'Rating',
            style: TextStyle(
              fontSize: 20.0,letterSpacing: .4,
              color: Colors.white,fontFamily: 'NunitoSans',fontWeight: FontWeight.w600),
          ): Text(''),
        ),
        body: isBooked ? ListView(children: <Widget>[
          Column(
          children: <Widget>[
           Container(
              height: 235.0,
              color: Colors.black87,
              child: Column(
                children: <Widget>[
                  Center(
                    child: Container(
                        child: CircleAvatar(
                          backgroundColor: Colors.yellow[800],
                          backgroundImage: NetworkImage('${serviceProviderImage}'),
                          radius: 50.0,
                        )),
                  ),
                  Center(
                      child: Padding(
                        child: Text(
                          
                          '${serviceProviderName}',
                          style: TextStyle(
                            fontFamily: 'Rukie',
                            color: Colors.white, fontSize: 20.0,fontWeight: FontWeight.w400),
                        ),padding: EdgeInsets.only(top:10.0,),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Row(
                      children: <Widget>[
                        Column(children: <Widget>[
                          Text(
                            ' Duration',
                            style: TextStyle(
                               fontFamily: 'NunitoSans',
                                color: Colors.white,
                                fontSize: 17.6,
                                letterSpacing: .5,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            '${serviceHours}',
                            style:
                            TextStyle(
                              letterSpacing: .5,
                              fontFamily: 'Rukie',
                              color: Colors.white, fontSize: 18.6,fontWeight: FontWeight.w600,height: 2.0),
                          )
                        ]),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(color: Colors.white))),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              'Total Cost',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                  color: Colors.white,
                                  fontSize: 17.6,
                                  letterSpacing: .5,
                                  fontWeight: FontWeight.w300),
                            ),
                            Text(
                              '${serviceProviderPrice}',
                              style: TextStyle(
                                 fontFamily: 'Rukie',
                                 letterSpacing: .5,
                                  color: Colors.white, fontSize: 18.6,fontWeight: FontWeight.w600,height: 2.0),
                            )
                          ],
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 12.0,
                  ),
                  Center(
                    child: Text(
                      'Rate the service provider',
                      style: TextStyle(fontSize: 16.6),
                    ),
                  ),
                  SizedBox(height: 8.0,),
                  Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.star,
                              color: rating1 == 1
                                  ? Colors.yellow[500]
                                  : Colors.black12,size: 25.0,),
                            onPressed: () {

                              if (rating1 >= 1) {
                                setState(() {
                                  rating1 = 0;
                                });
                              }
                              setState(() {
                                rating = 1;
                                rating1 += 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.star,size: 25.0,
                                color: rating2 == 1
                                    ? Colors.yellow[500]
                                    : Colors.black12),
                            onPressed: () {

                              if (rating2 >= 1) {
                                setState(() {
                                  rating2 = 0;
                                });
                              }
                              setState(() {
                                rating = 2;
                                rating2 += 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.star,size: 25.0,
                                color: rating3 >= 1
                                    ? Colors.yellow[500]
                                    : Colors.black12),
                            onPressed: () {

                              if (rating3 >= 1) {
                                setState(() {
                                  rating3 = 0;
                                });
                              }
                              setState((){
                                rating = 3;

                                rating3 += 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.star,size:25.0,
                                color: rating4 >= 1
                                    ? Colors.yellow[500]
                                    : Colors.black12),
                            onPressed: () {

                              if (rating4 >= 1) {
                                setState(() {
                                  rating4 = 0;
                                });
                              }
                              setState((){
                                rating = 4;
                                rating4 += 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.star,size: 25.0,
                                color: rating5 >= 1
                                    ? Colors.yellow[500]
                                    : Colors.black12),
                            onPressed: () {

                              if (rating5 >= 1) {
                                setState(() {
                                  rating5 = 0;
                                });
                              }
                              setState((){
                                rating = 5;
                                rating5 += 1;
                              });
                            },
                          )
                        ],
                      )),
                      // text field to be added here
                      SizedBox(height: 26.0,),
                      Padding(child: TextFormField(
                        maxLength: 500,
                        maxLines: 2,
          keyboardType: TextInputType.multiline,
          controller: _rateCommentCtrl,
          decoration:
              InputDecoration(labelText: 'Leave a review',
                hintText: 'Mobile Number',
                // border: OutlineInputBorder()
                )
        ),padding: EdgeInsets.only(left: 18.0,right:18.0),),
      Container(
        margin: EdgeInsets.only(top: 10.0),
        child: FlatButton(
        
          onPressed: () {
            makeServiceRequest(_rateCommentCtrl.text);
          },
          child: Padding(
            child: Text(
              'Submit',
              style: TextStyle(
                 fontFamily: 'NunitoSans',
                  color: Colors.white,
                  letterSpacing: .5,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            padding: EdgeInsets.only(top: 11.0, bottom: 11.0),
          ),
          color: Colors.blueAccent,
        ),width: 300,)

                ],
              ),
            )
          ],
        )
        ],) : isBooked == false ? Center(child: Text('Please request for a service and rate after'),) : Center(child: CircularProgressIndicator(),),
        // bottomNavigationBar: isBooked ? ,
        backgroundColor: Colors.white),onWillPop: (){
            Navigator.push(
            context, MaterialPageRoute(builder: (context) => Swiper()));
            return Future.value(false);
        },);
  }
}
