import 'package:meatzo/core/network/api_client.dart';
import 'package:meatzo/core/network/dio_client.dart';
import 'package:meatzo/data/repositories/auth_repository.dart';
import 'package:meatzo/features/auth/logic/domain/auth/otp_verification_cubit.dart';
import 'package:meatzo/features/auth/logic/domain/auth/otp_verification_state.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:meatzo/screens/AuthScreen/custome_Next_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? otp; // Accept OTP from server

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.otp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String get otp => otpControllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {});
    });

    // Autofill OTP from server (optional)
    if (widget.otp != null && widget.otp!.length == 6) {
      for (int i = 0; i < 6; i++) {
        otpControllers[i].text = widget.otp![i];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<Otpverificationcubit>(
      create: (_) =>
          Otpverificationcubit(AuthRepository(ApiClient(DioClient.dio))),
      child: BlocConsumer<Otpverificationcubit, OtpVerificationState>(
          listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Otp verified '),
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state is OtpVerificationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }
      }, builder: (context, state) {
        final cubit = context.read<Otpverificationcubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Verify OTP'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter the OTP sent to ${widget.phoneNumber}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                if (widget.otp != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Auto OTP: ${widget.otp}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index - 1]);
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                if (state is OtpVerificationLoading)
                  const CircularProgressIndicator()
                else
                  const SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    cubit.verifyOtp(
                      widget.phoneNumber,
                      otp,
                    );
                  },
                  text: 'Verify OTP',
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Row(
                    children: [
                      Text(
                        "Didn't receive code?",
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Resend Again.",
                        style: TextStyle(fontSize: 17, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "By Signing up you agree to our Terms Conditions & Privacy Policy.",
                    style: TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
