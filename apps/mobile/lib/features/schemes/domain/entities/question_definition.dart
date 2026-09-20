class QuestionVisibilityCondition {
  final String field;
  final String operator; // EQ, NEQ, IN, NOT_IN
  final dynamic value;

  const QuestionVisibilityCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  bool evaluate(Map<String, dynamic> answers) {
    final answer = answers[field];
    if (answer == null) return false;

    switch (operator) {
      case 'EQ':
        return answer.toString() == value.toString();
      case 'NEQ':
        return answer.toString() != value.toString();
      case 'IN':
        if (value is List) {
          return (value as List)
              .map((e) => e.toString())
              .contains(answer.toString());
        }
        return false;
      case 'NOT_IN':
        if (value is List) {
          return !(value as List)
              .map((e) => e.toString())
              .contains(answer.toString());
        }
        return true;
      default:
        return false;
    }
  }
}

class QuestionDefinition {
  final String id;
  final String field;
  final String label;
  final String type; // SINGLE_SELECT, BOOLEAN, NUMBER, CURRENCY, TEXT
  final List<String>? options;
  final bool required;
  final QuestionVisibilityCondition? visibilityCondition;

  const QuestionDefinition({
    required this.id,
    required this.field,
    required this.label,
    required this.type,
    this.options,
    this.required = false,
    this.visibilityCondition,
  });

  bool isVisible(Map<String, dynamic> answers) {
    if (visibilityCondition == null) return true;
    return visibilityCondition!.evaluate(answers);
  }
}
