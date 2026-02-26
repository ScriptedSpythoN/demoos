// lib/models/profile_models.dart
//
// Shared data models for Student, Faculty and HOD profiles.
// Kept backend-ready: toJson / fromJson stubs included.

// ─────────────────────────────────────────────────────────────────
class StudentProfile {
  String name;
  String registrationNumber;
  String rollNumber;
  String semester;
  String contactNumber;
  String email;
  String guardianName;
  String guardianContact;
  String? profileImagePath; // local file path or network URL

  StudentProfile({
    this.name = '',
    this.registrationNumber = '',
    this.rollNumber = '',
    this.semester = '',
    this.contactNumber = '',
    this.email = '',
    this.guardianName = '',
    this.guardianContact = '',
    this.profileImagePath,
  });

  /// Auto-derive semester from registration number.
  /// Convention: last 2 digits of reg no encode admission year.
  /// Adjust logic to match your actual scheme.
  static String deriveSemester(String regNo) {
    if (regNo.length < 4) return '';
    try {
      final yearDigits = int.parse(regNo.substring(2, 4));
      final currentYear = DateTime.now().year % 100;
      final diff = (currentYear - yearDigits).clamp(0, 4);
      final sem = (diff * 2 + 1).clamp(1, 8);
      return sem.toString();
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'registration_number': registrationNumber,
        'roll_number': rollNumber,
        'semester': semester,
        'contact_number': contactNumber,
        'email': email,
        'guardian_name': guardianName,
        'guardian_contact': guardianContact,
        'profile_image_path': profileImagePath,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> j) => StudentProfile(
        name: j['name'] ?? '',
        registrationNumber: j['registration_number'] ?? '',
        rollNumber: j['roll_number'] ?? '',
        semester: j['semester'] ?? '',
        contactNumber: j['contact_number'] ?? '',
        email: j['email'] ?? '',
        guardianName: j['guardian_name'] ?? '',
        guardianContact: j['guardian_contact'] ?? '',
        profileImagePath: j['profile_image_path'],
      );
}

// ─────────────────────────────────────────────────────────────────
enum FacultyRole {
  professor,
  assistantProfessor,
  guestFaculty,
  hod,
}

extension FacultyRoleExt on FacultyRole {
  String get label {
    switch (this) {
      case FacultyRole.professor:         return 'Professor';
      case FacultyRole.assistantProfessor: return 'Assistant Professor';
      case FacultyRole.guestFaculty:      return 'Guest Faculty';
      case FacultyRole.hod:               return 'HOD';
    }
  }

  static FacultyRole fromLabel(String label) {
    switch (label) {
      case 'Professor':          return FacultyRole.professor;
      case 'Assistant Professor': return FacultyRole.assistantProfessor;
      case 'Guest Faculty':       return FacultyRole.guestFaculty;
      case 'HOD':                 return FacultyRole.hod;
      default:                    return FacultyRole.professor;
    }
  }

  /// Sort order for department screen
  int get sortOrder {
    switch (this) {
      case FacultyRole.hod:               return 0;
      case FacultyRole.professor:         return 1;
      case FacultyRole.assistantProfessor: return 2;
      case FacultyRole.guestFaculty:      return 3;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
class FacultyProfile {
  String name;
  String facultyId;
  FacultyRole role;
  String contactNumber;
  String email;
  String education;
  String fieldsOfExpertise;
  String coursesTypicallyTaught;
  String researchAndPublications;
  String? profileImagePath;

  FacultyProfile({
    this.name = '',
    this.facultyId = '',
    this.role = FacultyRole.professor,
    this.contactNumber = '',
    this.email = '',
    this.education = '',
    this.fieldsOfExpertise = '',
    this.coursesTypicallyTaught = '',
    this.researchAndPublications = '',
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'faculty_id': facultyId,
        'role': role.label,
        'contact_number': contactNumber,
        'email': email,
        'education': education,
        'fields_of_expertise': fieldsOfExpertise,
        'courses_typically_taught': coursesTypicallyTaught,
        'research_and_publications': researchAndPublications,
        'profile_image_path': profileImagePath,
      };

  factory FacultyProfile.fromJson(Map<String, dynamic> j) => FacultyProfile(
        name: j['name'] ?? '',
        facultyId: j['faculty_id'] ?? '',
        role: FacultyRoleExt.fromLabel(j['role'] ?? ''),
        contactNumber: j['contact_number'] ?? '',
        email: j['email'] ?? '',
        education: j['education'] ?? '',
        fieldsOfExpertise: j['fields_of_expertise'] ?? '',
        coursesTypicallyTaught: j['courses_typically_taught'] ?? '',
        researchAndPublications: j['research_and_publications'] ?? '',
        profileImagePath: j['profile_image_path'],
      );
}

// ─────────────────────────────────────────────────────────────────
class HodProfile {
  String name;
  String uniqueId;
  String contactNumber;
  String email;
  String education;
  String fieldsOfExpertise;
  String coursesTypicallyTaught;
  String researchAndPublications;
  String? profileImagePath;

  HodProfile({
    this.name = '',
    this.uniqueId = '',
    this.contactNumber = '',
    this.email = '',
    this.education = '',
    this.fieldsOfExpertise = '',
    this.coursesTypicallyTaught = '',
    this.researchAndPublications = '',
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'unique_id': uniqueId,
        'contact_number': contactNumber,
        'email': email,
        'education': education,
        'fields_of_expertise': fieldsOfExpertise,
        'courses_typically_taught': coursesTypicallyTaught,
        'research_and_publications': researchAndPublications,
        'profile_image_path': profileImagePath,
      };

  factory HodProfile.fromJson(Map<String, dynamic> j) => HodProfile(
        name: j['name'] ?? '',
        uniqueId: j['unique_id'] ?? '',
        contactNumber: j['contact_number'] ?? '',
        email: j['email'] ?? '',
        education: j['education'] ?? '',
        fieldsOfExpertise: j['fields_of_expertise'] ?? '',
        coursesTypicallyTaught: j['courses_typically_taught'] ?? '',
        researchAndPublications: j['research_and_publications'] ?? '',
        profileImagePath: j['profile_image_path'],
      );
}

// ─────────────────────────────────────────────────────────────────
/// Singleton-style in-memory store so the Department screen can
/// read profile data written by Faculty / HOD profile screens.
/// Replace with your actual persistence layer (SharedPreferences / API).
class ProfileStore {
  static final ProfileStore _inst = ProfileStore._();
  ProfileStore._();
  factory ProfileStore() => _inst;

  HodProfile? hodProfile;
  final List<FacultyProfile> facultyProfiles = [];

  void upsertFaculty(FacultyProfile p) {
    final idx = facultyProfiles.indexWhere((f) => f.facultyId == p.facultyId);
    if (idx >= 0) {
      facultyProfiles[idx] = p;
    } else {
      facultyProfiles.add(p);
    }
  }

  /// Returns all profiles sorted HOD → Professor → Asst Prof → Guest
  List<dynamic> sortedForDepartment() {
    final list = <dynamic>[];
    if (hodProfile != null) list.add(hodProfile!);
    final sorted = List<FacultyProfile>.from(facultyProfiles)
      ..sort((a, b) => a.role.sortOrder.compareTo(b.role.sortOrder));
    list.addAll(sorted);
    return list;
  }
}