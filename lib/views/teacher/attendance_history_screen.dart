import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/attendance_history_controller.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  AttendanceHistoryScreen({super.key});

  final AttendanceHistoryController controller =
      Get.put(AttendanceHistoryController());
  static const _purple = Color(0xFF4A3AFF);
  static const _bg = Color(0xFFF5F6FA);

  void _presentDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _purple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.onDatePicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'History & Summary',
          style:
              TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: _purple),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportCSV(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFigmaSummaryCard(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Daily Attendance",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey[800])),
                    InkWell(
                      onTap: () => _presentDatePicker(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Obx(() => Text(
                                  DateFormat('MM/dd/yyyy')
                                      .format(controller.selectedDate.value),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today,
                                size: 16, color: _purple),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoadingDaily.value) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()));
                }

                if (controller.dailyRecords.isEmpty) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      controller.dailyMessage.value.isNotEmpty
                          ? controller.dailyMessage.value
                          : "No records found.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.dailyRecords.length,
                  itemBuilder: (context, index) {
                    var r = controller.dailyRecords[index];
                    bool isPresent =
                        r['status'].toString().toLowerCase() == 'present';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.black12))),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: _purple.withValues(alpha: 0.1),
                          child: Text(
                            r['studentName']
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: _purple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(r['studentName'] ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: isPresent ? Colors.green : Colors.red),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPresent ? "Present" : "Absent",
                            style: TextStyle(
                                color: isPresent ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("STUDENTS SUMMARY",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoadingSummary.value) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()));
                }

                var summary = controller.summaryData;
                if (summary['students'] == null ||
                    summary['students'].isEmpty) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No summary data available.")));
                }

                List students = summary['students'];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var st = students[index];
                    int pct = st['percentage'] ?? 0;

                    Color progressColor;
                    if (pct >= 85) {
                      progressColor = Colors.green;
                    } else if (pct >= 75) {
                      progressColor = Colors.orange;
                    } else {
                      progressColor = _purple;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(st['studentName'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Row(
                                children: [
                                  Text("${st['present']}/${st['total']}",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Text("$pct%",
                                      style: TextStyle(
                                          color: progressColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: st['total'] > 0
                                  ? (st['present'] / st['total'])
                                  : 0,
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFigmaSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: _purple,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _purple.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Obx(() {
        if (controller.isLoadingSummary.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        var summary = controller.summaryData;
        int totalLectures = summary['totalLectures'] ?? 0;

        List students = summary['students'] ?? [];
        int totalStudents = students.length;

        int sumPercentages = 0;
        int studentsAbove75 = 0;
        for (var st in students) {
          sumPercentages += (st['percentage'] as int? ?? 0);
          if ((st['percentage'] ?? 0) >= 75) studentsAbove75++;
        }

        int classAverage =
            totalStudents > 0 ? (sumPercentages / totalStudents).round() : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CLASS AVERAGE",
                style: TextStyle(
                    color: Colors.white70, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text("$classAverage%",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(totalLectures.toString(), "Lectures"),
                _buildSummaryItem(totalStudents.toString(), "Students"),
                _buildSummaryItem(studentsAbove75.toString(), "Above 75%"),
              ],
            )
          ],
        );
      }),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
