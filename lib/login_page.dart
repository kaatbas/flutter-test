import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormFilled = false; // Kilit ikonu durumu için yeni state

  final Color primaryColor = const Color(0xFF0A7AFF); // iOS Mavisi
  final Color accentColor =
      const Color(0xFF00C6AE); // Ek bir canlı renk (Turkuaz/Yeşil tonu)
  final Color backgroundColor = const Color(0xFFF2F2F7);
  final Color cardBackgroundColor = Colors.white;
  final Color textFieldFillColor =
      Colors.grey.shade50; // Daha yumuşak bir dolgu
  final Color textColor = Colors.black87;
  final Color hintColor = Colors.grey.shade600;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateFormFilledState);
    _passwordController.addListener(_updateFormFilledState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateFormFilledState);
    _passwordController.removeListener(_updateFormFilledState);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateFormFilledState() {
    setState(() {
      _isFormFilled = _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Giriş başarılı!',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: accentColor.withOpacity(0.8)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş yapılırken bir hata oluştu.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorMessage = 'E-posta veya şifre hatalı.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz e-posta formatı.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(errorMessage, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegistrationPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RegistrationPage()));
  }

  void _forgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Şifre sıfırlama için lütfen e-posta adresinizi girin.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orangeAccent.shade700),
      );
      return;
    }
    // TODO: Firebase şifre sıfırlama işlevselliği
    // FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Şifre sıfırlama e-postası ' +
                  _emailController.text.trim() +
                  ' adresine gönderilecektir (işlevsellik yakında).',
              style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Hoş Geldiniz',
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        backgroundColor: Colors.transparent, // Şeffaf AppBar
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Üst İkon/Logo Alanı
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20.0,
                      top: 0), // AppBar'a yakınsa top padding azaltılabilir
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _isFormFilled
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      key: ValueKey<bool>(
                          _isFormFilled), // İkon değiştiğinde animasyon için
                      size: 70,
                      color: primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
                Card(
                  elevation: 5.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  color: cardBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'E-posta Adresiniz',
                              hintStyle: TextStyle(
                                  color: hintColor,
                                  fontWeight: FontWeight.normal),
                              filled: true,
                              fillColor: textFieldFillColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none),
                              prefixIcon: Icon(Icons.alternate_email_rounded,
                                  color: primaryColor.withOpacity(0.7)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Lütfen e-posta adresinizi girin.';
                              if (!RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value))
                                return 'Lütfen geçerli bir e-posta adresi girin.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Şifreniz',
                              hintStyle: TextStyle(
                                  color: hintColor,
                                  fontWeight: FontWeight.normal),
                              filled: true,
                              fillColor: textFieldFillColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none),
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: primaryColor.withOpacity(0.7)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Lütfen şifrenizi girin.';
                              return null;
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 16.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isLoading ? null : _forgotPassword,
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0)),
                                child: Text('Şifremi Unuttum?',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: _isLoading ? 0 : 3,
                            ),
                            onPressed: _isLoading ? null : _signIn,
                            child: _isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text('Giriş Yap',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabınız yok mu?',
                        style: TextStyle(
                            color: textColor.withOpacity(0.9), fontSize: 15)),
                    TextButton(
                      onPressed: _isLoading ? null : _goToRegistrationPage,
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                      child: Text('Hemen Kayıt Olun',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
