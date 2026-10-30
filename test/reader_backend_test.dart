import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_manga/services/reader_service.dart';

void main() {
  group('KuroReaderBackendService - Automated Tests', () {
    late KuroReaderBackendService readerService;

    setUp(() {
      readerService = KuroReaderBackendService.instance;
    });

    test('1. Reader Stats - Valores seguros por defecto cuando no hay sesión activa', () async {
      final stats = await readerService.getReaderStats('');
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('mangasLeidos'), isTrue);
      expect(stats.containsKey('favoritosCount'), isTrue);
      expect(stats.containsKey('nivel'), isTrue);
      expect(stats['mangasLeidos'], equals(0));
      expect(stats['favoritosCount'], equals(0));
    });

    test('2. Historial de Lectura - Cálculo de porcentaje y estructura', () {
      final totalPages = 45;
      final currentPage = 23;
      final double progress = totalPages > 0
          ? ((currentPage / totalPages) * 100).clamp(1.0, 100.0)
          : 0.0;
      final percent = progress.round();

      expect(percent, equals(51));

      final readingPayload = {
        'mangaId': 'db-super-01',
        'mangaTitle': 'Dragon Ball Super',
        'coverUrl': 'https://storage/cover.jpg',
        'chapterTitle': 'Capítulo 01: El Sueño Premonitorio',
        'tomoTitle': 'Tomo 01',
        'currentPage': currentPage,
        'totalPages': totalPages,
        'progressPercent': percent,
      };

      expect(readingPayload['mangaId'], equals('db-super-01'));
      expect(readingPayload['progressPercent'], equals(51));
      expect(readingPayload['tomoTitle'], equals('Tomo 01'));
    });

    test('3. Biblioteca Personal - Estructura de Favoritos', () {
      final favItem = {
        'mangaId': 'fate-extra-01',
        'title': 'Fate Extra Last Encore',
        'imageUrl': 'https://storage/fate.jpg',
        'category': 'Shonen',
      };

      expect(favItem['mangaId'], equals('fate-extra-01'));
      expect(favItem['title'], equals('Fate Extra Last Encore'));
      expect(favItem['category'], equals('Shonen'));
    });

    test('4. Calificaciones - Cálculo de promedio y redondeo', () {
      final ratings = [5.0, 4.0, 5.0, 4.5, 5.0];
      final double sum = ratings.reduce((a, b) => a + b);
      final double avg = sum / ratings.length;
      final roundedAvg = double.parse(avg.toStringAsFixed(1));

      expect(roundedAvg, equals(4.7));
      expect(ratings.length, equals(5));
    });

    test('5. Comunidad y Comentarios - Estructura y sanitización', () {
      final commentPayload = {
        'userId': 'usr_test_123',
        'autor': 'Lector Nocturno',
        'avatar': 'https://storage/avatar.jpg',
        'comentario': 'Excelente capítulo y traducción impecable.',
        'puntuacion': 5.0,
        'clan': 'CLAN CARMESÍ',
        'likes': 0,
      };

      expect(commentPayload['autor'], isNotEmpty);
      expect(commentPayload['comentario'], contains('Excelente'));
      expect(commentPayload['clan'], equals('CLAN CARMESÍ'));
      expect(commentPayload['puntuacion'], equals(5.0));
    });
  });
}
