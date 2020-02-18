import './comments.dart';
import './video_stories.dart';
import 'package:flutter/material.dart';
import './viewList.dart';
import './styles_beauty.dart';

final controllerPageView = PageController(initialPage: 0,keepPage: true);
class Swiper  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PageView(
      scrollDirection: Axis.horizontal,
      controller: controllerPageView,children: <Widget>[
      ViewList(),
      StylesBeautyWidget(),
      VideoStories()
    ]);
  }
}
