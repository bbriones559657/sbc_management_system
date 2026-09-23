import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/demo_user.dart';

class DemoLoginScreen extends StatefulWidget {
  final ValueChanged<DemoUser> onSignedIn;

  const DemoLoginScreen({
    super.key,
    required this.onSignedIn,
  });

  @override
  State<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends State<DemoLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _error;

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    final user = DemoUser.authenticate(
      _usernameController.text,
      _passwordController.text,
    );

    if (user == null) {
      setState(() => _error = 'Incorrect username or password.');
      return;
    }

    widget.onSignedIn(user);
  }

  void _useDemoAccount(String username) {
    _usernameController.text = username;
    _passwordController.text = '123';
    setState(() => _error = null);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 430,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Street Bowl Café', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  const Text(
                    'MANAGEMENT SYSTEM',
                    style: AppTextStyles.overline,
                  ),
                  const SizedBox(height: 28),
                  const Text('Sign in', style: AppTextStyles.h2),
                  const SizedBox(height: 6),
                  Text(
                    'Use a prototype account to continue.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _usernameController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Username is required.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onFieldSubmitted: (_) => _signIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Password is required.'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 46,
                    child: FilledButton(
                      onPressed: _signIn,
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DEMO ACCOUNTS',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DemoAccountButton(
                    role: 'Admin',
                    access: 'All modules',
                    onTap: () => _useDemoAccount('admin'),
                  ),
                  const SizedBox(height: 8),
                  _DemoAccountButton(
                    role: 'Cashier',
                    access: 'Orders and inventory operations',
                    onTap: () => _useDemoAccount('cashier'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Both demo accounts use password: 123',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray500,
                    ),
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

class _DemoAccountButton extends StatelessWidget {
  final String role;
  final String access;
  final VoidCallback onTap;

  const _DemoAccountButton({
    required this.role,
    required this.access,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role, style: AppTextStyles.bodyMedium),
                    Text(access, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: AppColors.gray500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
