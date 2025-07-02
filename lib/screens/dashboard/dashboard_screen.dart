import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/history/history_screen.dart'; // Import halaman history sesuai struktur project-mu

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showSuhu = true;

  final _database = FirebaseDatabase.instance.ref();
  double suhu = 0.0;
  double kekeruhan = 0.0;
  double currentPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToSensorData();
  }

  void _listenToSensorData() {
    _database.child("sensor/suhu").onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        final newVal = double.tryParse(value.toString()) ?? 0.0;
        setState(() {
          suhu = newVal;
          if (showSuhu) currentPercent = (newVal.clamp(0.0, 100.0)) / 100.0;
        });
      }
    });

    _database.child("sensor/kekeruhan").onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        final newVal = double.tryParse(value.toString()) ?? 0.0;
        setState(() {
          kekeruhan = newVal;
          if (!showSuhu) currentPercent = (newVal.clamp(0.0, 100.0)) / 100.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final value = showSuhu ? suhu : kekeruhan;
    final satuan = showSuhu ? "°C" : " NTU";

    return Scaffold(
      body: Column(
        children: [
          // Header with Settings and History Icon
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4878B0), Color(0xFFA4C5E5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      toggleButton("Suhu", showSuhu, () {
                        setState(() {
                          showSuhu = true;
                          currentPercent = (suhu.clamp(0.0, 100.0)) / 100.0;
                        });
                      }),
                      const SizedBox(width: 16),
                      toggleButton("Kekeruhan", !showSuhu, () {
                        setState(() {
                          showSuhu = false;
                          currentPercent = (kekeruhan.clamp(0.0, 100.0)) / 100.0;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              // History Icon di kiri atas
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.history, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                ),
              ),
              // Settings Icon di kanan atas
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Konten Utama
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFE4EFFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showSuhu ? "Suhu Air" : "Tingkat Kekeruhan",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F4A7D),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Circular Percent Indicator
                  CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 16.0,
                    percent: currentPercent,
                    animation: true,
                    animateFromLastPercent: true,
                    animationDuration: 800,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.white,
                    progressColor: const Color(0xFF2F4A7D),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${value.toStringAsFixed(1)}$satuan",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2F4A7D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          showSuhu ? "Suhu saat ini" : "Kekeruhan air",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Status Info
                  statusInfo(value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusInfo(double value) {
    String status;
    Color color;
    IconData icon;

    if (showSuhu) {
      if (value < 25) {
        status = "Dingin";
        color = Colors.blue;
        icon = Icons.ac_unit;
      } else if (value <= 34) {
        status = "Normal";
        color = Colors.green;
        icon = Icons.thermostat;
      } else {
        status = "Panas";
        color = Colors.red;
        icon = Icons.local_fire_department;
      }
    } else {
      if (value < 25) {
        status = "Jernih";
        color = Colors.green;
        icon = Icons.water_drop;
      } else if (value < 30) {
        status = "Agak Keruh";
        color = Colors.orange;
        icon = Icons.waves;
      } else {
        status = "Keruh";
        color = Colors.red;
        icon = Icons.dangerous;
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.6), width: 1.2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget toggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2F4A7D) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(isActive ? 1.0 : 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
