import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the Terms of Use asset', () async {
    final content = await rootBundle.loadString(
      'lib/assets/legal/termos-de-uso.txt',
    );

    expect(content, contains('TERMOS DE USO DA PLATAFORMA EDUCANO'));
  });

  test('loads the Privacy Policy asset', () async {
    final content = await rootBundle.loadString(
      'lib/assets/legal/politica-de-privacidade.txt',
    );

    expect(content, contains('POLÍTICA DE PRIVACIDADE DA PLATAFORMA EDUCANO'));
  });
}
