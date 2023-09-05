const Map<String, int> answerTypes = {
  "SHORT": 5,
  "MEDIUM": 10,
  "BIG": 15,
  "SUPER_BIG": 20
};

class Question{
  Question({required this.title, required this.answerType, required this.id});
  final String title;
  final String answerType;
  final int id;

  int get answerSize{
    return answerTypes[answerType] ?? 0;
  }
}