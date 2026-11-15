import 'package:educano_app/core/utils/api_mappers.dart';
import 'package:educano_app/features/course/models/course_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a question to the API alternative-letter contract', () {
    final payload = ApiMappers.questionPayload(
      const ActivityQuestion(
        id: '',
        title: 'Frações',
        statement: 'Quanto é 1/2 + 1/2?',
        difficulty: ActivityQuestionDifficulty.easy,
        options: ['1/2', '1', '2'],
        correctOptionIndex: 1,
      ),
    );

    expect(payload['titulo'], 'Frações');
    expect(payload['enunciado'], 'Quanto é 1/2 + 1/2?');
    expect(payload['letraCorreta'], 'B');
    expect(payload['alternativas'], [
      {'letra': 'A', 'texto': '1/2'},
      {'letra': 'B', 'texto': '1'},
      {'letra': 'C', 'texto': '2'},
    ]);
    expect(payload.containsKey('materia'), isFalse);
    expect(payload.containsKey('correta'), isFalse);
  });

  test('reads the correct alternative from the API alternative ID', () {
    final question = ApiMappers.question({
      'id': 'question-id',
      'titulo': 'Questão',
      'enunciado': 'Qual é a resposta?',
      'idAlternativaCorreta': 'answer-b',
      'alternativas': [
        {'id': 'answer-a', 'texto': 'A'},
        {'id': 'answer-b', 'texto': 'B'},
      ],
    });

    expect(question.correctOptionIndex, 1);
    expect(question.optionIds, ['answer-a', 'answer-b']);
  });
}
