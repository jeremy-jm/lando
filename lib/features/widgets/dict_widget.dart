import 'package:flutter/material.dart';
import 'package:lando/models/result_model.dart';

class DictWidget extends StatefulWidget {
  const DictWidget({super.key, required this.result});
  final ResultModel result;

  @override
  State<DictWidget> createState() => _DictWidgetState();
}

class _DictWidgetState extends State<DictWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('ResultWidget'));
  }
}
