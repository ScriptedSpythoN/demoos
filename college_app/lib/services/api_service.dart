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

  // --- AUTH METHODS ---

 static Future<bool> login(String username, String password) async {
  try {
    // OAuth2 expects form-urlencoded
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    print('🔐 Login Response Status: ${response.statusCode}');
    print('📦 Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      userRole = data['role'];
      currentUserName = data['full_name'];
      currentUserId = data['user_id'] ?? username;

      await _storage.write(key: 'auth_token', value: _token);
      
      print('✅ Login Success!');
      print('👤 Role: $userRole');
      print('📛 Name: $currentUserName');
      print('🆔 ID: $currentUserId');
      
      return true;
    }
    
    print('❌ Login Failed: ${response.body}');
    return false;
  } catch (e) {
    print('🔥 Login Error: $e');
    return false;
  }
}
  static Future<void> logout() async {
    _token = null;
    userRole = null;
    currentUserName = null;
    currentUserId = null;
    await _storage.delete(key: 'auth_token');
  }

  // --- ATTENDANCE & SCHEDULE METHODS ---

  /// Fetches the weekly schedule for the logged-in teacher
  /// (Merged from File 2)
  static Future<List<Map<String, dynamic>>> fetchTeacherSchedule() async {
    final fid = currentUserId; 
    if (fid == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/attendance/teacher/schedule/$fid'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print('Schedule Fetch Failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      return [];
    }
  }

  static Future<List<AttendanceEntry>> fetchRollList(
      String classId, String subjectId) async {
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

  static Future<void> submitAttendance(
      String subjectId, DateTime date, List<AttendanceEntry> entries) async {
    final payload = {
      'subject_id': subjectId,
      'date': date.toIso8601String().split('T').first,
      'records': entries.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/submit'),
      headers: _getHeaders(),
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Submit failed: ${response.body}');
    }
  }

  // --- STUDENT STATS ---

  static Future<Map<String, dynamic>> fetchStudentStats(
      String studentId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/student/stats/$studentId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load stats');
  }

  // --- MEDICAL METHODS ---

  static Future<String> submitMedical({
    required String studentRollNo,
    required String departmentId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    required File pdfFile,
  }) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${AppConfig.baseUrl}/api/medical/submit'));
    
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.fields.addAll({
      'student_roll_no': studentRollNo,
      'department_id': departmentId,
      'from_date': fromDate.toIso8601String().split('T').first,
      'to_date': toDate.toIso8601String().split('T').first,
      'reason': reason,
    });

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      pdfFile.path,
      contentType: MediaType('application', 'pdf'),
    ));

    var response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['request_id'];
    }
    throw Exception('Medical submit failed: ${response.body}');
  }

  /// Fetches pending medical requests for HOD
  /// (Kept from File 1: Includes new OCR and Reason fields)
  static Future<List<MedicalEntry>> fetchPendingMedical(
      String departmentId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/medical/hod/pending?department_id=$departmentId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // UPDATED: Now maps the new fields required for Verification
      return data
          .map((r) => MedicalEntry(
                requestId: r['request_id'],
                studentRollNo: r['student_roll_no'],
                fromDate: DateTime.parse(r['from_date']),
                toDate: DateTime.parse(r['to_date']),
                status: r['status'],
                hodRemark: r['hod_remark'],

                // --- NEW FIELDS (From File 1) ---
                reason: r['reason'] ?? 'No reason provided',
                documentPath: r['document_path'] ?? '',
                ocrText: r['ocr_text'],
                ocrStatus: r['ocr_status'],
              ))
          .toList();
    }
    throw Exception('Fetch failed');
  }

  static Future<void> reviewMedical(
      String requestId, String action, String? remark) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/medical/hod/review'),
      headers: _getHeaders(),
      body: jsonEncode(
          {'request_id': requestId, 'action': action, 'remark': remark ?? ''}),
    );
    if (response.statusCode != 200) {
      throw Exception('Review failed: ${response.body}');
    }
  }

  // --- HELPERS ---

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}