import '../../course/models/course_models.dart';

/// Questões provisórias usadas enquanto o app ainda não possui um banco
/// compartilhado de questões para montar simulados.
class ExamMockQuestions {
  ExamMockQuestions._();

  static const List<ActivityQuestion> all = [
    ActivityQuestion(
      id: 'mock-enem-1',
      title: 'Texto 1',
      statement:
          'As redes sociais digitais reconfiguraram a noção de esfera pública. '
          'Se antes o acesso à tribuna exigia mediação institucional, hoje a '
          'emissão de mensagens é instantânea e descentralizada. Contudo, a '
          'aparente democratização da palavra vem acompanhada de uma economia '
          'da atenção, na qual o algoritmo premia o engajamento pelo clímax '
          'emocional, transformando o debate complexo em polarização '
          'espetacularizada.\n\n'
          'O impacto desse modelo algorítmico na sociedade resulta em:',
      difficulty: ActivityQuestionDifficulty.medium,
      options: [
        'Ampliação do rigor crítico nas discussões políticas cotidianas.',
        'Superação definitiva das barreiras de acesso à informação qualificada.',
        'Redução da complexidade dos fatos em favor de reações passionais.',
        'Fortalecimento das instituições tradicionais de imprensa escrita.',
        'Neutralidade ideológica na circulação de conteúdos na internet.',
      ],
      correctOptionIndex: 2,
    ),
    ActivityQuestion(
      id: 'mock-enem-2',
      title: 'Questão 2',
      statement:
          'Uma escola instalou painéis solares que geram 18 kWh de energia '
          'por dia. Em cinco dias de funcionamento, os painéis geram, ao todo:',
      difficulty: ActivityQuestionDifficulty.easy,
      options: ['23 kWh', '60 kWh', '80 kWh', '90 kWh', '108 kWh'],
      correctOptionIndex: 3,
    ),
    ActivityQuestion(
      id: 'mock-enem-3',
      title: 'Questão 3',
      statement:
          'Em uma área urbana, a substituição de superfícies vegetadas por '
          'asfalto e concreto reduz a infiltração da água no solo. Uma medida '
          'que ajuda a diminuir alagamentos e recuperar essa infiltração é:',
      difficulty: ActivityQuestionDifficulty.medium,
      options: [
        'Ampliar a pavimentação impermeável das calçadas.',
        'Canalizar todos os cursos d’água da região.',
        'Instalar jardins de chuva e pavimentos permeáveis.',
        'Remover a vegetação das margens dos rios.',
        'Aumentar a velocidade de escoamento para os bairros baixos.',
      ],
      correctOptionIndex: 2,
    ),
  ];
}
