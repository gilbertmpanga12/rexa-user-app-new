import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './app_services/localizer.dart';

class PlaceholderWid extends StatefulWidget {
  @override
  PlaceholderWidState createState() => PlaceholderWidState();
}

class History {
  final String requestedSaloonService;
  final String timeStamp;
  final String priceRequested;
  History({this.requestedSaloonService, this.timeStamp, this.priceRequested});
  factory History.fromJson(Map<String, dynamic> json) {
    return History(
        requestedSaloonService: json['requestedSaloonService'],
        timeStamp: '${json['timeStamp']}',
        priceRequested: '${json['priceRequested']}');
  }
}

class PlaceholderWidState extends State<PlaceholderWid> {
  List<History> resultsFetched = List();
  String uid;
  bool requestFailed = false;
  bool requestPassed = false;
  bool test = false;
  String errorMessage;

  fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      final response = await http.get(
          'https://young-tor-95342.herokuapp.com/api/get-user-history/${prefs.getString('uid')}');
      if (response.statusCode == 200 || response.statusCode == 201) {
       
        setState(() {
          resultsFetched = (json.decode(response.body) as List)
              .map((data) => new History.fromJson(data))
              .toList();
          requestPassed = resultsFetched.length > 0;
          requestFailed = requestPassed == false;
        });

        return resultsFetched;
      } else {
        requestFailed = true;
        errorMessage = response.body;
        throw Exception('Oops something wrong');
      }
    }catch(err){
      requestFailed = true;
    }
  }

  String _DateFormater(String date) {
    final List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    try{
      print(date);
      final today = DateTime.parse(date.toString());
    String dateSlug =
        "${daysOfWeek[today.weekday]} ${months[today.month][0].toUpperCase() + months[today.month].substring(1,)} ${today.year.toString()} ${today.hour.toString().padLeft(2, '0')}:${today.minute.toString().padLeft(2, '0')}";
    return dateSlug;
    }catch(err){
      return '';
    }
  }

  initState() {
    fetchHistory();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            DemoLocalizations.of(context).history,
     style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w900,fontSize: 20),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: resultsFetched.length > 0
            ? ListView.separated(
              separatorBuilder: (context, index) =>  Divider(),
                itemCount: resultsFetched.length,
                itemBuilder: (context, i) {
                  return new Column(
                      children: <Widget> [
                      //  SizedBox(height: 13.0,),
                        


Container(
  padding: EdgeInsets.only(top: 5.0,bottom: 13.0),
  height: 60.0,
  child: ListTile(
  title:  Text(
   '${resultsFetched[i].requestedSaloonService}',
  style: TextStyle(fontFamily: 'Comfortaa',fontWeight: FontWeight.w600),
    ),
    subtitle: new Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: new Text(
                              '${resultsFetched[i].timeStamp}',
                              style: new TextStyle(letterSpacing: -1,
                                  color: Colors.grey, fontSize: 14.0),
                              softWrap: true,
                            ),
                          ),
  trailing: Text(
                            '${resultsFetched[i].priceRequested == 'null' ? 'N/A': resultsFetched[i].priceRequested}',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 17.0),
                          )
),)
                        
                      ],
                    );
                }
              ): requestFailed
? Center(
                    child: Text('You have no history'),
                  ): Center(
                    child: CircularProgressIndicator(strokeWidth: 5.0),
                  ),
        backgroundColor: Colors.white);
  }

}