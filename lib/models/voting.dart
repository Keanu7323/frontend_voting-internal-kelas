class Voting {
  final String id;
  final String title;
  final String description;
  final List<VotingOption> options;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Voting({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Voting.fromJson(Map<String, dynamic> json) {
    return Voting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      options: (json['options'] as List?)
          ?.map((option) => VotingOption.fromJson(option))
          .toList() ?? [],
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'options': options.map((option) => option.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class VotingOption {
  final String id;
  final String label;
  final String description;

  VotingOption({
    required this.id,
    required this.label,
    this.description = '',
  });

  factory VotingOption.fromJson(Map<String, dynamic> json) {
    return VotingOption(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
    };
  }
}