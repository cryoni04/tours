import 'package:flutter/material.dart';

class MyNavigator {
  
  static void goReplace(BuildContext context, String routeName){
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void goReplaceAll(BuildContext context, String routeName){
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }

  static void gotTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}
