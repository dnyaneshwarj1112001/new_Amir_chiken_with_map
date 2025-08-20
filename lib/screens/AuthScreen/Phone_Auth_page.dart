import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meatzo/cubit/auth_cubit.dart';
import 'package:meatzo/cubit/auth_state.dart';
import 'package:meatzo/screens/AuthScreen/custome_Next_button.dart';
import 'package:meatzo/features/auth/presentation/AuthScreen/Otp_verification_page.dart';

class PhoneAuthScreen extends StatefulWidget {
  static const String id = 'PhoneAuthScreen';

  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isValid = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      isValid = value.length == 10 && RegExp(r'^[0-9]+$').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.response.message ?? 'OTP sent')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(
                    phoneNumber: phoneController.text.trim(),
                    otp: state.response.otp.toString(),
                  ),
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          "lib/innitiel_screens/images/shop1.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Get started",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Enter your mobile number to continue",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.lock, color: Colors.teal, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Your number is safe with us',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        style: const TextStyle(fontSize: 18, letterSpacing: 2),
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.teal),
                          prefixText: '+91 ',
                          labelText: 'Phone Number',
                          labelStyle: const TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.teal, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: _onChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Only digits allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: isValid && state is! AuthLoading
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().loginWithPhone(
                                      phoneController.text.trim());
                                }
                              }
                            : () {},
                        text: state is AuthLoading ? "Loading..." : "Sign In",
                      
                      ),
                      const SizedBox(height: 30),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user,
                              color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "We never share your number",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
