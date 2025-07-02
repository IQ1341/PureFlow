import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? selectedDate;
  int currentPage = 0;
  final int itemsPerPage = 14;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> historyData = [];

  @override
  void initState() {
    super.initState();
    fetchHistory(); // load data pertama kali
  }

  Future<void> fetchHistory() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      historyData = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter tanggal
    final filteredData = selectedDate == null
        ? historyData
        : historyData.where((doc) {
            final timestamp = doc.data()['timestamp'];
            if (timestamp == null || timestamp is! Timestamp) return false;
            final date = timestamp.toDate();
            return date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;
          }).toList();

    final totalPages =
        (filteredData.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();

    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredData.length);

    final pagedData = filteredData.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Data",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2F4A7D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                  currentPage = 0; // reset ke halaman pertama saat ganti tanggal
                });
              }
            },
          ),
        ],
      ),
      body: historyData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(const Color(0xFF2F4A7D)),
                      headingTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: SizedBox(width: 20, child: Text('No'))),
                        DataColumn(label: SizedBox(width: 140, child: Text('Tanggal'))),
                        DataColumn(label: SizedBox(width: 60, child: Text('Suhu'))),
                        DataColumn(label: SizedBox(width: 60, child: Text('Keruh'))),
                      ],
                      rows: pagedData.isEmpty
                          ? []
                          : List.generate(pagedData.length, (index) {
                              final doc = pagedData[index];
                              final data = doc.data();

                              final timestamp = data['timestamp'];
                              final temperature = data['temperature'];
                              final turbidity = data['turbidity'];

                              final date = (timestamp is Timestamp)
                                  ? timestamp.toDate()
                                  : null;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 20,
                                      child: Text(
                                        (startIndex + index + 1).toString(),
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 140,
                                      child: Text(
                                        date != null
                                            ? "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
                                            : "-",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        temperature != null
                                            ? temperature.toString()
                                            : "-",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        turbidity != null
                                            ? turbidity.toString()
                                            : "-",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 0
                          ? () {
                              setState(() {
                                currentPage--;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4A7D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Page ${currentPage + 1} of $totalPages',
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                currentPage++;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4A7D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
      backgroundColor: const Color(0xFFE4EFFC),
    );
  }
}
