class MyUserEntity {
  String userId;
  int streak;
  List<String> incomingRequest;
  List<String> outgoingRequest;
  String username;
  String email;
  String name;
  bool isActive;

  MyUserEntity({
    required this.incomingRequest,
    required this.streak,
    required this.outgoingRequest,
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.isActive, 
  });


  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'streak': streak,
      'username': username,
      'email': email,
      'name': name,
      'isActive': isActive,
      'incomingRequests': incomingRequest,
      'outgoingRequests' : outgoingRequest,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
  return MyUserEntity(
    streak: doc['streak'] is int ? doc['streak'] : int.tryParse(doc['streak']?.toString() ?? '') ?? 0,
    incomingRequest: List<String>.from(doc['incomingRequests'] ?? []),
    outgoingRequest: List<String>.from(doc['outgoingRequests'] ?? []),
    userId: doc['userId']?.toString() ?? '',
    username: doc['username']?.toString() ?? '',
    email: doc['email']?.toString() ?? '',
    name: doc['name']?.toString() ?? '',
    isActive: doc['isActive'] is bool ? doc['isActive'] : false,
  );
}





  @override
  String toString() {
    return 'MyUserEntity: $userId, $username, $email, $name, $isActive, $incomingRequest, $outgoingRequest, $streak';
  }
}
