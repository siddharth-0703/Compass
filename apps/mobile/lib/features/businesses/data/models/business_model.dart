class BusinessModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String status;
  final int? yearStarted;
  final String? stage;
  final int? employees;
  final String? locationState;
  final String? locationDistrict;
  
  BusinessModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    this.yearStarted,
    this.stage,
    this.employees,
    this.locationState,
    this.locationDistrict,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    String? state;
    String? district;
    
    if (json['location'] is Map) {
      state = json['location']['state'];
      district = json['location']['district'];
    } else if (json['location'] is String) {
      state = json['location']; // If it's just a string, assume it's the state/general location
    }

    return BusinessModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'Draft',
      yearStarted: json['yearStarted'],
      stage: json['stage'],
      employees: json['employees'],
      locationState: state,
      locationDistrict: district,
    );
  }
}
