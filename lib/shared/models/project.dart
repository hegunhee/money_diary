/// 여행·이사처럼 목적별로 비용을 묶는 프로젝트
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.budget,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    name: json['name'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    budget: json['budget'] as int,
  );

  final String id;

  final String name;

  final DateTime startDate;

  final DateTime endDate;

  /// 프로젝트 예산(원)
  final int budget;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'budget': budget,
  };
}
