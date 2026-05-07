import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student_controller.dart';

class StudentClassDetails extends StatefulWidget {
  const StudentClassDetails({super.key});

  @override
  State<StudentClassDetails> createState() => _StudentClassDetailsState();
}

class _StudentClassDetailsState extends State<StudentClassDetails> {
  final StudentController controller = Get.put(StudentController());

  String classId = '';
  String subjectName = 'Class Details';

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    classId = args['classId'] ?? args['id'] ?? '';
    subjectName = args['subjectName'] ?? args['name'] ?? subjectName;

    if (classId.isNotEmpty) {
      controller.getClassAttendance(classId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isAttendanceLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
              ),
            );
          }

          final data = controller.classAttendance;

          final total = (data['totalLectures'] is int)
              ? data['totalLectures'] as int
              : (data['total'] is int)
                  ? data['total'] as int
                  : (data['history'] is List)
                      ? (data['history'] as List).length
                      : 0;

          final attended = (data['presentCount'] is int)
              ? data['presentCount'] as int
              : (data['attended'] is int)
                  ? data['attended'] as int
                  : (data['history'] is List)
                      ? (data['history'] as List).where((r) {
                          final s =
                              (r['status'] ?? '').toString().toLowerCase();
                          return s.contains('present') ||
                              s == '1' ||
                              s == 'true';
                        }).length
                      : 0;

          final missed = (data['absentCount'] is int)
              ? data['absentCount'] as int
              : (total - attended);

          final percent = (data['percentage'] != null)
              ? data['percentage'].toString()
              : (total > 0
                  ? ((attended * 100 / total).round()).toString()
                  : '--');

          final records =
              (data['history'] is List) ? data['history'] as List : [];

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF4F46E5),
                              width: 6,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$percent%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                'YOUR ATTENDANCE',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                               SizedBox(height: 6),
                               Text(
                                'Excellent standing',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Minimum required: 75%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statBox(
                      'Total',
                      total.toString(),
                      color: const Color(0xFF0F172A),
                    ),
                    _statBox(
                      'Attended',
                      attended.toString(),
                      color: const Color(0xFF059669),
                    ),
                    _statBox(
                      'Missed',
                      missed.toString(),
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ATTENDANCE HISTORY',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];

                    final status =
                        (r['status'] ?? '').toString().toLowerCase();

                    final isPresent = status.contains('present') ||
                        status == '1' ||
                        status == 'true';

                    final profileName =
                        controller.profile['name'] ??
                            controller.profile['studentName'] ??
                            'You';

                    final title = profileName;

                    final date =
                        r['date'] ?? r['createdAt'] ?? r['day'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isPresent
                                ? const Color(0xFFDDF7E8)
                                : const Color(0xFFFFE3E3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: isPresent
                                ? const Color(0xFF059669)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        title: Text(
                          title.isNotEmpty ? title : 'Attendance',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            date.toString(),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: Text(
                          isPresent ? 'PRESENT' : 'ABSENT',
                          style: TextStyle(
                            color: isPresent
                                ? const Color(0xFF059669)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _statBox(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}