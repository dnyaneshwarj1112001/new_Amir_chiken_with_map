import 'package:flutter/material.dart';

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({super.key});

  @override
  State<EditprofileScreen> createState() => _EditprofileScreenState();
}

class _EditprofileScreenState extends State<EditprofileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT ACCOUNT"),
      ),
      body: Form(
        child: Column(
          children: [
            TextFormField()
            ],
        ),
      ),
    );
  }
}
