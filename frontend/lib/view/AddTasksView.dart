import 'package:flutter/material.dart';

class Addtasksview extends StatelessWidget {
  const Addtasksview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Task"),
      ),
    );
  }
}