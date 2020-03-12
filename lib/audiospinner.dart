import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget audioSpinner(String commenterPhotoUrl) {
  return Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
          gradient: audioDiscGradient,
          shape: BoxShape.circle,
          image:
              DecorationImage(
                        image: new CachedNetworkImageProvider(
                       commenterPhotoUrl),
                          fit: BoxFit.cover,
                            )));
}

LinearGradient get audioDiscGradient => LinearGradient(colors: [
      Colors.grey[800],
      Colors.grey[900],
      Colors.grey[900],
      Colors.grey[800]
    ], stops: [
      0.0,
      0.4,
      0.6,
      1.0
    ], begin: Alignment.bottomLeft, end: Alignment.topRight);