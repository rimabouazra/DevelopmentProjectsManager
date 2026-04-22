import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/view/signUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;
  bool _loading       = false;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }
    setState(() => _loading = true);
    AuthHelper().LogInUser(
      context: context,
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Row(children: [
        // ── Formulaire gauche ──────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.layers_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('DevManager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          )),
                    ]),
                    const SizedBox(height: 36),

                    // Titre
                    const Text('Bon retour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    const Text('Connectez-vous à votre espace de travail',
                        style: TextStyle(
                          color: AppColors.textNavyMuted, fontSize: 13)),
                    const SizedBox(height: 28),

                    // Email
                    _FieldLabel('Adresse email'),
                    const SizedBox(height: 5),
                    _DarkField(
                      controller: _emailCtrl,
                      hint: 'nom@entreprise.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Mot de passe
                    _FieldLabel('Mot de passe'),
                    const SizedBox(height: 5),
                    _DarkField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textNavyMuted, size: 16),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Bouton connexion
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Se connecter'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lien inscription
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Pas encore de compte ?',
                          style: TextStyle(
                            color: AppColors.textNavyMuted, fontSize: 12)),
                      TextButton(
                        onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                            builder: (_) => const SignupPage())),
                        child: const Text("S'inscrire",
                          style: TextStyle(
                            color: AppColors.blueLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Panneau droit ──────────────────────────────────────────────────
        Container(
          width: 260,
          color: AppColors.navyMid,
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pourquoi DevManager ?',
                    style: TextStyle(
                      color: AppColors.textNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                SizedBox(height: 20),
                _Feature('Projets centralisés'),
                _Feature('Rôles & permissions'),
                _Feature('Suivi en temps réel'),
                _Feature('Tableaux de bord'),
                _Feature('Collaboration équipe'),
                _Feature('Notifications intégrées'),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textNavyMuted,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.06,
      ));
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  const _DarkField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textNavyMuted, fontSize: 13),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  final String label;
  const _Feature(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [
      Container(
        width: 6, height: 6,
        decoration: const BoxDecoration(
          color: AppColors.blue, shape: BoxShape.circle),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: const TextStyle(
            color: AppColors.textNavy, fontSize: 12)),
    ]),
  );
}