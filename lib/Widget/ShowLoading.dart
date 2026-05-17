import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/Them.dart';


Widget showLoading() => Center(
  child: CircularProgressIndicator(
    color: Themes().GetColor("primary"),
  ),
);