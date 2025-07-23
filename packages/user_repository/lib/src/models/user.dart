import '../entities/entities.dart';

class MyUser {
  List<String> friends;
  int streak;
  List<String> incomingRequest;
  List<String> outgoingRequest;
  String userId;
  String username;
  String email;
  String name;
  bool isActive;

  MyUser({
    required this.friends,
    required this.streak,
    required this.incomingRequest,
    required this.outgoingRequest,
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.isActive,
  });

  static final empty = MyUser(
    friends: [],
    streak: 0,
    outgoingRequest: [],
    incomingRequest: [],
    userId: '',
    username: '',
    email: '',
    name: '',
    isActive: false,
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      friends: friends,
      streak: streak,
      outgoingRequest: outgoingRequest,
      incomingRequest: incomingRequest,
      userId: userId,
      username: username,
      email: email,
      name: name,
      isActive: isActive,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      friends: entity.friends,
      streak: entity.streak,
      outgoingRequest: entity.outgoingRequest,
      incomingRequest: entity.incomingRequest,
      userId: entity.userId,
      username: entity.username,
      email: entity.email,
      name: entity.name,
      isActive: entity.isActive,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $username, $email, $name, $isActive, $incomingRequest, $outgoingRequest, $streak, $friends';
  }
}
