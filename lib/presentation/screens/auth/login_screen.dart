import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../config/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading = true;

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // بعد تسجيل الدخول بنجاح، انتقل إلى الصفحة التالية
      if (mounted) {
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تسجيل الدخول: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
         _isLoading = false;
        Navigator.of(context).pushReplacementNamed('/dashboard'); // استبدل '/home' بمسار الصفحة التي تريد الانتقال إليها

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شعار التطبيق
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/car_logo.png',
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // عنوان التطبيق
                  Text(
                    'إدارة السيارات',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // وصف مختصر للتطبيق
                  Text(
                    'أدر مخزون سياراتك بكل سهولة',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // حقل البريد الإلكتروني
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'البريد الإلكتروني',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'كلمة المرور',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // زر تسجيل الدخول
                  CustomButton(
                    text: 'تسجيل الدخول',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}