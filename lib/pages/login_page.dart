import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final TextEditingController controller = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.how_to_vote, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('VoteIt', style: AppTextStyle.title),
              const SizedBox(height: 32),

              CustomTextField(
                label: 'Email',
                hint: 'Masukan Email Anda',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              CustomTextField(
                label: 'Password',
                hint: 'Masukan Password Anda',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Masuk',
                onPressed: () {
                  // print('Nama yang dimasukkan: ${controller.text}');
                  if (_emailController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    // Provider.of<VotingProvider>(context, listen: false).login(
                    //   email: _emailController.text,
                    //   password: _passwordController.text,
                    // );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  } else {
                    print('Email atau Password kosong, tidak bisa login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
