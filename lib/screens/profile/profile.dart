import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color primaryColor = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xffF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // FOTO PROFILE
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 65, color: primaryColor),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // NAMA
                  const Text(
                    "Siti Sopiah",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // USERNAME
                  const Text(
                    "@sitisopiah16",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // NAMA
                  _buildProfileItem(
                    icon: Icons.person_outline,
                    title: "Nama",
                    value: "Siti Sopiah",
                  ),

                  _buildDivider(),

                  // USERNAME
                  _buildProfileItem(
                    icon: Icons.account_circle_outlined,
                    title: "Username",
                    value: "sitisopiah16",
                  ),

                  _buildDivider(),

                  // EMAIL
                  _buildProfileItem(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: "sitisopiyah160609@gmail.com",
                  ),

                  _buildDivider(),

                  // PHONE
                  _buildProfileItem(
                    icon: Icons.phone_outlined,
                    title: "Phone",
                    value: "081234567890",
                  ),

                  _buildDivider(),

                  // GENDER
                  _buildProfileItem(
                    icon: Icons.wc_outlined,
                    title: "Gender",
                    value: "Perempuan",
                  ),

                  _buildDivider(),

                  // TEMPAT LAHIR
                  _buildProfileItem(
                    icon: Icons.location_city_outlined,
                    title: "Tempat Lahir",
                    value: "Tasikmalaya",
                  ),

                  _buildDivider(),

                  // TANGGAL LAHIR
                  _buildProfileItem(
                    icon: Icons.calendar_month_outlined,
                    title: "Tanggal Lahir",
                    value: "16 Juni 2009",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Halaman edit profile
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          switch (index) {
            // HOME
            case 0:
              context.go('/dashboard');
              break;

            // SURVEY
            case 1:
              context.go('/survey');
              break;

            // PROFILE
            case 2:
              context.go('/profile');
              break;
          }
        },

        items: const [
          // HOME
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          // SURVEY
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: "Survey",
          ),

          // PROFILE
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ICON
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 23),
        ),

        const SizedBox(width: 15),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Divider(height: 1),
    );
  }
}
