# Habivi

App de hábitos para comunidad universitaria. El personaje refleja tu seguimiento de hábitos (animación Rive en fase posterior).

## Estructura del proyecto

```
lib/
├── main.dart                 # Arranque: Hive + ProviderScope
├── app.dart                  # MaterialApp.router y tema oscuro
├── core/                     # Infraestructura global
│   ├── theme/                # Tema oscuro y colores
│   ├── router/               # Rutas (go_router)
│   ├── constants/            # Nombres de cajas Hive
│   └── hive/                 # Inicialización única de Hive
├── data/
│   ├── models/               # Modelos @HiveType + .g.dart
│   └── repositories/         # Acceso a Hive (openBox, CRUD)
├── domain/                   # Lógica de negocio sin UI
│   ├── enums/                # CharacterMood, etc.
│   └── services/             # MoodService (stub)
└── presentation/             # Interfaz de usuario
    ├── shell/                # Navegación inferior (5 pestañas)
    ├── features/             # Pantallas por funcionalidad
    └── shared/widgets/       # Widgets reutilizables
```

### Pantallas (pestañas inferiores)

| Pestaña    | Ruta        | Contenido                          |
|-----------|-------------|------------------------------------|
| Inicio    | `/home`     | Personaje + resumen                |
| Hábitos   | `/habits`   | Lista de hábitos                   |
| Estudio   | `/study`    | Pomodoro y métodos de estudio      |
| Calendario| `/calendar` | Eventos                            |
| Perfil    | `/profile`  | Usuario y ajustes                  |

Ruta adicional: `/notes` (desde Perfil). Detalle de hábito: `/habits/:id`.

## Comandos

```bash
# Dependencias
flutter pub get

# Ejecutar app
flutter run

# Regenerar adaptadores Hive (si cambias modelos)
dart run build_runner build --delete-conflicting-outputs

# Tests
flutter test
```

## Dependencias principales

- **flutter_riverpod** — estado de la app
- **go_router** — navegación multi-pantalla
- **hive / hive_flutter** — base de datos local
- **path_provider** — rutas de almacenamiento

## Próximos pasos

- Lógica real de `MoodService` según `RegistroHabito`
- Integración Rive en `presentation/shared/widgets/rive_character.dart`
- CRUD de hábitos en UI
- Providers Riverpod para repositories
