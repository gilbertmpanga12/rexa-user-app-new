import 'package:rxdart/rxdart.dart';

class Linker {
  PublishSubject pictureListener = PublishSubject();
  PublishSubject changeLocale = PublishSubject();
  PublishSubject linkerListener = PublishSubject();
  

}

final Linker linkerService = Linker();