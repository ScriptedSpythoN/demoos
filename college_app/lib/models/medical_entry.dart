class MedicalEntry {
  final String requestId;
  final String studentRollNo;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;
  final String? hodRemark;

  MedicalEntry({
    required this.requestId,
    required this.studentRollNo,
    required this.fromDate,
    required this.toDate,
    required this.status,
    this.hodRemark, required documentPath, required ocrStatus, required ocrText, required reason,
  });
}
