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

// Sample data
class SampleData {
  static final List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'Alex Rivera',
      age: 26,
      gender: 'Male',
      occupation: 'Software Engineer',
      city: 'New York',
      bio: 'Looking for someone who appreciates a clean kitchen and doesn\'t mind occasional board game nights. I\'m...',
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      isVerified: true,
      rating: 4.8,
      reviewCount: 12,
      budgetRange: const RangeValues(1000, 1500),
      preferredLocation: 'Manhattan',
      moveInDate: DateTime.now().add(const Duration(days: 30)),
      leaseDuration: '12 months',
      sleepSchedule: 'night_owl',
      cleanlinessLevel: 4,
      smoking: false,
      drinking: true,
      pets: false,
      workFromHome: true,
      socialActivityLevel: 3,
      guestFrequency: 2,
      matches: 47,
      interests: ['Gaming', 'Cooking', 'Reading'],
    ),
    UserModel(
      id: '2',
      name: 'Jamie Chen',
      age: 24,
      gender: 'Female',
      occupation: 'Architecture Student',
      city: 'New York',
      bio: 'Architecture student who loves design and art. I keep things tidy and prefer a calm living environment.',
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      isVerified: true,
      rating: 4.9,
      reviewCount: 8,
      budgetRange: const RangeValues(900, 1400),
      preferredLocation: 'Brooklyn',
      moveInDate: DateTime.now().add(const Duration(days: 15)),
      leaseDuration: '12 months',
      sleepSchedule: 'early_bird',
      cleanlinessLevel: 5,
      smoking: false,
      drinking: false,
      pets: false,
      workFromHome: false,
      socialActivityLevel: 2,
      guestFrequency: 1,
      matches: 31,
      interests: ['Art', 'Architecture', 'Yoga'],
    ),
    UserModel(
      id: '3',
      name: 'Marcus Webb',
      age: 28,
      gender: 'Male',
      occupation: 'Graphic Designer',
      city: 'New York',
      bio: 'Creative professional who works from home. Clean, respectful, and enjoy quiet evenings.',
      photoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
      isVerified: true,
      rating: 4.7,
      reviewCount: 15,
      budgetRange: const RangeValues(1100, 1600),
      preferredLocation: 'Chelsea',
      moveInDate: DateTime.now().add(const Duration(days: 45)),
      leaseDuration: '6 months',
      sleepSchedule: 'flexible',
      cleanlinessLevel: 4,
      smoking: false,
      drinking: true,
      pets: true,
      workFromHome: true,
      socialActivityLevel: 2,
      guestFrequency: 2,
      matches: 22,
      interests: ['Design', 'Photography', 'Coffee'],
    ),
    UserModel(
      id: '4',
      name: 'Sarah Kim',
      age: 25,
      gender: 'Female',
      occupation: 'Barista',
      city: 'New York',
      bio: 'Early riser who loves coffee and cats. Looking for a clean and friendly housemate.',
      photoUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      isVerified: false,
      rating: 4.6,
      reviewCount: 5,
      budgetRange: const RangeValues(800, 1200),
      preferredLocation: 'Williamsburg',
      moveInDate: DateTime.now().add(const Duration(days: 7)),
      leaseDuration: '12 months',
      sleepSchedule: 'early_bird',
      cleanlinessLevel: 5,
      smoking: false,
      drinking: false,
      pets: true,
      workFromHome: false,
      socialActivityLevel: 3,
      guestFrequency: 2,
      matches: 18,
      interests: ['Coffee', 'Cats', 'Hiking'],
    ),
    UserModel(
      id: '5',
      name: 'Leo Zhang',
      age: 27,
      gender: 'Male',
      occupation: 'UX Researcher',
      city: 'New York',
      bio: 'UX researcher passionate about human-centered design. I am tidy and love cooking Asian food.',
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      isVerified: true,
      rating: 4.5,
      reviewCount: 9,
      budgetRange: const RangeValues(1000, 1500),
      preferredLocation: 'Astoria',
      moveInDate: DateTime.now().add(const Duration(days: 60)),
      leaseDuration: '12 months',
      sleepSchedule: 'night_owl',
      cleanlinessLevel: 4,
      smoking: false,
      drinking: true,
      pets: false,
      workFromHome: true,
      socialActivityLevel: 3,
      guestFrequency: 3,
      matches: 35,
      interests: ['UX', 'Cooking', 'Travel'],
    ),
  ];

  static final UserModel currentUser = UserModel(
    id: 'me',
    name: 'Jordan Taylor',
    age: 25,
    gender: 'Non-binary',
    occupation: 'Product Manager',
    city: 'New York',
    bio: 'PM at a startup, love hiking and cooking. Clean and organized. Looking for a chill roommate.',
    photoUrl: 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=400',
    isVerified: true,
    rating: 4.7,
    reviewCount: 7,
    budgetRange: const RangeValues(900, 1400),
    preferredLocation: 'Brooklyn',
    moveInDate: DateTime.now().add(const Duration(days: 30)),
    leaseDuration: '12 months',
    sleepSchedule: 'night_owl',
    cleanlinessLevel: 4,
    smoking: false,
    drinking: true,
    pets: false,
    workFromHome: true,
    socialActivityLevel: 3,
    guestFrequency: 2,
    matches: 47,
    interests: ['Hiking', 'Cooking', 'Product', 'Music'],
  );
}
