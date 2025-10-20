//models / DTOS

class Student {
  final int id;
  final String username;
  final String password;
  final String course;

  Student({
    required this.id,
    required this.username,
    required this.password,
    required this.course
  });
}