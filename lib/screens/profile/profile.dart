import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = 'https://sijala.biz.id/api/v1';

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = true;
  bool isLoggingOut = false;
  bool isLoadingPhoto = false;

  String name = '-';
  String username = '-';
  String email = '-';
  String phone = '-';
  String gender = '-';
  String photo = '';

  Uint8List? profileImage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  // ============================================================
  // AMBIL TOKEN
  // ============================================================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  Future<void> getProfile() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('======================================');
      debugPrint('GET PROFILE');
      debugPrint('STATUS   : ${response.statusCode}');
      debugPrint('RESPONSE : ${response.body}');
      debugPrint('======================================');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == true && result['data'] != null) {
          final user = result['data'];

          // ======================================================
          // GENDER
          // ======================================================

          final apiGender = user['gender']?.toString() ?? '';

          String genderText = '-';

          if (apiGender == 'L') {
            genderText = 'Laki-laki';
          } else if (apiGender == 'P') {
            genderText = 'Perempuan';
          } else if (apiGender == 'Laki-laki') {
            genderText = 'Laki-laki';
          } else if (apiGender == 'Perempuan') {
            genderText = 'Perempuan';
          }

          // ======================================================
          // DATA PROFILE
          // ======================================================

          final profilePhoto = user['photo']?.toString() ?? '';

          if (mounted) {
            setState(() {
              name = user['name']?.toString() ?? '-';
              username = user['username']?.toString() ?? '-';
              email = user['email']?.toString() ?? '-';
              phone = user['phone']?.toString() ?? '-';
              gender = genderText;
              photo = profilePhoto;
            });
          }

          // ======================================================
          // AMBIL FOTO DARI SERVER
          // ======================================================

          if (profilePhoto.isNotEmpty) {
            await loadProfileImage(profilePhoto);
          } else {
            if (mounted) {
              setState(() {
                profileImage = null;
              });
            }
          }
        }
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('token');

        if (mounted) {
          context.go('/login');
        }
      } else {
        showMessage(
          'Gagal mengambil data profile (${response.statusCode})',
          isError: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('GET PROFILE ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      showMessage(
        'Terjadi kesalahan saat mengambil data profile',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // LOAD FOTO PROFILE DARI SERVER
  // ============================================================

  Future<void> loadProfileImage(String fileName) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final encodedFileName = Uri.encodeComponent(fileName);

      final response = await http.get(
        Uri.parse('$baseUrl/image/$encodedFileName'),
        headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      debugPrint('IMAGE STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            profileImage = response.bodyBytes;
          });
        }
      } else {
        debugPrint('Gagal mengambil foto profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('LOAD IMAGE ERROR: $e');
    }
  }

  // ============================================================
  // PILIH FOTO DARI FILE PICKER
  // ============================================================

  Future<void> pickProfileImage() async {
    try {
      debugPrint('======================================');
      debugPrint('MEMBUKA PEMILIH FOTO');
      debugPrint('======================================');

      // File Picker versi terbaru
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      // ========================================================
      // USER MEMBATALKAN
      // ========================================================

      if (files.isEmpty) {
        debugPrint('User membatalkan pilih foto');
        return;
      }

      final PlatformFile file = files.first;

      debugPrint('Nama file: ${file.name}');

      // ========================================================
      // BACA FILE MENJADI BYTES
      // ========================================================

      final Uint8List bytes = await file.readAsBytes();

      debugPrint('Foto berhasil dibaca');
      debugPrint('Jumlah bytes: ${bytes.length}');

      if (bytes.isEmpty) {
        showMessage('Foto yang dipilih kosong', isError: true);
        return;
      }

      if (!mounted) return;

      // ========================================================
      // TAMPILKAN PREVIEW
      // ========================================================

      setState(() {
        profileImage = bytes;
        isLoadingPhoto = true;
      });

      // ========================================================
      // UPLOAD KE SERVER
      // ========================================================

      await uploadProfileImage(file.name, bytes);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('ERROR PILIH FOTO');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        isLoadingPhoto = false;
      });

      showMessage('Gagal memilih foto: $e', isError: true);
    }
  }

  // ============================================================
  // UPLOAD FOTO PROFILE
  // ============================================================

  Future<void> uploadProfileImage(String fileName, Uint8List bytes) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      // ========================================================
      // MULTIPART REQUEST
      // ========================================================

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/update'),
      );

      // ========================================================
      // HEADER
      // ========================================================

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // ========================================================
      // DATA PROFILE
      // ========================================================

      request.fields['name'] = name == '-' ? '' : name;
      request.fields['email'] = email == '-' ? '' : email;
      request.fields['phone'] = phone == '-' ? '' : phone;

      // ========================================================
      // GENDER
      // ========================================================

      String genderCode = '';

      if (gender == 'Laki-laki') {
        genderCode = 'L';
      } else if (gender == 'Perempuan') {
        genderCode = 'P';
      } else if (gender == 'L' || gender == 'P') {
        genderCode = gender;
      }

      request.fields['gender'] = genderCode;

      // ========================================================
      // CEK EXTENSION FILE
      // ========================================================

      String extension = 'jpg';

      if (fileName.contains('.')) {
        extension = fileName.split('.').last.toLowerCase();
      }

      if (extension != 'jpg' &&
          extension != 'jpeg' &&
          extension != 'png' &&
          extension != 'webp') {
        extension = 'jpg';
      }

      // ========================================================
      // NAMA FILE BARU
      // ========================================================

      final newFileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // ========================================================
      // TAMBAHKAN FOTO
      // ========================================================

      request.files.add(
        http.MultipartFile.fromBytes('photo', bytes, filename: newFileName),
      );

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint('======================================');
      debugPrint('UPLOAD FOTO');
      debugPrint('Nama       : $name');
      debugPrint('Email      : $email');
      debugPrint('Phone      : $phone');
      debugPrint('Gender     : $genderCode');
      debugPrint('File       : $newFileName');
      debugPrint('Bytes      : ${bytes.length}');
      debugPrint('URL        : $baseUrl/profile/update');
      debugPrint('======================================');

      // ========================================================
      // KIRIM REQUEST
      // ========================================================

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('======================================');
      debugPrint('UPLOAD RESULT');
      debugPrint('STATUS   : ${response.statusCode}');
      debugPrint('RESPONSE : ${response.body}');
      debugPrint('======================================');

      // ========================================================
      // BERHASIL
      // ========================================================

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final result = jsonDecode(response.body);

          if (result['status'] == true) {
            showMessage('Foto profile berhasil diperbarui');

            // Ambil data terbaru
            await getProfile();
          } else {
            showMessage(
              result['message']?.toString() ?? 'Gagal memperbarui foto profile',
              isError: true,
            );
          }
        } catch (e) {
          debugPrint('Response berhasil tetapi bukan JSON: $e');

          showMessage('Foto profile berhasil diperbarui');

          await getProfile();
        }
      }
      // ========================================================
      // TOKEN EXPIRED
      // ========================================================
      else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('token');

        if (mounted) {
          context.go('/login');
        }
      }
      // ========================================================
      // ERROR SERVER
      // ========================================================
      else {
        String message = 'Gagal mengupload foto (${response.statusCode})';

        try {
          final result = jsonDecode(response.body);

          if (result['message'] != null) {
            message = result['message'].toString();
          }

          if (result['errors'] != null) {
            debugPrint('VALIDATION ERRORS: ${result['errors']}');
          }
        } catch (e) {
          debugPrint('Response error bukan JSON: $e');
        }

        showMessage(message, isError: true);
      }
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('UPLOAD PHOTO ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      showMessage('Terjadi kesalahan saat mengupload foto', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingPhoto = false;
        });
      }
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        debugPrint('LOGOUT STATUS: ${response.statusCode}');

        debugPrint('LOGOUT RESPONSE: ${response.body}');
      }
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');

      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });

        context.go('/login');
      }
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // ============================================================
  // FOTO PROFILE
  // ============================================================

  Widget buildProfilePhoto() {
    return GestureDetector(
      onTap: isLoadingPhoto ? null : pickProfileImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // ======================================================
          // FOTO
          // ======================================================
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 3, color: Colors.white),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(0.15),
                ),
              ],
            ),
            child: ClipOval(
              child: profileImage != null
                  ? Image.memory(
                      profileImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade500,
                      ),
                    ),
            ),
          ),

          // ======================================================
          // LOADING
          // ======================================================
          if (isLoadingPhoto)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.35),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // ======================================================
          // ICON CAMERA
          // ======================================================
          if (!isLoadingPhoto)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE ITEM
  // ============================================================

  Widget buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // ======================================================
          // ICON
          // ======================================================
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 14),

          // ======================================================
          // TEXT
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await logout();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ==================================================
                    // FOTO PROFILE
                    // ==================================================
                    buildProfilePhoto(),

                    const SizedBox(height: 12),

                    const Text(
                      'Klik foto untuk mengganti',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // NAMA
                    // ==================================================
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // INFORMASI PROFILE
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // NAMA
                          buildProfileItem(
                            icon: Icons.person_outline,
                            title: 'Nama',
                            value: name,
                          ),

                          // EMAIL
                          buildProfileItem(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: email,
                          ),

                          // PHONE
                          buildProfileItem(
                            icon: Icons.phone_outlined,
                            title: 'Nomor Telepon',
                            value: phone,
                          ),

                          // GENDER
                          buildProfileItem(
                            icon: Icons.wc_outlined,
                            title: 'Jenis Kelamin',
                            value: gender,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // EDIT PROFILE
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context.push('/edit_profile');

                          await getProfile();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // LOGOUT
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isLoggingOut ? null : confirmLogout,

                        icon: isLoggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),

                        label: Text(
                          isLoggingOut ? 'Logout...' : 'Logout',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/dashboard');
          } else if (index == 1) {
            context.go('/surveyDaftar');
          } else if (index == 2) {
            context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Survey',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
