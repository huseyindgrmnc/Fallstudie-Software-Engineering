class Trophies {
  final int bronze;
  final int silver;
  final int gold;
  final int platinum;

  Trophies({
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.platinum,
  });

  factory Trophies.fromJson(Map<String, dynamic> json) {
    return Trophies(
      bronze: json['bronze'],
      silver: json['silver'],
      gold: json['gold'],
      platinum: json['platinum'],
    );
  }
}


class TrophyInfo {
  final String title;
  final String iconUrl;
  final Trophies definedTrophies;
  final Trophies earnedTrophies;
  final int progress;

  TrophyInfo({
    required this.title,
    required this.iconUrl,
    required this.definedTrophies,
    required this.earnedTrophies,
    required this.progress,
  });

  factory TrophyInfo.fromJson(Map<String, dynamic> json) {
    return TrophyInfo(
      title: json['trophyTitleName'],
      iconUrl: json['trophyTitleIconUrl'],
      definedTrophies: Trophies.fromJson(json['definedTrophies']),
      earnedTrophies: Trophies.fromJson(json['earnedTrophies']),
      progress: json['progress'],
    );
  }
}