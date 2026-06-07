
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
}

// Sample listings
class SampleListings {
  static final List<ListingModel> listings = [
    ListingModel(
      id: 'l1',
      userId: '3',
      userName: 'Marcus Webb',
      userPhoto: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
      userVerified: true,
      type: ListingType.roomAvailable,
      title: 'Bright Loft in Chelsea',
      description: 'Stunning loft-style apartment in the heart of Chelsea. Floor-to-ceiling windows, exposed brick, modern kitchen. Looking for a creative professional or student.',
      monthlyRent: 1200,
      securityDeposit: 2400,
      location: 'Chelsea, Manhattan',
      neighborhood: 'Chelsea',
      photos: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
      ],
      isFurnished: true,
      utilitiesIncluded: false,
      availableFrom: DateTime.now().add(const Duration(days: 14)),
      genderPreference: 'Any',
      currentRoommates: 2,
      totalRooms: 3,
      rating: 4.8,
      views: 234,
      isFeatured: true,
      amenities: ['WiFi', 'Washer/Dryer', 'Gym', 'Rooftop', 'Doorman'],
      isOwnerPost: false,
      roommateIds: ['1', '3'],
    ),
    ListingModel(
      id: 'l2',
      userId: '1',
      userName: 'Alex Rivera',
      userPhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      userVerified: true,
      type: ListingType.roomAvailable,
      title: 'Cozy Room in Williamsburg',
      description: 'Private room in a beautifully renovated brownstone in trendy Williamsburg. Steps from L train and surrounded by amazing restaurants and bars.',
      monthlyRent: 1050,
      securityDeposit: 1050,
      location: 'Williamsburg, Brooklyn',
      neighborhood: 'Williamsburg',
      photos: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      ],
      isFurnished: false,
      utilitiesIncluded: true,
      availableFrom: DateTime.now().add(const Duration(days: 7)),
      genderPreference: 'Any',
      currentRoommates: 1,
      totalRooms: 2,
      rating: 4.6,
      views: 187,
      isFeatured: false,
      amenities: ['WiFi', 'Backyard', 'Near Subway'],
      isOwnerPost: false,
      roommateIds: ['1'],
    ),
    ListingModel(
      id: 'l3',
      userId: '2',
      userName: 'Jamie Chen',
      userPhoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      userVerified: true,
      type: ListingType.lookingForRoom,
      title: 'Looking: Studio or 1BR near Design District',
      description: 'Architecture student seeking a room or shared apartment near the Brooklyn design district. Very clean and quiet.',
      monthlyRent: 1100,
      securityDeposit: 1100,
      location: 'DUMBO, Brooklyn',
      neighborhood: 'DUMBO',
      photos: [
        'https://images.unsplash.com/photo-1459767129954-1b1c1f9b9ace?w=800',
      ],
      isFurnished: false,
      utilitiesIncluded: false,
      availableFrom: DateTime.now().add(const Duration(days: 30)),
      genderPreference: 'Female preferred',
      currentRoommates: 0,
      totalRooms: 1,
      rating: 4.9,
      views: 89,
      isFeatured: false,
      amenities: [],
      isOwnerPost: false,
      roommateIds: [],
    ),
    ListingModel(
      id: 'l4',
      userId: '5',
      userName: 'Leo Zhang',
      userPhoto: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      userVerified: true,
      type: ListingType.roomAvailable,
      title: 'Sublet: Modern Studio in Astoria',
      description: 'Newly listed studio apartment in Astoria. Fully furnished, great natural light. Landlord-owned property, looking for the first tenant to occupy and optionally add roommates later.',
      monthlyRent: 1350,
      securityDeposit: 0,
      location: 'Astoria, Queens',
      neighborhood: 'Astoria',
      photos: [
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=800',
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
      ],
      isFurnished: true,
      utilitiesIncluded: true,
      availableFrom: DateTime.now().add(const Duration(days: 60)),
      genderPreference: 'Any',
      currentRoommates: 0,
      totalRooms: 1,
      rating: 4.7,
      views: 156,
      isFeatured: true,
      amenities: ['Fully Furnished', 'WiFi Included', 'Utilities Included', 'Near Subway'],
      isOwnerPost: true,
      roommateIds: [],
    ),
    ListingModel(
      id: 'l5',
      userId: '4',
      userName: 'Sarah Kim',
      userPhoto: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      userVerified: false,
      type: ListingType.roomAvailable,
      title: 'Private Room, Shared House - Bushwick',
      description: 'Big private room in a 4-bedroom house. We have a garden, great roommates, and a very chill vibe.',
      monthlyRent: 950,
      securityDeposit: 950,
      location: 'Bushwick, Brooklyn',
      neighborhood: 'Bushwick',
      photos: [
        'https://images.unsplash.com/photo-1556020685-ae41abfc9365?w=800',
        'https://images.unsplash.com/photo-1571939228382-b2f2b585ce15?w=800',
      ],
      isFurnished: false,
      utilitiesIncluded: false,
      availableFrom: DateTime.now().add(const Duration(days: 3)),
      genderPreference: 'Female preferred',
      currentRoommates: 3,
      totalRooms: 4,
      rating: 4.4,
      views: 321,
      isFeatured: false,
      amenities: ['Garden', 'Parking', 'Pet Friendly'],
      isOwnerPost: false,
      roommateIds: ['3', '4', '5'],
    ),
    ListingModel(
      id: 'l6',
      userId: 'owner1',
      userName: 'Metropolitan Rentals',
      userPhoto: 'https://images.unsplash.com/photo-1545235621-c8c48f1df591?w=400',
      userVerified: true,
      type: ListingType.roomAvailable,
      title: 'Brand New Studio in DUMBO',
      description: 'Beautiful newly renovated apartment. Never occupied, ready for move-in. No current roommates. Host is property owner.',
      monthlyRent: 1500,
      securityDeposit: 1500,
      location: 'DUMBO, Brooklyn',
      neighborhood: 'DUMBO',
      photos: [
        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
      ],
      isFurnished: true,
      utilitiesIncluded: true,
      availableFrom: DateTime.now().add(const Duration(days: 5)),
      genderPreference: 'Any',
      currentRoommates: 0,
      totalRooms: 2,
      rating: 4.9,
      views: 92,
      isFeatured: true,
      amenities: ['WiFi', 'Gym', 'Elevator', 'Doorman', 'Near Subway'],
      isOwnerPost: true,
      roommateIds: [],
    ),
  ];
}

