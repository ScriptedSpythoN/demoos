// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../config/app_config.dart';
// import '../models/attendance_entry.dart';
// import '../models/medical_entry.dart';

// class ApiService {
//   static const _storage = FlutterSecureStorage();
//   static String? _token;
//   static String? userRole;
//   static String? currentUserName;
//   static String? currentUserId;

//   // ─────────────────────────────────────────────────────────────────
//   // AUTH METHODS
//   // ─────────────────────────────────────────────────────────────────

//   static Future<bool> login(String username, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {'username': username, 'password': password},
//       );

//       print('🔐 Login Response Status: ${response.statusCode}');
//       print('📦 Login Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _token = data['access_token'];
//         userRole = data['role'];
//         currentUserName = data['full_name'];
//         currentUserId = data['user_id'] ?? username;

//         await _storage.write(key: 'auth_token', value: _token);

//         print('✅ Login Success!');
//         print('👤 Role: $userRole');
//         print('📛 Name: $currentUserName');
//         print('🆔 ID: $currentUserId');

//         return true;
//       }

//       print('❌ Login Failed: ${response.body}');
//       return false;
//     } catch (e) {
//       print('🔥 Login Error: $e');
//       return false;
//     }
//   }

//   /// Registers a new Student account.
//   /// Returns a [RegistrationResult] with success flag and message.
//   static Future<RegistrationResult> registerStudent({
//     required String fullName,
//     required String regdNo,
//     required String rollNo,
//     required String semester,
//     required String contactNo,
//     required String email,
//     required String guardianName,
//     required String guardianContactNo,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/auth/register/student'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'full_name': fullName,
//           'regd_no': regdNo,
//           'roll_no': rollNo,
//           'semester': semester,
//           'contact_no': contactNo,
//           'email': email,
//           'guardian_name': guardianName,
//           'guardian_contact_no': guardianContactNo,
//           'password': password,
//           'role': 'STUDENT',
//         }),
//       );

//       print('📝 Student Register Status: ${response.statusCode}');
//       print('📦 Student Register Body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return RegistrationResult(success: true, message: 'Registration successful');
//       }

//       final body = jsonDecode(response.body);
//       return RegistrationResult(
//         success: false,
//         message: body['detail'] ?? 'Registration failed. Please try again.',
//       );
//     } catch (e) {
//       print('🔥 Student Register Error: $e');
//       return RegistrationResult(success: false, message: 'Network error: $e');
//     }
//   }

//   /// Registers a new Faculty or HOD account.
//   /// Returns a [RegistrationResult] with success flag and message.
//   static Future<RegistrationResult> registerFaculty({
//     required String fullName,
//     required String facultyId,
//     required String role,         // 'Prof.' | 'Asst. Prof.' | 'Guest Faculty'
//     required String contactNo,
//     required String email,
//     required String education,
//     required String fieldsOfExpertise,
//     required String password,
//     required String accountRole,  // 'TEACHER' | 'HOD'
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/auth/register/faculty'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'full_name': fullName,
//           'faculty_id': facultyId,
//           'designation': role,
//           'contact_no': contactNo,
//           'email': email,
//           'education': education,
//           'fields_of_expertise': fieldsOfExpertise,
//           'password': password,
//           'role': accountRole,    // sent as 'TEACHER' or 'HOD' to the backend
//         }),
//       );

//       print('📝 Faculty Register Status: ${response.statusCode}');
//       print('📦 Faculty Register Body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return RegistrationResult(success: true, message: 'Registration successful');
//       }

//       final body = jsonDecode(response.body);
//       return RegistrationResult(
//         success: false,
//         message: body['detail'] ?? 'Registration failed. Please try again.',
//       );
//     } catch (e) {
//       print('🔥 Faculty Register Error: $e');
//       return RegistrationResult(success: false, message: 'Network error: $e');
//     }
//   }

//   static Future<void> logout() async {
//     _token = null;
//     userRole = null;
//     currentUserName = null;
//     currentUserId = null;
//     await _storage.delete(key: 'auth_token');
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // ATTENDANCE & SCHEDULE METHODS
//   // ─────────────────────────────────────────────────────────────────

//   static Future<List<Map<String, dynamic>>> fetchTeacherSchedule() async {
//     final fid = currentUserId;
//     if (fid == null) return [];

//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/attendance/teacher/schedule/$fid'),
//         headers: _getHeaders(),
//       );

//       if (response.statusCode == 200) {
//         return List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       } else {
//         print('Schedule Fetch Failed: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Error fetching schedule: $e');
//       return [];
//     }
//   }

//   static Future<List<AttendanceEntry>> fetchRollList(
//       String classId, String subjectId) async {
//     final response = await http.post(
//       Uri.parse('${AppConfig.baseUrl}/api/attendance/roll-list'),
//       headers: _getHeaders(),
//       body: jsonEncode({'class_id': classId, 'subject_id': subjectId}),
//     );

//     if (response.statusCode == 200) {
//       final List rolls = jsonDecode(response.body)['roll_numbers'];
//       return rolls.map((r) => AttendanceEntry(rollNo: r.toString())).toList();
//     }
//     throw Exception('Failed to fetch rolls');
//   }

//   static Future<void> submitAttendance(
//       String subjectId, DateTime date, List<AttendanceEntry> entries) async {
//     final payload = {
//       'subject_id': subjectId,
//       'date': date.toIso8601String().split('T').first,
//       'records': entries.map((e) => e.toJson()).toList(),
//     };

//     final response = await http.post(
//       Uri.parse('${AppConfig.baseUrl}/api/attendance/submit'),
//       headers: _getHeaders(),
//       body: jsonEncode(payload),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Submit failed: ${response.body}');
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // STUDENT STATS
//   // ─────────────────────────────────────────────────────────────────

//   static Future<Map<String, dynamic>> fetchStudentStats(
//       String studentId) async {
//     final response = await http.get(
//       Uri.parse('${AppConfig.baseUrl}/api/attendance/student/stats/$studentId'),
//       headers: _getHeaders(),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     }
//     throw Exception('Failed to load stats');
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // MEDICAL METHODS
//   // ─────────────────────────────────────────────────────────────────

//   static Future<String> submitMedical({
//     required String studentRollNo,
//     required String departmentId,
//     required DateTime fromDate,
//     required DateTime toDate,
//     required String reason,
//     required File pdfFile,
//   }) async {
//     var request = http.MultipartRequest(
//         'POST', Uri.parse('${AppConfig.baseUrl}/api/medical/submit'));

//     if (_token != null) {
//       request.headers['Authorization'] = 'Bearer $_token';
//     }

//     request.fields.addAll({
//       'student_roll_no': studentRollNo,
//       'department_id': departmentId,
//       'from_date': fromDate.toIso8601String().split('T').first,
//       'to_date': toDate.toIso8601String().split('T').first,
//       'reason': reason,
//     });

//     request.files.add(await http.MultipartFile.fromPath(
//       'file',
//       pdfFile.path,
//       contentType: MediaType('application', 'pdf'),
//     ));

//     var response = await http.Response.fromStream(await request.send());
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['request_id'];
//     }
//     throw Exception('Medical submit failed: ${response.body}');
//   }

//   static Future<List<MedicalEntry>> fetchPendingMedical(
//       String departmentId) async {
//     final response = await http.get(
//       Uri.parse(
//           '${AppConfig.baseUrl}/api/medical/hod/pending?department_id=$departmentId'),
//       headers: _getHeaders(),
//     );

//     if (response.statusCode == 200) {
//       final List data = jsonDecode(response.body);
//       return data
//           .map((r) => MedicalEntry(
//                 requestId: r['request_id'],
//                 studentRollNo: r['student_roll_no'],
//                 fromDate: DateTime.parse(r['from_date']),
//                 toDate: DateTime.parse(r['to_date']),
//                 status: r['status'],
//                 hodRemark: r['hod_remark'],
//                 reason: r['reason'] ?? 'No reason provided',
//                 documentPath: r['document_path'] ?? '',
//                 ocrText: r['ocr_text'],
//                 ocrStatus: r['ocr_status'],
//               ))
//           .toList();
//     }
//     throw Exception('Fetch failed');
//   }

//   static Future<void> reviewMedical(
//       String requestId, String action, String? remark) async {
//     final response = await http.post(
//       Uri.parse('${AppConfig.baseUrl}/api/medical/hod/review'),
//       headers: _getHeaders(),
//       body: jsonEncode(
//           {'request_id': requestId, 'action': action, 'remark': remark ?? ''}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Review failed: ${response.body}');
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────────────────────────

//   static Map<String, String> _getHeaders() {
//     return {
//       'Content-Type': 'application/json',
//       if (_token != null) 'Authorization': 'Bearer $_token',
//     };
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// // REGISTRATION RESULT MODEL
// // ─────────────────────────────────────────────────────────────────

// /// Lightweight result wrapper returned by registration methods.
// /// Avoids throwing exceptions for expected failures (e.g. duplicate ID).
// class RegistrationResult {
//   final bool success;
//   final String message;

//   const RegistrationResult({required this.success, required this.message});
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/attendance_entry.dart';
import '../models/medical_entry.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static String? _token;
  static String? userRole;
  static String? currentUserName;
  static String? currentUserId;

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ─────────────────────────────────────────────────────────────────
  // AUTH METHODS
  // ─────────────────────────────────────────────────────────────────

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        userRole = data['role'];
        currentUserName = data['full_name'];
        currentUserId = data['user_id'];
        await _storage.write(key: 'auth_token', value: _token);
        return true;
      }
      return false;
    } catch (e) {
      print('🔥 Login Error: $e');
      return false;
    }
  }

  static Future<RegistrationResult> registerStudent({
    required String fullName,
    required String regdNo,
    required String rollNo,
    required String semester,
    required String contactNo,
    required String email,
    required String guardianName,
    required String guardianContactNo,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': regdNo, // Used as unique login ID
          'password': password,
          'full_name': fullName,
          'role': 'STUDENT',
          'regd_no': regdNo,
          'roll_no': rollNo,
          'semester': int.tryParse(semester) ?? 6,
          'contact_no': contactNo,
          'email': email,
          'guardian_name': guardianName,
          'guardian_contact_no': guardianContactNo,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const RegistrationResult(success: true, message: 'Registration successful');
      }
      final body = jsonDecode(response.body);
      return RegistrationResult(success: false, message: body['detail'] ?? 'Registration failed');
    } catch (e) {
      return RegistrationResult(success: false, message: 'Network error: $e');
    }
  }

  static Future<RegistrationResult> registerFaculty({
    required String fullName,
    required String facultyId,
    required String role,
    required String contactNo,
    required String email,
    required String education,
    required String fieldsOfExpertise,
    required String password,
    required String accountRole,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': facultyId,
          'password': password,
          'full_name': fullName,
          'role': accountRole,
          'contact_no': contactNo,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const RegistrationResult(success: true, message: 'Registration successful');
      }
      final body = jsonDecode(response.body);
      return RegistrationResult(success: false, message: body['detail'] ?? 'Registration failed');
    } catch (e) {
      return RegistrationResult(success: false, message: 'Network error: $e');
    }
  }

  static Future<void> logout() async {
    _token = null;
    userRole = null;
    currentUserName = null;
    currentUserId = null;
    await _storage.delete(key: 'auth_token');
  }

  // ─────────────────────────────────────────────────────────────────
  // OTHER METHODS (ATTENDANCE, MEDICAL, STATS)
  // ─────────────────────────────────────────────────────────────────
  
  static Future<Map<String, dynamic>> fetchStudentDashboard(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/attendance/student/stats/$studentId'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('🔥 Fetch Student Dashboard Error: $e');
      return {};
    }
  }
  static Future<List<Map<String, dynamic>>> fetchTeacherSchedule() async {
    if (currentUserId == null) return [];
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/attendance/teacher/schedule/$currentUserId'),
        headers: _getHeaders(),
      );
      return response.statusCode == 200 ? List<Map<String, dynamic>>.from(jsonDecode(response.body)) : [];
    } catch (e) { return []; }
  }

  static Future<List<AttendanceEntry>> fetchRollList(String classId, String subjectId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/roll-list'),
      headers: _getHeaders(),
      body: jsonEncode({'class_id': classId, 'subject_id': subjectId}),
    );
    if (response.statusCode == 200) {
      final List rolls = jsonDecode(response.body)['roll_numbers'];
      return rolls.map((r) => AttendanceEntry(rollNo: r.toString())).toList();
    }
    throw Exception('Failed to fetch rolls');
  }

  static Future<void> submitAttendance(String subjectId, DateTime date, List<AttendanceEntry> entries) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/submit'),
      headers: _getHeaders(),
      body: jsonEncode({
        'subject_id': subjectId,
        'date': date.toIso8601String().split('T').first,
        'records': entries.map((e) => e.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200) throw Exception('Submit failed');
  }

  static Future<Map<String, dynamic>> fetchStudentStats(String studentId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/student/stats/$studentId'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stats');
  }

  static Future<String> submitMedical({
    required String studentRollNo,
    required String departmentId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    required File pdfFile,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}/api/medical/submit'));
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    request.fields.addAll({
      'student_roll_no': studentRollNo,
      'department_id': departmentId,
      'from_date': fromDate.toIso8601String().split('T').first,
      'to_date': toDate.toIso8601String().split('T').first,
      'reason': reason,
    });
    request.files.add(await http.MultipartFile.fromPath('file', pdfFile.path, contentType: MediaType('application', 'pdf')));
    var response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) return jsonDecode(response.body)['request_id'];
    throw Exception('Medical submit failed');
  }

  static Future<List<MedicalEntry>> fetchPendingMedical(String departmentId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/medical/hod/pending?department_id=$departmentId'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((r) => MedicalEntry(
        requestId: r['request_id'],
        studentRollNo: r['student_roll_no'],
        fromDate: DateTime.parse(r['from_date']),
        toDate: DateTime.parse(r['to_date']),
        status: r['status'],
        hodRemark: r['hod_remark'],
        reason: r['reason'] ?? 'No reason provided',
        documentPath: r['document_path'] ?? '',
        ocrText: r['ocr_text'],
        ocrStatus: r['ocr_status'],
      )).toList();
    }
    throw Exception('Fetch failed');
  }

  static Future<List<MedicalEntry>> fetchReviewedMedical(String departmentId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/medical/hod/reviewed?department_id=$departmentId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((r) => MedicalEntry(
            requestId: r['request_id'],
            studentRollNo: r['student_roll_no'],
            fromDate: DateTime.parse(r['from_date']),
            toDate: DateTime.parse(r['to_date']),
            status: r['status'],
            hodRemark: r['hod_remark'],
            reason: r['reason'] ?? 'No reason provided',
            documentPath: r['document_path'] ?? '',
            // Assuming ocr fields aren't strictly needed for the reviewed list overview
          )).toList();
    }
    throw Exception('Failed to fetch reviewed medical requests');
  }
  // ─────────────────────────────────────────────────────────────────
  // DEPARTMENT STATS
  // ─────────────────────────────────────────────────────────────────
  static Future<Map<String, int>> fetchDepartmentStats() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/auth/stats'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'students': data['students'] ?? 0,
          'faculty': data['faculty'] ?? 0,
        };
      }
      return {'students': 0, 'faculty': 0};
    } catch (e) {
      print('🔥 Fetch Stats Error: $e');
      return {'students': 0, 'faculty': 0};
    }
  }

  // Add inside ApiService class
  static Future<List<dynamic>> fetchDepartmentAnalytics(String departmentId) async {
    try {
      final response = await http.get(
        // Note: adjust the prefix if your main.py maps it differently. 
        // Based on your code, students_router is mounted at /api/students.
        // But the router itself has prefix /api/admin/students.
        // Assuming the final path is: /api/students/department/...
        Uri.parse('${AppConfig.baseUrl}/api/students/department/$departmentId/analytics'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Analytics Fetch Failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching analytics: $e');
      return [];
    }
  }
  
  static Future<void> reviewMedical(String requestId, String action, String? remark) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/medical/hod/review'),
      headers: _getHeaders(),
      body: jsonEncode({'request_id': requestId, 'action': action, 'remark': remark ?? ''}),
    );
    if (response.statusCode != 200) throw Exception('Review failed');
  }
}

class RegistrationResult {
  final bool success;
  final String message;
  const RegistrationResult({required this.success, required this.message});
}