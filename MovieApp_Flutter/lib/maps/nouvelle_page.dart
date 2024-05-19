import 'package:flutter/material.dart';

class NouvellePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nouvelle Page"),
      ),
      body: Center(
        child: Text(
          "Hello Cinema",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
