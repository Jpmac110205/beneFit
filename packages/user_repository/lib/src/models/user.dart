import 'package:user_repository/user_repository.dart';

class MyUser {
  List<String> friends;
  int streak;
  List<String> incomingRequests;
  List<String> outgoingRequests;
  String userId;
  String username;
  String email;
  String name;
  bool isActive;
  int totalExp;

  MyUser({
    required this.friends,
    required this.streak,
    required this.incomingRequests,
    required this.outgoingRequests,
    required this.userId,
    required this.username,
    required this.email,
    required this.name,
    required this.isActive,
    required this.totalExp,
  });

  static final empty = MyUser(
    friends: [],
    streak: 0,
    outgoingRequests: [],
    incomingRequests: [],
    userId: '',
    username: '',
    email: '',
    name: '',
    isActive: false,
    totalExp: 0,
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      friends: friends,
      streak: streak,
      outgoingRequests: outgoingRequests,
      incomingRequests: incomingRequests,
      userId: userId,
      username: username,
      email: email,
      name: name,
      isActive: isActive,
      totalExp: totalExp,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      friends: entity.friends,
      streak: entity.streak,
      outgoingRequests: entity.outgoingRequests,
      incomingRequests: entity.incomingRequests,
      userId: entity.userId,
      username: entity.username,
      email: entity.email,
      name: entity.name,
      isActive: entity.isActive,
      totalExp: entity.totalExp,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $username, $email, $name, $isActive, $incomingRequests, $outgoingRequests, $streak, $friends, $totalExp';
  }
}
