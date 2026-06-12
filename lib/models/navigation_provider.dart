import 'package:flutter/material.dart';

// مُتحكم عالمي منفصل لمنع تداخل الملفات ولضمان سرعة الاستجابة
final ValueNotifier<int> globalTabIndex = ValueNotifier<int>(0);
