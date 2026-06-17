
enum ListingType { roomAvailable, lookingForRoom, sublease }

class ListingModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final bool userVerified;
  final ListingType type;
  final String title;
  final String description;
  final double monthlyRent;
  final double securityDeposit;
  final String location;
  final String neighborhood;
  final List<String> photos;
  final bool isFurnished;
  final bool utilitiesIncluded;
  final DateTime availableFrom;
  final String genderPreference;
  final int currentRoommates;
  final int totalRooms;
  final double rating;
  final int views;
  final bool isFeatured;
  final List<String> amenities;
  final bool isOwnerPost;
  final List<String> roommateIds;

  ListingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.userVerified,
    required this.type,
    required this.title,
    required this.description,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.location,
    required this.neighborhood,
    required this.photos,
    required this.isFurnished,
    required this.utilitiesIncluded,
    required this.availableFrom,
    required this.genderPreference,
    required this.currentRoommates,
    required this.totalRooms,
    this.rating = 0.0,
    this.views = 0,
    this.isFeatured = false,
    this.amenities = const [],
    this.isOwnerPost = false,
    this.roommateIds = const [],
  });

  String get typeLabel {
    switch (type) {
      case ListingType.roomAvailable:
        return 'Room Available';
      case ListingType.lookingForRoom:
        return 'Looking for Room';
      case ListingType.sublease:
        return 'Sublease';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userPhoto': userPhoto,
    'userVerified': userVerified,
    'type': type.index,
    'title': title,
    'description': description,
    'monthlyRent': monthlyRent,
    'securityDeposit': securityDeposit,
    'location': location,
    'neighborhood': neighborhood,
    'photos': photos,
    'isFurnished': isFurnished,
    'utilitiesIncluded': utilitiesIncluded,
    'availableFrom': availableFrom.toIso8601String(),
    'genderPreference': genderPreference,
    'currentRoommates': currentRoommates,
    'totalRooms': totalRooms,
    'rating': rating,
    'views': views,
    'isFeatured': isFeatured,
    'amenities': amenities,
    'isOwnerPost': isOwnerPost,
    'roommateIds': roommateIds,
  };

  factory ListingModel.fromJson(Map<String, dynamic> json) => ListingModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    userPhoto: json['userPhoto'] as String,
    userVerified: json['userVerified'] as bool? ?? false,
    type: ListingType.values[json['type'] as int? ?? 0],
    title: json['title'] as String,
    description: json['description'] as String,
    monthlyRent: (json['monthlyRent'] as num).toDouble(),
    securityDeposit: (json['securityDeposit'] as num).toDouble(),
    location: json['location'] as String,
    neighborhood: json['neighborhood'] as String,
    photos: (json['photos'] as List<dynamic>).cast<String>(),
    isFurnished: json['isFurnished'] as bool? ?? false,
    utilitiesIncluded: json['utilitiesIncluded'] as bool? ?? false,
    availableFrom: DateTime.tryParse(json['availableFrom'] as String? ?? '') ?? DateTime.now(),
    genderPreference: json['genderPreference'] as String,
    currentRoommates: json['currentRoommates'] as int? ?? 0,
    totalRooms: json['totalRooms'] as int? ?? 1,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    views: json['views'] as int? ?? 0,
    isFeatured: json['isFeatured'] as bool? ?? false,
    amenities: (json['amenities'] as List<dynamic>?)?.cast<String>() ?? [],
    isOwnerPost: json['isOwnerPost'] as bool? ?? false,
    roommateIds: (json['roommateIds'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  ListingModel copyWith({
    String? title,
    String? description,
    double? monthlyRent,
    double? securityDeposit,
    String? location,
    String? neighborhood,
    List<String>? photos,
    bool? isFurnished,
    bool? utilitiesIncluded,
    DateTime? availableFrom,
    String? genderPreference,
    int? currentRoommates,
    int? totalRooms,
    double? rating,
    int? views,
    bool? isFeatured,
    List<String>? amenities,
    bool? isOwnerPost,
    List<String>? roommateIds,
  }) {
    return ListingModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      userVerified: userVerified,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      location: location ?? this.location,
      neighborhood: neighborhood ?? this.neighborhood,
      photos: photos ?? this.photos,
      isFurnished: isFurnished ?? this.isFurnished,
      utilitiesIncluded: utilitiesIncluded ?? this.utilitiesIncluded,
      availableFrom: availableFrom ?? this.availableFrom,
      genderPreference: genderPreference ?? this.genderPreference,
      currentRoommates: currentRoommates ?? this.currentRoommates,
      totalRooms: totalRooms ?? this.totalRooms,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      isFeatured: isFeatured ?? this.isFeatured,
      amenities: amenities ?? this.amenities,
      isOwnerPost: isOwnerPost ?? this.isOwnerPost,
      roommateIds: roommateIds ?? this.roommateIds,
    );
  }
}

