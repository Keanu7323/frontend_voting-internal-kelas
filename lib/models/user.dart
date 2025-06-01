class User {
  final String id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class VoteResult {
  final String optionId;
  final String optionLabel;
  final int count;
  final double percentage;

  VoteResult({
    required this.optionId,
    required this.optionLabel,
    required this.count,
    required this.percentage,
  });

  factory VoteResult.fromJson(Map<String, dynamic> json) {
    return VoteResult(
      optionId: json['optionId'] ?? '',
      optionLabel: json['optionLabel'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}