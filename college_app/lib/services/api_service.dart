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

  // ─────────────────────────────────────────────────────────────────
  // TOKEN & HEADER HELPERS
  // ─────────────────────────────────────────────────────────────────

  /// Retrieve token from in-memory cache or secure storage.
  /// ALWAYS call this before any authenticated request.
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await _storage.read(key: 'auth_token');
    return _token;
  }

  /// Async-safe authenticated headers. Use for all requests.
  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    // Always ensure token is loaded from storage if not in memory
    final token = await getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Synchronous headers — only safe after login (token guaranteed in memory).
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
        currentUserId = data['user_id'] ?? username;
        await _storage.write(key: 'auth_token', value: _token!);
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
          'username': regdNo,
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
      return RegistrationResult(
        success: false,
        message: body['detail'] ?? 'Registration failed.',
      );
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
          'education': education,
          'fields_of_expertise': fieldsOfExpertise,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const RegistrationResult(success: true, message: 'Registration successful');
      }
      final body = jsonDecode(response.body);
      return RegistrationResult(
        success: false,
        message: body['detail'] ?? 'Registration failed.',
      );
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
  // PASSWORD RESET METHODS
  // ─────────────────────────────────────────────────────────────────

  static Future<bool> requestPasswordReset(String username) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('🔥 Request Reset Error: $e');
      return false;
    }
  }

  static Future<bool> verifyOtp(String username, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'otp': otp}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('🔥 Verify OTP Error: $e');
      return false;
    }
  }

  static Future<bool> resetPassword(
      String username, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('🔥 Reset Password Error: $e');
      return false;
    }
  }
  // ─────────────────────────────────────────────────────────────────
  // SECURE CHANGE PASSWORD (Logged-In User)
  // ─────────────────────────────────────────────────────────────────
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/change-password'),
        headers: await _authHeaders(json: true), // Securely attaches the JWT
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('🔥 Change Password Error: $e');
      return false;
    }
  }
  // ─────────────────────────────────────────────────────────────────
  // ATTENDANCE & SCHEDULE METHODS
  // ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchTeacherSchedule() async {
    if (currentUserId == null) return [];
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/attendance/teacher/schedule/$currentUserId'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<AttendanceEntry>> fetchRollList(
      String classId, String subjectId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/roll-list'),
      headers: await _authHeaders(json: true),
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
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/attendance/submit'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'subject_id': subjectId,
        'date': date.toIso8601String().split('T').first,
        'records': entries.map((e) => e.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200) throw Exception('Submit failed');
  }

  // ─────────────────────────────────────────────────────────────────
  // STUDENT STATS & DASHBOARD
  // ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> fetchStudentStats(
      String studentId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/attendance/student/stats/$studentId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stats');
  }

  static Future<Map<String, dynamic>> fetchStudentDashboard(
      String studentId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/attendance/student/stats/$studentId'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      print('🔥 Fetch Student Dashboard Error: $e');
      return {};
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // DEPARTMENT STATS & ANALYTICS
  // ─────────────────────────────────────────────────────────────────

  static Future<Map<String, int>> fetchDepartmentStats() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/auth/stats'),
        headers: await _authHeaders(),
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

  static Future<List<dynamic>> fetchDepartmentAnalytics(
      String departmentId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/students/department/$departmentId/analytics'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      print('Analytics Fetch Failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching analytics: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // MEDICAL METHODS
  // ─────────────────────────────────────────────────────────────────

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
    final token = await getToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

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
    throw Exception('Medical submit failed');
  }

  static Future<List<MedicalEntry>> fetchPendingMedical(
      String departmentId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/medical/hod/pending?department_id=$departmentId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((r) => MedicalEntry(
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
              ))
          .toList();
    }
    throw Exception('Fetch failed');
  }

  static Future<List<MedicalEntry>> fetchReviewedMedical(
      String departmentId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/medical/hod/reviewed?department_id=$departmentId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((r) => MedicalEntry(
                requestId: r['request_id'],
                studentRollNo: r['student_roll_no'],
                fromDate: DateTime.parse(r['from_date']),
                toDate: DateTime.parse(r['to_date']),
                status: r['status'],
                hodRemark: r['hod_remark'],
                reason: r['reason'] ?? 'No reason provided',
                documentPath: r['document_path'] ?? '',
              ))
          .toList();
    }
    throw Exception('Failed to fetch reviewed medical requests');
  }

  static Future<void> reviewMedical(
      String requestId, String action, String? remark) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/medical/hod/review'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'request_id': requestId,
        'action': action,
        'remark': remark ?? '',
      }),
    );
    if (response.statusCode != 200) throw Exception('Review failed');
  }

  // ─────────────────────────────────────────────────────────────────
  // ANNOUNCEMENT METHODS
  // ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> fetchMyAnnouncementGroups() async {
    // Ensure token is loaded from storage before fetching
    await getToken();
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/announce/groups/my'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      // Surface auth errors clearly instead of silently returning []
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Not authenticated. Please log in again.');
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createAnnouncementGroup(
      String name) async {
    // Ensure token is loaded from storage before request
    await getToken();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/announce/groups/create'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({"name": name}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    // Try to parse backend error detail, fall back to status code message
    try {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Creation failed (${response.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Creation failed (${response.statusCode})');
    }
  }

  /// Send the raw invite code WITH prefix (std@... or ad@...) directly to backend.
  /// Backend handles prefix parsing and role assignment.
  static Future<Map<String, dynamic>> joinAnnouncementGroup(
      String code) async {
    // Ensure token is loaded from storage before request
    await getToken();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/announce/groups/join'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({"invite_link": code.trim()}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    try {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Join failed (${response.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Join failed (${response.statusCode})');
    }
  }

  static Future<List<dynamic>> fetchAnnouncements(int groupId) async {
    await getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/announce/groups/$groupId/messages'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<void> postAnnouncement({
    required int groupId,
    required String type,
    String? content,
    required List<String> tags,
    List<String>? pollOptions,
    File? file,
  }) async {
    final token = await getToken();
    final uri =
        Uri.parse('${AppConfig.baseUrl}/api/announce/groups/$groupId/announce');

    var request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields['message_type'] = type;
    request.fields['tags'] = jsonEncode(tags);

    if (content != null && content.isNotEmpty) {
      request.fields['content'] = content;
    }
    if (pollOptions != null && pollOptions.isNotEmpty) {
      request.fields['poll_options'] = jsonEncode(pollOptions);
    }
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['detail'] ?? 'Failed to post announcement (${response.statusCode})');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to post announcement (${response.statusCode})');
      }
    }
  }

  static Future<void> deleteAnnouncement(
      int groupId, int announcementId) async {
    await getToken();
    final response = await http.delete(
      Uri.parse(
          '${AppConfig.baseUrl}/api/announce/groups/$groupId/announce/$announcementId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) throw Exception('Delete failed');
  }

  /// Toggle reaction — sending the same emoji again removes it.
  static Future<void> reactToAnnouncement(int announceId, String emoji) async {
    await getToken();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/announce/react'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({"announcement_id": announceId, "emoji": emoji}),
    );
    if (response.statusCode != 200) throw Exception('React failed');
  }

  /// Vote on a poll option — sending the same option_id toggles vote off.
  static Future<void> votePoll(int announcementId, int optionId) async {
    await getToken();
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/announce/poll/vote'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        "announcement_id": announcementId,
        "option_id": optionId,
      }),
    );
    if (response.statusCode != 200) throw Exception('Vote failed');
  }

  static Future<List<dynamic>> fetchGroupTags(int groupId) async {
    await getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/announce/groups/$groupId/tags'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<List<dynamic>> fetchGroupMembers(int groupId) async {
    await getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/announce/groups/$groupId/members'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<void> leaveGroup(int groupId) async {
    await getToken();
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/announce/groups/$groupId/leave'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) throw Exception('Leave failed');
  }
}

// ─────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────

class RegistrationResult {
  final bool success;
  final String message;
  const RegistrationResult({required this.success, required this.message});
}