import 'package:flutter/material.dart';
import './contacts.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './viewfull_image.dart';
import './watchvideo.dart';

class CategoriesAll {
  final String nationalId;
  final bool isRequested;
  final String servicePhotoUrl;
  final String serviceCategoryId;
  final String serviceOfferedId;
  final String fullName;
  final String serviceCategoryName;
  final String time;
  final String location;
  final String serviceOffered;
  final String uid;
  final String price;
  final String serviceProviderToken;
  final bool statusNotRequired;
  final bool isVideo;

  CategoriesAll(
      {this.nationalId,
        this.isRequested,
        this.servicePhotoUrl,
        this.serviceCategoryId,
        this.fullName,
        this.serviceCategoryName,
        this.time,
        this.location,
        this.serviceOffered,
        this.serviceOfferedId,
        this.uid,
        this.price,this.serviceProviderToken,this.statusNotRequired,this.isVideo});

  factory CategoriesAll.fromJson(Map<String, dynamic> json) {
    return CategoriesAll(
        nationalId: json['nationalId'],
        isRequested: json['isRequested'],
        servicePhotoUrl: '${json['servicePhotoUrl']}',
        serviceCategoryId: json['serviceCategoryId'],
        fullName: json['fullName'],
        serviceCategoryName: json['serviceCategoryName'],
        time: json['time'],
        location: json['location'],
        serviceOffered: json['serviceOffered'],
        serviceOfferedId: json['serviceOffered'],
        price: '${json['price']}',
        uid: json['uid'],
        serviceProviderToken: json['serviceProviderToken'],
        statusNotRequired: json['statusNotRequired'],
        isVideo: json['isVideo']
    );
  }
}

class ItemViewer extends StatefulWidget {
  String categoryType;
  ItemViewer({this.categoryType});
  @override
  ItemViewerState createState() => ItemViewerState();
}

class ItemViewerState extends State<ItemViewer> {
  List<CategoriesAll> resultsFetched = List();
  String _categoryType;
  String _userId;
  bool notAvailable;

  fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('uid');
    });
    final response = await http.get(
        'https://viking-250012.appspot.com/api/all-feeds/$_categoryType');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);
      setState(() {
        resultsFetched = (json.decode(response.body) as List)
            .map((data) => new CategoriesAll.fromJson(data))
            .toList();
        notAvailable = resultsFetched.length == 0 ? true : false;
      });

      return resultsFetched;
    } else {
      throw Exception('Oops something wrong');
    }
  }

  initState() {
    _categoryType = widget.categoryType;
    print(_categoryType);
    fetchCategories();
    super.initState();
  }

  String stringChopper(String word) {
    if (word.length > 16) {
      return word.substring(0, 16) + '...';
    } else {
      return word;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.black87),
          title: Text(
            'Explore',
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 1.3),
      body: resultsFetched.length > 0
          ? ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return  Padding(
  padding: new EdgeInsets.all(0.0),
  child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
               
                Flexible(
                  fit: FlexFit.tight,
                  flex: 460,
                  child: resultsFetched[index].isVideo == true ? InkWell(
                                                child: Container(
                                                  color: Colors.black,
                                                  child: Stack(children: <Widget>[
                                                    Center(child: Icon(Icons.play_circle_filled,color: Colors.white,size: 56.0,))
                                                  ],),
                                                ),
                                          onTap: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WatchVideo(
                                                          serviceName: resultsFetched[index].serviceOffered,
                                                          photoUrl: resultsFetched[index].servicePhotoUrl,
                                                          isVideo: resultsFetched[index].isVideo,
 )));
                                          },
                                              ): InkWell(
                    child: new Image.network(
                    "${resultsFetched[index].servicePhotoUrl}",
                    fit: BoxFit.cover,
                  ),
                  onTap: (){
                    Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => ServicesContacts(
  uid: '${resultsFetched[index].uid}',
  serviceOffered:
  '${resultsFetched[index].serviceOffered}',
  userId: '$_userId',
  location: '${resultsFetched[index].location}',
  price: '${resultsFetched[index].price}',
  serviceProviderToken: '${resultsFetched[index].serviceProviderToken}',
  duration: '${resultsFetched[index].time}'
  )));
                  },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:1.0,left: 16.0,right: 16.0,bottom: 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${ stringChopper(resultsFetched[index].serviceOffered)}',
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0)
                          )
                        ],
                      ),
                      // HERE
                resultsFetched[index].isVideo == true ?   IconButton(
                        icon:  Icon(FontAwesomeIcons.externalLinkSquareAlt,size: 20.0,),
                        onPressed: (){
                  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => ServicesContacts(
  uid: '${resultsFetched[index].uid}',
  serviceOffered:
  '${resultsFetched[index].serviceOffered}',
  userId: '$_userId',
  location: '${resultsFetched[index].location}',
  price: '${resultsFetched[index].price}',
  serviceProviderToken: '${resultsFetched[index].serviceProviderToken}',
  duration: '${resultsFetched[index].time}'
  )));                      },
                      ): IconButton(
                        icon:  Icon(Icons.visibility),
                        onPressed: (){
  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(serviceName: resultsFetched[index].serviceOffered,photoUrl: resultsFetched[index].servicePhotoUrl,)));
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 0.3),
                  child: Text(
                    "${resultsFetched[index].price}",
                    style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18.0,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5.0),
                  child: Row(children: <Widget>[
  Icon(Icons.access_time,color: Colors.grey[500],size: 13.8,),
  Text(
  '${resultsFetched[index].time}',
  maxLines: 1,style: TextStyle(fontSize: 13.8,fontWeight: FontWeight.w300,fontFamily: 'foo',

  ),
 
  )
  ]) // ,mainAxisAlignment: MainAxisAlignment.left,
                ,
                ),
                SizedBox(height: 5.0,)
              ],
            )
  );
        },
//              padding: EdgeInsets.all(1.0),
        itemExtent: 460.0,
        itemCount: resultsFetched.length,
      )
          : notAvailable == true
          ? Center(
        child: Text('Services have not been added yet'),
      )
          : Center(
        child: CircularProgressIndicator(strokeWidth: 5.0),
      ),
      backgroundColor: Colors.white,
    );
  }
}
