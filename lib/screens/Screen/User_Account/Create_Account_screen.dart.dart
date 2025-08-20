import 'package:meatzo/screens/AuthScreen/custome_Next_button.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:meatzo/screens/AuthScreen/Phone_Auth_page.dart';

import 'package:meatzo/screens/Screen/User_Account/custometextfield/CustomTextFormField.dart';
import 'package:meatzo/screens/Screen/User_Account/user_create_bloc.dart';
import 'package:meatzo/screens/Screen/User_Account/user_create_event.dart';
import 'package:meatzo/screens/Screen/User_Account/user_create_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Create_Account_screen extends StatefulWidget {
  const Create_Account_screen({super.key});

  @override
  State<Create_Account_screen> createState() => _Create_Account_screenState();
}

class _Create_Account_screenState extends State<Create_Account_screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _mobileNumer = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _pincode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const Gaph(
                height: 20,
              ),
              const Text(
                "Enter your information for sign up.",
                style: TextStyle(fontSize: 16),
              ),
              const Gaph(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PhoneAuthScreen()));
                        },
                        child: const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 17, color: Colors.red),
                        ),
                      ),
                    ),
                    const Gaph(height: 20),
                    BlocBuilder<UserCreateBloc, UserCreateState>(
                      builder: (context, state) {
                        if (state is emtytext) {
                          return Container();
                        } else if (state is UserTextInvalidState) {
                          return Text(
                            state.message,
                            style: const TextStyle(fontSize: 17, color: Colors.red),
                          );
                        }
                        return Container();
                      },
                    ),
                    TextFormField(
                      controller: _textController,
                      onChanged: (value) {
                        BlocProvider.of<UserCreateBloc>(context).add(
                          EmailTextChangeEvent(_textController.text),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your Email",
                        suffixIcon:
                            BlocBuilder<UserCreateBloc, UserCreateState>(
                          builder: (context, state) {
                            return Icon(Icons.check, // Check icon
                                color: (state is UserTextInvalidState)
                                    ? Colors.red
                                    : Colors.green
                                // Optional: Set the color of the icon
                                );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const Gaph(height: 20),
                    CustomTextFormField(
                      keyboardType: TextInputType.number,
                      controller: _mobileNumer,
                      hintText: "Enter Mobile Number",
                      labelText: "Mobile No",
                      suffixIconBuilder: (context) {
                        return Icon(
                          _mobileNumer.text.isNotEmpty &&
                                  _mobileNumer.text.length == 10
                              ? Icons.check
                              : (_mobileNumer.text.isNotEmpty &&
                                      _mobileNumer.text.length < 10
                                  ? Icons.error
                                  : null),
                          color: _mobileNumer.text.isNotEmpty &&
                                  _mobileNumer.text.length == 10
                              ? Colors.green
                              : (_mobileNumer.text.isNotEmpty &&
                                      _mobileNumer.text.length < 10
                                  ? Colors.red
                                  : Colors.transparent),
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mobile number cannot be empty";
                        } else if (value.length != 10) {
                          return "Enter a valid 10-digit mobile number";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(
                            () {}); // Triggers UI update for the suffix icon
                      },
                    ),
                    const Gaph(height: 20),
                    CustomTextFormField(
                        keyboardType: TextInputType.text,
                        controller: _userName,
                        labelText: "User Name",
                        hintText: "Enter User Name"),
                    const Gaph(height: 20),
                    CustomTextFormField(
                        keyboardType: TextInputType.number,
                        controller: _pincode,
                        labelText: "Pin Code",
                        hintText: "Please Enter the Pin code"),
                    const Gaph(height: 20),
                    CustomButton(
                      text: "SIGN UP",
                      onPressed: () {},
                    ),
                    const Gaph(height: 20),
                    const Center(
                      child: Text(
                        "By Signing up you agree to our Terms Conditions & Privacy Policy.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
