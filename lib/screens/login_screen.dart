import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController ;
  late final TextEditingController _passwordController ;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Valeurs pré-remplies pour le développement
    _emailController = TextEditingController(text: "jilanimed07@gmail.com");
    _passwordController = TextEditingController(text: "jilajila");
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        Provider.of<AuthProvider>(context, listen: false).login(user);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _error = "Email ou mot de passe incorrect.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Une erreur s'est produite.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: "Email",
                validator:
                    (value) => value!.isEmpty ? "Entrez votre email" : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _passwordController,
                label: "Mot de passe",
                isPassword: true,
                validator:
                    (value) =>
                        value!.isEmpty ? "Entrez votre mot de passe" : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "Se connecter",
                isLoading: _isLoading,
                onPressed: () => _login(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
