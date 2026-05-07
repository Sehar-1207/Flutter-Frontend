import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/attendance_controller.dart';

class MarkAttendanceScreen extends StatelessWidget {
  MarkAttendanceScreen({super.key});

  final AttendanceController controller = Get.put(AttendanceController());
  static const _purple = Color(0xFF4A3AFF);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

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
          'Mark Attendance',
          style:
              TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            Container(
              color: Colors.white,
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard("Total",
                          controller.students.length.toString(), Colors.blue),
                      Obx(() => _buildStatCard("Present",
                          controller.totalPresent.toString(), Colors.green)),
                      Obx(() => _buildStatCard("Absent",
                          controller.totalAbsent.toString(), Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.submitMarkAll('Present'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Mark All Present",
                              style: TextStyle(color: Colors.green)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.submitMarkAll('Absent'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Mark All Absent",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "STUDENTS",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.2),
                  ),
                  Text("Status",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            
            Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.students.length,
                itemBuilder: (context, index) {
                  var st = controller.students[index];

                  String studentId =
                      st['studentId'] ?? st['id'] ?? index.toString();

                  return Obx(() {
                    String status =
                        controller.attendanceStatus[studentId] ?? 'Present';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: _purple.withValues(alpha:0.1),
                          child: Text(
                            (st['studentName']?.toString().isNotEmpty == true)
                                ? st['studentName']
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          st['studentName'] ?? 'No Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          "ID: ${st['rollNo']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),

                        
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            
                            GestureDetector(
                              onTap: () => controller.toggleStatus(
                                studentId,
                                'Present',
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'Present'
                                      ? Colors.green.withValues(alpha:0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: status == 'Present'
                                        ? Colors.green
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 14,
                                      color: status == 'Present'
                                          ? Colors.green
                                          : Colors.grey[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "P",
                                      style: TextStyle(
                                        color: status == 'Present'
                                            ? Colors.green
                                            : Colors.grey[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            
                            GestureDetector(
                              onTap: () => controller.toggleStatus(
                                studentId,
                                'Absent',
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'Absent'
                                      ? Colors.red.withValues(alpha:0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: status == 'Absent'
                                        ? Colors.red
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 14,
                                      color: status == 'Absent'
                                          ? Colors.red
                                          : Colors.grey[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "A",
                                      style: TextStyle(
                                        color: status == 'Absent'
                                            ? Colors.red
                                            : Colors.grey[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
            // Bottom floating Submit button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
              ]),
              child: ElevatedButton.icon(
                onPressed: () => controller.submitAttendance(),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Submit Attendance",
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
