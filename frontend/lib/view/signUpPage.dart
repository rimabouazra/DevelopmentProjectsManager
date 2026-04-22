import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/model/User.dart';
import 'package:frontend/model/auth_helper.dart';
import 'package:frontend/view/LoginPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;
  bool _loading       = false;
  Role _role          = Role.Developer;

  final _roles = const [
    (role: Role.Developer,     label: 'Développeur',    icon: Icons.code_rounded),
    (role: Role.Manager,       label: 'Manager',         icon: Icons.manage_accounts_rounded),
    (role: Role.Administrator, label: 'Administrateur', icon: Icons.admin_panel_settings_rounded),
  ];

  Future<void> _signup() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }
    setState(() => _loading = true);
    AuthHelper().signUpUser(
      context: context,
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      name: _nameCtrl.text.trim(),
      role: _role,
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Row(children: [
        // ── Formulaire ────────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
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
                          )),
                    ]),
                    const SizedBox(height: 36),

                    const Text('Créer un compte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    const Text('Rejoignez votre espace de travail',
                        style: TextStyle(
                          color: AppColors.textNavyMuted, fontSize: 13)),
                    const SizedBox(height: 28),

                    // Nom
                    _buildLabel('Nom complet'),
                    const SizedBox(height: 5),
                    _buildField(
                      controller: _nameCtrl,
                      hint: 'Jean Dupont',
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _buildLabel('Adresse email'),
                    const SizedBox(height: 5),
                    _buildField(
                      controller: _emailCtrl,
                      hint: 'nom@entreprise.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Mot de passe
                    _buildLabel('Mot de passe'),
                    const SizedBox(height: 5),
                    _buildField(
                      controller: _passwordCtrl,
                      hint: '8 caractères minimum',
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textNavyMuted, size: 16),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sélection rôle
                    _buildLabel('Rôle'),
                    const SizedBox(height: 8),
                    Row(children: _roles.map((r) {
                      final selected = _role == r.role;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _role = r.role),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.blue.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              border: Border.all(
                                color: selected
                                    ? AppColors.blue
                                    : Colors.white.withOpacity(0.12),
                                width: selected ? 1.5 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(children: [
                              Icon(r.icon,
                                color: selected
                                    ? AppColors.blueLight
                                    : AppColors.textNavyMuted,
                                size: 18),
                              const SizedBox(height: 5),
                              Text(r.label,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.blueLight
                                      : AppColors.textNavyMuted,
                                  fontSize: 10,
                                  fontWeight: selected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                          ),
                        ),
                      );
                    }).toList()),
                    const SizedBox(height: 24),

                    // Bouton
                    SizedBox(
                      width: double.infinity, height: 42,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signup,
                        child: _loading
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text("Créer mon compte"),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lien connexion
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Déjà un compte ?',
                          style: TextStyle(
                            color: AppColors.textNavyMuted, fontSize: 12)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage())),
                        child: const Text('Se connecter',
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

        // ── Panneau droit ─────────────────────────────────────────────────
        Container(
          width: 240,
          color: AppColors.navyMid,
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commencez gratuitement',
                    style: TextStyle(
                      color: AppColors.textNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                SizedBox(height: 8),
                Text('Gérez vos projets et collaborez avec votre équipe dès aujourd\'hui.',
                    style: TextStyle(
                      color: AppColors.textNavyMuted, fontSize: 12,
                      height: 1.6,
                    )),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLabel(String text) => Text(text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textNavyMuted,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.06,
      ));

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) => TextField(
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