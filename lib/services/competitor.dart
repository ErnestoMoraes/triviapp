class CompetitorModel {
  final String name;
  final String photoUrl;
  final int score;

  CompetitorModel({
    required this.name,
    required this.photoUrl,
    required this.score,
  });

  factory CompetitorModel.fromMap(Map<String, dynamic> map) {
    return CompetitorModel(
      name: map['name'],
      photoUrl: map['photoUrl'] ?? '',
      score: map['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'score': score,
    };
  }
}
