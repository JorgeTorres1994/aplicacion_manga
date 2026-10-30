import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_manga/Screens/admin/admin_overview_screen.dart';

void main() {
  testWidgets('Admin Navigation Shell - Verifica las 5 pestañas y navegación persistente',
      (WidgetTester tester) async {
    // Configurar viewport móvil estándar HD
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: KuroAdminOverviewScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verificar que los 5 items de la barra de navegación existan
    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('PUBLICAR'), findsOneWidget);
    expect(find.text('CATÁLOGO'), findsOneWidget);
    expect(find.text('SEGURIDAD'), findsOneWidget);
    expect(find.text('PERFIL'), findsOneWidget);

    // 2. Verificar que la pantalla inicial sea Dashboard (SYS_VIEW / Overview)
    expect(find.text('ADMIN DASHBOARD'), findsOneWidget);
    expect(find.text('Métricas Clave'), findsOneWidget);
    expect(find.text('Comandos Directos'), findsOneWidget);

    // 3. Cambiar a la pestaña PUBLICAR (Pestaña 1)
    await tester.tap(find.text('PUBLICAR'));
    await tester.pumpAndSettle();

    expect(find.text('SUBIR CAPÍTULO'), findsOneWidget);
    // Verificar que la barra inferior sigue existiendo (persistente)
    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('PERFIL'), findsOneWidget);

    // 4. Cambiar a la pestaña CATÁLOGO (Pestaña 2)
    await tester.tap(find.text('CATÁLOGO'));
    await tester.pumpAndSettle();

    expect(find.text('CATÁLOGO GLOBAL'), findsOneWidget);
    expect(find.text('NUEVA SERIE'), findsOneWidget);
    expect(find.text('Buscar por manga, autor o categoría...'), findsOneWidget);

    // 5. Cambiar a la pestaña SEGURIDAD (Pestaña 3)
    await tester.tap(find.text('SEGURIDAD'));
    await tester.pumpAndSettle();

    expect(find.textContaining('TODOS'), findsWidgets);
    expect(find.textContaining('REPORTADOS'), findsWidgets);
    expect(find.textContaining('CRÍTICAS'), findsWidgets);
    expect(find.text('COLA DE MODERACIÓN DE COMENTARIOS'), findsOneWidget);

    // 6. Cambiar a la pestaña PERFIL (Pestaña 4)
    await tester.tap(find.text('PERFIL'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL ADMINISTRADOR'), findsOneWidget);
    expect(find.text('ACCESO TOTAL // SUPERADMIN'), findsOneWidget);
    expect(find.text('GUARDAR CAMBIOS EN PERFIL'), findsOneWidget);
    expect(find.text('Cambiar a Modo Lector'), findsOneWidget);

    // 7. Regresar al DASHBOARD
    await tester.tap(find.text('DASHBOARD'));
    await tester.pumpAndSettle();

    expect(find.text('ADMIN DASHBOARD'), findsOneWidget);
  });
}
