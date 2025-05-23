import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false; // Yükleme durumu için state

  // Renkler (LoginPage ile aynı)
  final Color primaryColor = const Color(0xFF0A7AFF);
  final Color accentColor = const Color(0xFF00C6AE);
  final Color backgroundColor = const Color(0xFFF2F2F7);
  final Color cardBackgroundColor = Colors.white;
  final Color textFieldFillColor = Colors.grey.shade50;
  final Color textColor = Colors.black87;
  final Color hintColor = Colors.grey.shade600;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Şifreler eşleşmiyor!',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orangeAccent.shade700),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Kayıt başarılı! Lütfen giriş yapın.',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: accentColor.withOpacity(0.8)),
        );
        Navigator.pop(context); // Giriş ekranına geri dön
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Kayıt sırasında bir hata oluştu.';
      if (e.code == 'weak-password') {
        errorMessage = 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Yeni Hesap Oluştur',
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.transparent, // Şeffaf AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor), // Geri butonu için
        centerTitle: true,
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
                // Üst İkon/Logo Alanı (isteğe bağlı, login ile aynı veya farklı olabilir)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 0),
                  child: Icon(Icons.person_add_alt_1_rounded,
                      size: 60, color: primaryColor.withOpacity(0.8)),
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
                              hintText: 'Şifre Belirleyin',
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
                                return 'Lütfen bir şifre girin.';
                              if (value.length < 6)
                                return 'Şifre en az 6 karakter olmalıdır.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Şifreyi Tekrar Girin',
                              hintStyle: TextStyle(
                                  color: hintColor,
                                  fontWeight: FontWeight.normal),
                              filled: true,
                              fillColor: textFieldFillColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none),
                              prefixIcon: Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: primaryColor.withOpacity(0.7)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Lütfen şifrenizi tekrar girin.';
                              if (value != _passwordController.text)
                                return 'Şifreler eşleşmiyor.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: _isLoading ? 0 : 3,
                            ),
                            onPressed: _isLoading ? null : _registerUser,
                            child: _isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text('Hesap Oluştur',
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
                    Text('Zaten bir hesabınız var mı?',
                        style: TextStyle(
                            color: textColor.withOpacity(0.9), fontSize: 15)),
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                      child: Text('Giriş Yapın',
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
