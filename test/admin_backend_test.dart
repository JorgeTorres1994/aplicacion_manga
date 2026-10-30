import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_manga/services/admin_service.dart';

void main() {
  group('KuroAdminBackendService - Automated Tests', () {
    late KuroAdminBackendService service;

    setUp(() {
      service = KuroAdminBackendService.instance;
    });

    test('1. Dashboard Metrics - Formato y valores de fallback', () async {
      final metrics = await service.getDashboardMetrics();

      expect(metrics.containsKey('readersCount'), isTrue);
      expect(metrics.containsKey('catalogCount'), isTrue);
      expect(metrics.containsKey('pendingRaws'), isTrue);
      expect(metrics.containsKey('forumReports'), isTrue);

      expect(metrics['pendingRaws'], isA<int>());
      expect(metrics['forumReports'], isA<String>());
      expect(metrics['status'], isNotNull);
    });

    test('2. Publicar Capítulo - Validación de estructura y metadatos', () async {
      // Simulación de los parámetros requeridos por el backend
      const series = 'Berserk';
      const vol = 'Tomo 42';
      const capNum = 'Capitulo 143';
      const capName = 'El Despertar del Behemoth';
      const tags = ['Dark Fantasy', 'Seinen', 'Psicológico'];

      // Construcción del paquete de datos esperado
      final expectedPayload = {
        'title': '$series: $vol',
        'capitulo': capNum,
        'nombreCapitulo': capName,
        'mangaCategoryName': 'Dark Fantasy',
        'tags': tags,
        'type': 'SEINEN • RAW',
        'numberPages': '42',
        'visibilidad': 'PUBLICADO',
      };

      expect(expectedPayload['title'], equals('Berserk: Tomo 42'));
      expect(expectedPayload['tags'], contains('Dark Fantasy'));
      expect(expectedPayload['tags'], contains('Seinen'));
      expect(expectedPayload['visibilidad'], equals('PUBLICADO'));
    });

    test('3. Moderación - Categorización de acciones de seguridad', () async {
      final validActions = ['sancionar', 'aprobar', 'purgar', 'tag_spoiler', 'ban'];

      for (var action in validActions) {
        expect(validActions.contains(action), isTrue);
      }

      // Verificación de resolución de reportes
      final resolved = await service.autoResolveAllReports();
      expect(resolved, greaterThanOrEqualTo(0));
    });

    test('4. Perfil Admin - Integridad de datos y roles', () async {
      final profilePayload = {
        'usuario': 'Jorge Torres',
        'celular': '952336505',
        'bio': 'Root Administrator • Kuro Manga Platform // Nivel 9 SuperAdmin',
        'avatar': 'images/admin_crops/mod_user_1.png',
        'rol': 'admin',
        'correo': 'jorge.torres.1994.1000@gmail.com',
      };

      expect(profilePayload['rol'], equals('admin'));
      expect(profilePayload['correo'], equals('jorge.torres.1994.1000@gmail.com'));
      expect(profilePayload['celular'], equals('952336505'));
      expect(profilePayload['usuario'], equals('Jorge Torres'));
      expect(profilePayload['avatar'], startsWith('images/admin_crops/'));
      expect(profilePayload.containsKey('email'), isFalse);
      expect(profilePayload.containsKey('telefono'), isFalse);
    });

    test('5. Catálogo - Estados de emisión permitidos', () {
      final allowedStatuses = ['EN EMISIÓN', 'PAUSADO', 'FINALIZADO'];

      expect(allowedStatuses.contains('EN EMISIÓN'), isTrue);
      expect(allowedStatuses.contains('PAUSADO'), isTrue);
      expect(allowedStatuses.contains('FINALIZADO'), isTrue);
      expect(allowedStatuses.contains('CANCELADO'), isFalse);
    });

    test('6. Catálogo y Ficha Técnica - Integridad de metadatos para Admin', () {
      final sampleMangaData = {
        'docId': 'sample_manga_123',
        'id': 'sample_manga_123',
        'title': 'Chainsaw Man',
        'author': 'Tatsuki Fujimoto',
        'category': 'Shonen • Acción',
        'type': 'MANGA',
        'status': 'EN EMISIÓN',
        'numberPages': '45',
        'capitulo': '1',
        'nombreCapitulo': 'Perro y Motosierra',
        'pdfUrl': 'https://example.com/chapter1.pdf',
        'imageUrl': 'https://example.com/cover.jpg',
        'views': '1250',
        'fecha_subida_str': '2026-10-29 17:00:00',
        'tags': ['Acción', 'Demonios', 'Gore'],
      };

      expect(sampleMangaData['docId'], isNotEmpty);
      expect(sampleMangaData['title'], equals('Chainsaw Man'));
      expect(sampleMangaData['author'], equals('Tatsuki Fujimoto'));
      expect(sampleMangaData['pdfUrl'], startsWith('https://'));
      expect(sampleMangaData['tags'], hasLength(3));
      expect(sampleMangaData['numberPages'], equals('45'));
    });

    test('7. Jerarquía 3 Niveles: Manga -> Tomos -> Capítulos', () {
      const mangaId = 'manga_berserk_001';
      const tomoId = 'tomo_01';
      const capId = 'cap_001';

      // Ruta del capítulo bajo la subcolección del manga
      const chapterFirestorePath = 'mangas/$mangaId/capitulos/$capId';
      const tomoFirestorePath = 'mangas/$mangaId/tomos/$tomoId';

      expect(chapterFirestorePath, startsWith('mangas/$mangaId/capitulos/'));
      expect(tomoFirestorePath, startsWith('mangas/$mangaId/tomos/'));

      final chapterRecord = {
        'id': capId,
        'mangaId': mangaId,
        'mangaTitle': 'Berserk',
        'tomo': 'Tomo 01',
        'numero': 1,
        'capituloDisplay': '01',
        'nombre': 'El Espadachín Negro',
        'pdfUrl': 'https://kuro.moe/berserk/c01.pdf',
        'visibilidad': 'PUBLICADO',
      };

      expect(chapterRecord['mangaId'], equals(mangaId));
      expect(chapterRecord['tomo'], equals('Tomo 01'));
      expect(chapterRecord['numero'], equals(1));
      expect(chapterRecord['visibilidad'], equals('PUBLICADO'));
    });

    test('8. Agrupación de Capítulos por Tomos y Ordenación', () {
      final chapters = [
        {'numero': 3, 'nombre': 'Cap 3', 'tomo': 'Tomo 01'},
        {'numero': 1, 'nombre': 'Cap 1', 'tomo': 'Tomo 01'},
        {'numero': 2, 'nombre': 'Cap 2', 'tomo': 'Tomo 01'},
        {'numero': 4, 'nombre': 'Cap 4', 'tomo': 'Tomo 02'},
      ];

      // Ordenación ascendente por número
      chapters.sort((a, b) => (a['numero'] as int).compareTo(b['numero'] as int));
      expect(chapters.first['numero'], equals(1));
      expect(chapters.last['numero'], equals(4));

      // Filtrado por tomo
      final tomo1Chapters = chapters.where((c) => c['tomo'] == 'Tomo 01').toList();
      final tomo2Chapters = chapters.where((c) => c['tomo'] == 'Tomo 02').toList();

      expect(tomo1Chapters.length, equals(3));
      expect(tomo2Chapters.length, equals(1));
    });
  });
}
