/// 여행·이사처럼 목적별로 비용을 묶는 프로젝트
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.isArchived = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    name: json['name'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    budget: json['budget'] as int,
    isArchived: json['isArchived'] as bool? ?? false,
  );

  final String id;

  final String name;

  final DateTime startDate;

  final DateTime endDate;

  /// 프로젝트 예산(원)
  final int budget;

  /// 보관 여부. 보관한 프로젝트는 보기만 하고, 거래 입력의 프로젝트 태그에 나오지 않습니다.
  final bool isArchived;

  Project withArchived({required bool isArchived}) => Project(
    id: id,
    name: name,
    startDate: startDate,
    endDate: endDate,
    budget: budget,
    isArchived: isArchived,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'budget': budget,
    'isArchived': isArchived,
  };
}
