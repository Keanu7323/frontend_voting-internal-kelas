import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../theme.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<VotingProvider>(context, listen: false);
    bool success = false;

    if (_isLogin) {
      success = await provider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await provider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Auto login after successful registration
        success = await provider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    }

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // Error handling is done in the provider, just show snackbar
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
          ),
        );
        provider.clearError();
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak sama';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VotingProvider>(
        builder: (context, provider, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.how_to_vote,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text('VoteIt', style: AppTextStyle.title),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Masuk ke akun Anda' : 'Buat akun baru',
                      style: AppTextStyle.subtitle.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    if (!_isLogin) ...[
                      CustomTextField(
                        hint: 'Nama Lengkap',
                        controller: _nameController,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      hint: 'Email',
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: 'Password',
                      controller: _passwordController,
                      obscure: true,
                      validator: _validatePassword,
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        hint: 'Konfirmasi Password',
                        controller: _confirmPasswordController,
                        obscure: true,
                        validator: _validateConfirmPassword,
                      ),
                    ],

                    const SizedBox(height: 24),

                    CustomButton(
                      label: provider.isLoading
                          ? 'Loading...'
                          : (_isLogin ? 'Masuk' : 'Daftar'),
                      onPressed: provider.isLoading ? () {} : _submit,
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(
                        _isLogin
                            ? 'Belum punya akun? Daftar di sini'
                            : 'Sudah punya akun? Masuk di sini',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}