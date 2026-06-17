import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String occupation;
  final String city;
  final String bio;
  final String photoUrl;
  final bool isVerified;
  final double rating;
  final int reviewCount;

  // Housing Preferences
  final RangeValues budgetRange;
  final String preferredLocation;
  final DateTime moveInDate;
  final String leaseDuration;

  // Lifestyle Preferences
  final String sleepSchedule; // 'early_bird', 'night_owl', 'flexible'
  final int cleanlinessLevel; // 1-5
  final bool smoking;
  final bool drinking;
  final bool pets;
  final bool workFromHome;
  final int socialActivityLevel; // 1-5 (introvert to extrovert)
  final int guestFrequency; // 1-5

  // Stats
  final int matches;
  final List<String> interests;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.city,
    required this.bio,
    required this.photoUrl,
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.budgetRange,
    required this.preferredLocation,
    required this.moveInDate,
    required this.leaseDuration,
    required this.sleepSchedule,
    required this.cleanlinessLevel,
    required this.smoking,
    required this.drinking,
    required this.pets,
    required this.workFromHome,
    required this.socialActivityLevel,
    required this.guestFrequency,
    this.matches = 0,
    this.interests = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'occupation': occupation,
    'city': city,
    'bio': bio,
    'photoUrl': photoUrl,
    'isVerified': isVerified,
    'rating': rating,
    'reviewCount': reviewCount,
    'budgetStart': budgetRange.start,
    'budgetEnd': budgetRange.end,
    'preferredLocation': preferredLocation,
    'moveInDate': moveInDate.toIso8601String(),
    'leaseDuration': leaseDuration,
    'sleepSchedule': sleepSchedule,
    'cleanlinessLevel': cleanlinessLevel,
    'smoking': smoking,
    'drinking': drinking,
    'pets': pets,
    'workFromHome': workFromHome,
    'socialActivityLevel': socialActivityLevel,
    'guestFrequency': guestFrequency,
    'matches': matches,
    'interests': interests,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
    gender: json['gender'] as String,
    occupation: json['occupation'] as String,
    city: json['city'] as String,
    bio: json['bio'] as String,
    photoUrl: json['photoUrl'] as String,
    isVerified: json['isVerified'] as bool? ?? false,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    budgetRange: RangeValues(
      (json['budgetStart'] as num?)?.toDouble() ?? 800,
      (json['budgetEnd'] as num?)?.toDouble() ?? 1500,
    ),
    preferredLocation: json['preferredLocation'] as String,
    moveInDate: DateTime.tryParse(json['moveInDate'] as String? ?? '') ?? DateTime.now(),
    leaseDuration: json['leaseDuration'] as String,
    sleepSchedule: json['sleepSchedule'] as String,
    cleanlinessLevel: json['cleanlinessLevel'] as int,
    smoking: json['smoking'] as bool,
    drinking: json['drinking'] as bool,
    pets: json['pets'] as bool,
    workFromHome: json['workFromHome'] as bool,
    socialActivityLevel: json['socialActivityLevel'] as int,
    guestFrequency: json['guestFrequency'] as int,
    matches: json['matches'] as int? ?? 0,
    interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  double compatibilityWith(UserModel other) {
    double score = 0;
    double total = 0;

    // Budget compatibility (25%)
    double budgetOverlap = _rangeOverlap(budgetRange, other.budgetRange);
    score += budgetOverlap * 0.25;
    total += 0.25;

    // Cleanliness (20%)
    double cleanDiff = (cleanlinessLevel - other.cleanlinessLevel).abs().toDouble();
    double cleanScore = 1 - (cleanDiff / 4);
    score += cleanScore * 0.20;
    total += 0.20;

    // Sleep schedule (15%)
    double sleepScore = sleepSchedule == other.sleepSchedule ? 1.0 : 0.5;
    score += sleepScore * 0.15;
    total += 0.15;

    // Smoking (15%)
    double smokingScore = smoking == other.smoking ? 1.0 : 0.0;
    score += smokingScore * 0.15;
    total += 0.15;

    // Work style (10%)
    double workScore = workFromHome == other.workFromHome ? 1.0 : 0.6;
    score += workScore * 0.10;
    total += 0.10;

    // Social lifestyle (15%)
    double socialDiff = (socialActivityLevel - other.socialActivityLevel).abs().toDouble();
    double socialScore = 1 - (socialDiff / 4);
    score += socialScore * 0.15;
    total += 0.15;

    return (score / total).clamp(0.0, 1.0);
  }

  double _rangeOverlap(RangeValues a, RangeValues b) {
    double overlapStart = [a.start, b.start].reduce((x, y) => x > y ? x : y);
    double overlapEnd = [a.end, b.end].reduce((x, y) => x < y ? x : y);
    if (overlapEnd < overlapStart) return 0.0;
    double overlap = overlapEnd - overlapStart;
    double minRange = [(a.end - a.start), (b.end - b.start)].reduce((x, y) => x < y ? x : y);
    if (minRange <= 0) return 1.0;
    return (overlap / minRange).clamp(0.0, 1.0);
  }

  String get sleepScheduleLabel {
    switch (sleepSchedule) {
      case 'early_bird':
        return 'Early Bird';
      case 'night_owl':
        return 'Night Owl';
      default:
        return 'Flexible';
    }
  }

  String get budgetLabel {
    return '\$${budgetRange.start.toInt()} - \$${budgetRange.end.toInt()}/mo';
  }
}

