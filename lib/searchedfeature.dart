import 'package:flutter/material.dart';


class SearchWid extends StatefulWidget {
  SearchWidState createState() => SearchWidState();
}

class SearchWidState extends State<SearchWid> {
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 1.0
      ),
      body: Center(child: Text('Search for services'),)
    );
  }
}
