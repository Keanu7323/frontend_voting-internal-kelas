import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import 'home_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

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
                hint: 'Masukkan Nama Anda',
                controller: controller,  // <-- Penting!
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Masuk',
                onPressed: () {
                  print('Nama yang dimasukkan: ${controller.text}');
                  if (controller.text.isNotEmpty) {
                    Provider.of<VotingProvider>(context, listen: false)
                        .login(controller.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  } else {
                    print('Nama kosong, tidak bisa login');
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
