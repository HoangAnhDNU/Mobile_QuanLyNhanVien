class Position {
  final String id;
  final String name;
  final int level;
  final double allowance;
  final String? createdAt;

  const Position({
    required this.id,
    required this.name,
    this.level = 1,
    this.allowance = 0,
    this.createdAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position.fromDbMap(json);
  Map<String, dynamic> toJson() => toDbMap();

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'allowance': allowance,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Position.fromDbMap(Map<String, dynamic> map) {
    return Position(
      id: map['id'] as String,
      name: map['name'] as String,
      level: (map['level'] as int?) ?? 1,
      allowance: (map['allowance'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] as String?,
    );
  }

  Position copyWith({
    String? id,
    String? name,
    int? level,
    double? allowance,
    String? createdAt,
  }) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      allowance: allowance ?? this.allowance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
