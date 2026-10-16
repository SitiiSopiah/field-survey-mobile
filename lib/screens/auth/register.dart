import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? selectedGender;

  bool isLoading = false;

  // URL REGISTER API
  static const String registerUrl = 'https://sijala.biz.id/api/v1/register';

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone wajib diisi';
    }

    if (value.trim().length < 10) {
      return 'Nomor phone tidak valid';
    }

    return null;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'gender': selectedGender,
          'phone': _phoneController.text.trim(),
        }),
      );

      print('==============================');
      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER RESPONSE: ${response.body}');
      print('==============================');

      dynamic responseData;

      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        responseData = null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String message = 'Registrasi berhasil';

        if (responseData is Map && responseData['message'] != null) {
          message = responseData['message'].toString();
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        context.go('/login');

        return;
      }

      String message = 'Registrasi gagal';

      if (responseData is Map) {
        if (responseData['message'] != null) {
          message = responseData['message'].toString();
        }

        // Jika API menggunakan validation errors
        if (responseData['errors'] is Map) {
          final errors = Map<String, dynamic>.from(responseData['errors']);

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
    } catch (e) {
      print('REGISTER ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat terhubung ke server'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF1565C0),
                  child: Icon(
                    Icons.person_add_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Lengkapi data berikut untuk mendaftar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Masukkan nama lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: validateName,
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'contoh@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: validateEmail,
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: selectedGender,

                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: const Icon(Icons.wc_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gender wajib dipilih';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,

                  decoration: InputDecoration(
                    labelText: 'Phone',
                    hintText: '081234567890',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: validatePhone,

                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      register();
                    }
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,

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
                            'Daftar',
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
                    const Text('Sudah punya akun?'),

                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.go('/login');
                            },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
