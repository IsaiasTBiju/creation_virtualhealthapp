/// Demo patient records (no PHI — synthetic) for healthcare professional UI.

class MockPatient {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String mrn;
  final String lastVisitLabel;
  final String conditionsSummary;
  final int avgStepsWeek;
  final String bpLast;
  final String glucoseLast;
  final List<String> diagnoses;
  final List<String> activeMedications;

  MockPatient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.mrn,
    required this.lastVisitLabel,
    required this.conditionsSummary,
    required this.avgStepsWeek,
    required this.bpLast,
    required this.glucoseLast,
    required this.diagnoses,
    required this.activeMedications,
  });

  MockPatient copyWith({
    List<String>? diagnoses,
    List<String>? activeMedications,
  }) {
    return MockPatient(
      id: id,
      fullName: fullName,
      age: age,
      gender: gender,
      mrn: mrn,
      lastVisitLabel: lastVisitLabel,
      conditionsSummary: conditionsSummary,
      avgStepsWeek: avgStepsWeek,
      bpLast: bpLast,
      glucoseLast: glucoseLast,
      diagnoses: diagnoses ?? List.from(this.diagnoses),
      activeMedications: activeMedications ?? List.from(this.activeMedications),
    );
  }
}

final List<MockPatient> kMockPatientsSeed = [
  MockPatient(
    id: 'p1',
    fullName: 'Jordan Lee',
    age: 54,
    gender: 'Female',
    mrn: 'MRN-100412',
    lastVisitLabel: '3 days ago — telehealth follow-up',
    conditionsSummary: 'Type 2 diabetes, hypertension, mild anxiety',
    avgStepsWeek: 6200,
    bpLast: '128/82 mmHg',
    glucoseLast: '118 mg/dL (fasting)',
    diagnoses: ['E11.9 Type 2 DM', 'I10 Essential hypertension'],
    activeMedications: ['Metformin 500mg BID', 'Lisinopril 10mg daily'],
  ),
  MockPatient(
    id: 'p2',
    fullName: 'Sam Okonkwo',
    age: 41,
    gender: 'Male',
    mrn: 'MRN-100883',
    lastVisitLabel: '1 week ago — lab review',
    conditionsSummary: 'Hyperlipidemia, obesity, sleep improvement plan',
    avgStepsWeek: 8400,
    bpLast: '122/78 mmHg',
    glucoseLast: '92 mg/dL (fasting)',
    diagnoses: ['E78.5 Hyperlipidemia', 'E66.9 Obesity'],
    activeMedications: ['Atorvastatin 20mg nightly'],
  ),
  MockPatient(
    id: 'p3',
    fullName: 'Riley Chen',
    age: 67,
    gender: 'Non-binary',
    mrn: 'MRN-100201',
    lastVisitLabel: 'Today — in-person vitals',
    conditionsSummary: 'CHF monitoring, medication reconciliation',
    avgStepsWeek: 3100,
    bpLast: '138/88 mmHg',
    glucoseLast: '101 mg/dL (random)',
    diagnoses: ['I50.9 Heart failure', 'I10 Hypertension'],
    activeMedications: ['Furosemide 40mg daily', 'Carvedilol 12.5mg BID'],
  ),
];
