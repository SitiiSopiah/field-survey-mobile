import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // =========================================================
  // COLOR
  // =========================================================

  static const Color primaryColor = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xffF5F7FA);

  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =========================================================
  // CONTROLLER
  // =========================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // =========================================================
  // VARIABLE
  // =========================================================

  // Nilai internal aplikasi:
  //
  // L = Laki-laki
  // P = Perempuan
  //
  // API GET bisa mengembalikan:
  // "Laki-laki"
  // "Perempuan"
  //
  // API UPDATE harus menerima:
  // "L"
  // "P"

  String? gender;

  bool isLoading = true;
  bool isSaving = false;

  // =========================================================
  // INIT STATE
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      print('======================================');
      print('LOAD PROFILE');
      print('TOKEN ADA: ${token != null && token.isNotEmpty}');
      print('======================================');

      // =====================================================
      // CEK TOKEN
      // =====================================================

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        showMessage(
          'Token tidak ditemukan. Silakan login kembali.',
          Colors.red,
        );

        return;
      }

      // =====================================================
      // REQUEST PROFILE
      // =====================================================

      final response = await http.get(
        Uri.parse('https://sijala.biz.id/api/v1/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('======================================');
      print('PROFILE RESPONSE');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('======================================');

      if (!mounted) return;

      // =====================================================
      // BERHASIL
      // =====================================================

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // Response:
        //
        // {
        //   "status": true,
        //   "data": {
        //      "user_id": 95,
        //      "name": "ss",
        //      "username": "ss",
        //      "email": "ss@gmail.com",
        //      "phone": "082231245244",
        //      "gender": "Perempuan"
        //   }
        // }

        final dynamic data = responseData['data'];

        if (data is! Map) {
          setState(() {
            isLoading = false;
          });

          showMessage('Data profile tidak sesuai.', Colors.red);

          return;
        }

        // ===================================================
        // AMBIL DATA
        // ===================================================

        final String name = data['name']?.toString() ?? '';

        final String email = data['email']?.toString() ?? '';

        final String phone = data['phone']?.toString() ?? '';

        final String apiGender =
            data['gender']?.toString().trim().toLowerCase() ?? '';

        // ===================================================
        // KONVERSI GENDER
        // ===================================================
        //
        // API:
        // "Laki-laki" -> "L"
        // "Perempuan" -> "P"
        //
        // Kalau API ternyata mengirim:
        // "L" -> "L"
        // "P" -> "P"
        //
        // ===================================================

        String? selectedGender;

        if (apiGender == 'laki-laki' ||
            apiGender == 'laki laki' ||
            apiGender == 'l' ||
            apiGender == 'male') {
          selectedGender = 'L';
        } else if (apiGender == 'perempuan' ||
            apiGender == 'p' ||
            apiGender == 'female') {
          selectedGender = 'P';
        } else {
          selectedGender = null;
        }

        print('======================================');
        print('DATA PROFILE');
        print('NAME       : $name');
        print('EMAIL      : $email');
        print('PHONE      : $phone');
        print('GENDER API : ${data['gender']}');
        print('GENDER APP : $selectedGender');
        print('======================================');

        // ===================================================
        // MASUKKAN KE FORM
        // ===================================================

        setState(() {
          nameController.text = name;
          emailController.text = email;
          phoneController.text = phone;

          // PENTING:
          // Kalau API mengirim "Perempuan",
          // gender akan menjadi "P".
          //
          // Dropdown akan otomatis memilih
          // item value="P".
          gender = selectedGender;

          isLoading = false;
        });
      }
      // =====================================================
      // TOKEN EXPIRED
      // =====================================================
      else if (response.statusCode == 401) {
        await prefs.remove('token');

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        showMessage(
          'Session telah berakhir. Silakan login kembali.',
          Colors.red,
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        context.go('/login');
      }
      // =====================================================
      // ERROR
      // =====================================================
      else {
        setState(() {
          isLoading = false;
        });

        String message =
            'Gagal mengambil profile '
            '(${response.statusCode})';

        try {
          final dynamic errorData = jsonDecode(response.body);

          if (errorData is Map) {
            if (errorData['message'] != null) {
              message = errorData['message'].toString();
            }
          }
        } catch (_) {}

        showMessage(message, Colors.red);
      }
    } catch (e) {
      print('======================================');
      print('ERROR LOAD PROFILE');
      print(e);
      print('======================================');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // =========================================================
  // UPDATE PROFILE
  // =========================================================

  Future<void> updateProfile() async {
    // =======================================================
    // VALIDASI FORM
    // =======================================================

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // =======================================================
    // VALIDASI GENDER
    // =======================================================

    if (gender == null || (gender != 'L' && gender != 'P')) {
      showMessage('Gender belum dipilih.', Colors.orange);

      return;
    }

    // =======================================================
    // LOADING
    // =======================================================

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      // =====================================================
      // CEK TOKEN
      // =====================================================

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        showMessage(
          'Token tidak ditemukan. Silakan login kembali.',
          Colors.red,
        );

        return;
      }

      // =====================================================
      // REQUEST BODY
      // =====================================================
      //
      // PENTING:
      //
      // JANGAN:
      //
      // genderForApi = "Perempuan"
      //
      // Karena API meminta:
      //
      // L atau P
      //
      // =====================================================

      final Map<String, dynamic> requestBody = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'gender': gender,
        'phone': phoneController.text.trim(),
      };

      print('======================================');
      print('UPDATE PROFILE');
      print('REQUEST BODY');
      print(jsonEncode(requestBody));
      print('======================================');

      // =====================================================
      // REQUEST API
      // =====================================================

      final response = await http.post(
        Uri.parse('https://sijala.biz.id/api/v1/profile/update'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('======================================');
      print('UPDATE RESPONSE');
      print('STATUS : ${response.statusCode}');
      print('BODY   : ${response.body}');
      print('======================================');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      // =====================================================
      // BERHASIL
      // =====================================================

      if (response.statusCode == 200 || response.statusCode == 201) {
        showMessage('Profile berhasil diperbarui.', Colors.green);

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        // Kembali ke halaman profile
        // membawa hasil true
        context.pop(true);

        return;
      }

      // =====================================================
      // UNAUTHORIZED
      // =====================================================

      if (response.statusCode == 401) {
        await prefs.remove('token');

        if (!mounted) return;

        showMessage(
          'Session telah berakhir. Silakan login kembali.',
          Colors.red,
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        context.go('/login');

        return;
      }

      // =====================================================
      // ERROR API
      // =====================================================

      String message =
          'Gagal memperbarui profile '
          '(${response.statusCode})';

      try {
        final dynamic errorData = jsonDecode(response.body);

        if (errorData is Map) {
          // Contoh:
          //
          // {
          //   "gender": [
          //      "Jenis kelamin harus L atau P."
          //   ]
          // }

          if (errorData['message'] != null) {
            message = errorData['message'].toString();
          }

          // Cek errors
          if (errorData['errors'] != null) {
            final errors = errorData['errors'];

            if (errors is Map) {
              final List<String> messages = [];

              errors.forEach((key, value) {
                if (value is List) {
                  messages.addAll(value.map((item) => item.toString()));
                } else {
                  messages.add(value.toString());
                }
              });

              if (messages.isNotEmpty) {
                message = messages.join('\n');
              }
            } else {
              message = errors.toString();
            }
          }

          // Kalau API langsung mengirim:
          //
          // {
          //   "gender": [...]
          // }
          //
          if (errorData['gender'] != null) {
            final genderError = errorData['gender'];

            if (genderError is List && genderError.isNotEmpty) {
              message = genderError.first.toString();
            } else {
              message = genderError.toString();
            }
          }
        }
      } catch (_) {
        // Response bukan JSON
      }

      showMessage(message, Colors.red);
    } catch (e) {
      print('======================================');
      print('ERROR UPDATE PROFILE');
      print(e);
      print('======================================');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage('Terjadi kesalahan: $e', Colors.red);
    }
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon, color: primaryColor),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }

        return null;
      },
    );
  }

  // =========================================================
  // GENDER DROPDOWN
  // =========================================================

  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: gender,

      decoration: InputDecoration(
        labelText: 'Gender',

        prefixIcon: const Icon(Icons.wc_outlined, color: primaryColor),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),

      // =====================================================
      // ITEM
      // =====================================================
      items: const [
        DropdownMenuItem<String>(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem<String>(value: 'P', child: Text('Perempuan')),
      ],

      // =====================================================
      // ON CHANGED
      // =====================================================
      onChanged: isSaving
          ? null
          : (value) {
              setState(() {
                gender = value;
              });

              print('GENDER DIPILIH: $gender');
            },

      // =====================================================
      // VALIDATOR
      // =====================================================
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Gender wajib dipilih';
        }

        return null;
      },
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isSaving
              ? null
              : () {
                  context.pop();
                },
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =======================================
                    // FOTO PROFILE
                    // =======================================
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,

                              border: Border.all(color: primaryColor, width: 4),
                            ),

                            child: const CircleAvatar(
                              backgroundColor: Colors.white,

                              child: Icon(
                                Icons.person,
                                size: 65,
                                color: primaryColor,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 0,
                            bottom: 0,

                            child: Container(
                              width: 35,
                              height: 35,

                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),

                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =======================================
                    // JUDUL
                    // =======================================
                    const Text(
                      'Informasi Profile',

                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =======================================
                    // NAMA
                    // =======================================
                    buildTextField(
                      controller: nameController,

                      label: 'Nama',

                      hint: 'Masukkan nama',

                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 16),

                    // =======================================
                    // EMAIL
                    // =======================================
                    buildTextField(
                      controller: emailController,

                      label: 'Email',

                      hint: 'Masukkan email',

                      icon: Icons.email_outlined,

                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // =======================================
                    // PHONE
                    // =======================================
                    buildTextField(
                      controller: phoneController,

                      label: 'Phone',

                      hint: 'Masukkan nomor phone',

                      icon: Icons.phone_outlined,

                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // =======================================
                    // GENDER
                    // =======================================
                    buildGenderDropdown(),

                    const SizedBox(height: 30),

                    // =======================================
                    // BUTTON SIMPAN
                    // =======================================
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : updateProfile,

                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),

                        label: Text(
                          isSaving ? 'Menyimpan...' : 'Simpan Perubahan',

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,

                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: OutlinedButton(
                        onPressed: isSaving
                            ? null
                            : () {
                                context.pop();
                              },

                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,

                          side: const BorderSide(color: primaryColor),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text(
                          'Batal',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
