import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  static const String loginUrl = 'https://sijala.biz.id/api/v1/login';

  Future<void> login() async {
    // Cek validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Aktifkan loading
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(loginUrl),

        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      print('================================');
      print('LOGIN STATUS : ${response.statusCode}');
      print('LOGIN RESPONSE : ${response.body}');
      print('================================');

      dynamic decodedData;

      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {
        decodedData = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decodedData is! Map) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Response dari server tidak valid'),
              backgroundColor: Colors.red,
            ),
          );

          return;
        }

        final data = Map<String, dynamic>.from(decodedData);

        String? token;

        if (data['token'] != null) {
          token = data['token'].toString();
        }

        if ((token == null || token.isEmpty) && data['data'] is Map) {
          final dataMap = Map<String, dynamic>.from(data['data']);

          if (dataMap['token'] != null) {
            token = dataMap['token'].toString();
          }
        }

        if ((token == null || token.isEmpty) && data['access_token'] != null) {
          token = data['access_token'].toString();
        }

        if ((token == null || token.isEmpty) && data['data'] is Map) {
          final dataMap = Map<String, dynamic>.from(data['data']);

          if (dataMap['access_token'] != null) {
            token = dataMap['access_token'].toString();
          }
        }

        if (token == null || token.isEmpty) {
          print('TOKEN TIDAK DITEMUKAN');
          print('DATA API: $data');

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil, tetapi token tidak ditemukan.'),
              backgroundColor: Colors.orange,
            ),
          );

          return;
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);

        // Cek apakah token benar-benar tersimpan
        final savedToken = prefs.getString('token');

        print('TOKEN BERHASIL DISIMPAN');
        print('TOKEN: ${savedToken != null ? 'ADA' : 'TIDAK ADA'}');

        if (data['user'] is Map) {
          final user = Map<String, dynamic>.from(data['user']);

          if (user['name'] != null) {
            await prefs.setString('name', user['name'].toString());
          }

          if (user['email'] != null) {
            await prefs.setString('email', user['email'].toString());
          }

          if (user['gender'] != null) {
            await prefs.setString('gender', user['gender'].toString());
          }

          if (user['phone'] != null) {
            await prefs.setString('phone', user['phone'].toString());
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']?.toString() ?? 'Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        context.go('/dashboard');
      } else {
        String message = 'Email atau password salah';

        if (decodedData is Map) {
          final data = Map<String, dynamic>.from(decodedData);

          if (data['message'] != null) {
            message = data['message'].toString();
          }

          if (data['errors'] is Map) {
            final errors = Map<String, dynamic>.from(data['errors']);

            if (errors.isNotEmpty) {
              final firstError = errors.values.first;

              if (firstError is List && firstError.isNotEmpty) {
                message = firstError.first.toString();
              }
            }
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('ERROR LOGIN: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat terhubung ke server.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
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
      backgroundColor: const Color(0xffF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: SizedBox(
            height: MediaQuery.of(context).size.height - 40,

            child: Center(
              child: Form(
                key: _formKey,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const CircleAvatar(
                      radius: 45,

                      backgroundColor: Color(0xFF1565C0),

                      child: Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Selamat Datang',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Silakan login untuk melanjutkan',

                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _emailController,

                      keyboardType: TextInputType.emailAddress,

                      textInputAction: TextInputAction.next,

                      decoration: InputDecoration(
                        labelText: 'Email',

                        hintText: 'contoh@email.com',

                        prefixIcon: const Icon(Icons.email),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,

                      obscureText: obscurePassword,

                      textInputAction: TextInputAction.done,

                      decoration: InputDecoration(
                        labelText: 'Password',

                        hintText: 'Masukkan password',

                        prefixIcon: const Icon(Icons.lock),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),

                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      validator: _validatePassword,

                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          login();
                        }
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,

                      height: 50,

                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),

                          disabledBackgroundColor: Colors.grey,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,

                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Masuk',

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text('Belum punya akun?'),

                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.push('/register');
                                },

                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
