class CompetitorModel {
  final String name;
  final String photoUrl;
  final int score;
  final String status;

  CompetitorModel({
    required this.name,
    required this.photoUrl,
    required this.score,
    required this.status,
  });

  factory CompetitorModel.fromMap(Map<String, dynamic> map) {
    return CompetitorModel(
      name: map['name'],
      photoUrl: map['photoUrl'] ?? '',
      score: map['score'],
      status: map['status'] ?? 'waiting',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'score': score,
      'status': status,
    };
  }
}
