import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

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
          "Survey",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data Survey",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 7),

                  Text(
                    "Kelola dan pantau data survey kamu",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Ringkasan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.assignment,
                    title: "Total",
                    value: "25",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.check_circle,
                    title: "Selesai",
                    value: "18",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.pending,
                    title: "Proses",
                    value: "7",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Survey",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    // Tambahkan aksi filter
                  },
                  icon: const Icon(
                    Icons.filter_list,
                    size: 20,
                  ),
                  label: const Text("Filter"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _buildSurveyCard(
              context: context,
              title: "Survey Rumah A",
              location: "Kampung Panyalahan",
              date: "11 Agustus 2026",
              status: "Selesai",
              statusColor: Colors.green,
            ),

            const SizedBox(height: 15),

            _buildSurveyCard(
              context: context,
              title: "Survey Wilayah RT 02",
              location: "RT 02 / RW 05",
              date: "10 Agustus 2026",
              status: "Proses",
              statusColor: Colors.orange,
            ),

            const SizedBox(height: 15),

            _buildSurveyCard(
              context: context,
              title: "Survey Fasilitas Umum",
              location: "Desa Sukamaju",
              date: "08 Agustus 2026",
              status: "Selesai",
              statusColor: Colors.green,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Arahkan ke halaman buat survey
                },
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "Buat Survey Baru",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;

            case 1:
              context.go('/survey');
              break;

            case 2:
              context.go('/profile');
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: "Survey",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 30,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyCard({
    required BuildContext context,
    required String title,
    required String location,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // JUDUL + STATUS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Divider(),

          const SizedBox(height: 10),

          // TANGGAL
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),

              const SizedBox(width: 8),

              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  // Detail survey
                },
                child: const Text(
                  "Detail",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}