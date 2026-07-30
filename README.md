# 🎯 Habivi

Una aplicación para ayudar a construir hábitos sostenibles y mejorar la productividad con retroalimentación visual y herramientas prácticas.

Resumen
-------
Habivi es una aplicación móvil desarrollada con Flutter que permite a las personas crear y seguir hábitos, registrar sesiones de estudio y gestionar tareas puntuales. La app prioriza una experiencia simple y de baja fricción: añadir o marcar un hábito debe ser rápido, las actualizaciones en la UI suceden de inmediato y los datos se guardan localmente para garantizar resistencia offline.

Qué incluye (visión general)
----------------------------
- Gestión de hábitos: crear, editar, eliminar y marcar como completado.
- Calendario de cumplimiento y visualización de días especiales (p. ej. días de descanso).
- Sistema de rachas (streaks) que mide la constancia con reglas configuradas en la lógica del dominio.
- Barra de energía que refleja el progreso del usuario con límites para evitar recompensas desproporcionadas.
- Productividad: temporizador de enfoque (Pomodoro), registro de sesiones y métodos de estudio.
- Gestión de tareas/pending items para objetivos puntuales.
- Persistencia local con Hive para almacenamiento sencillo y eficiente.

Por qué existe (problema que resuelve)
-------------------------------------
Los estudiantes (y muchas personas en general) tienen dificultad para mantener hábitos a largo plazo por variaciones en su rutina, agotamiento o falta de feedback claro. Habivi busca:

- Reducir la fricción para registrar hábitos (menos pasos → más adherencia).
- Proteger la motivación frente a fallos puntuales (mecanismos explicables como "días de descanso").
- Ofrecer herramientas concretas para enfocarse (temporizador) y revisar progreso (rachas, barras y estadísticas).

Instalación rápida
------------------
Requisitos:
- Flutter SDK 3.0+ instalado
- Git

Clonar e instalar:

```bash
git clone https://github.com/jladinori/habivi.git
cd habivi
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Ejecutar en modo desarrollo (web):

```bash
flutter run -d chrome
```

Estructura principal del código
-------------------------------
- lib/
  - main.dart — arranque y configuración de Hive/ProviderScope.
  - app.dart — router y tema.
  - core/ — utilidades globales (tema, rutas, constantes, inicialización Hive).
  - data/ — modelos (Hive Types), repositorios y acceso a cajas.
  - domain/ — reglas de negocio (servicios: racha, energía, lógica de hábitos).
  - presentation/ — pantallas, providers y widgets reutilizables.

Pantallas clave y flujo de usuario
---------------------------------
- Inicio
  - Resumen del día: racha diaria/ semanal, barra de energía y accesos.
  - Propósito: dar una vista motivadora y accionable cada vez que el usuario abre la app.

- Hábitos
  - Añadir/editar/eliminar hábitos.
  - Marcar completados y ver historial (calendar-like view).
  - Los días de descanso se muestran distintivos y no penalizan la racha.

- Productividad
  - Temporizador de enfoque (Pomodoro) y registro de sesiones.
  - Métodos de estudio y estadísticas rápidas.
  - Preguntas frecuentes / ayuda integrada.

- Pendientes
  - Lista de tareas puntuales con fecha y notas.

- Configuración
  - Ajustes de la app, metas personales y opciones de backup/restauración.

Principales decisiones de diseño (resumen)
-----------------------------------------
- Persistencia local con Hive: simple, rápido y funciona offline. Adecuado para un MVP que prioriza privacidad y control del usuario.
- Separación clara entre presentation / domain / data: facilita pruebas, mantenimiento y extensibilidad.
- Reglas de racha y días de descanso: definidas en servicios de dominio para facilitar cambios sin tocar la UI.
- Límite diario en ganancia de energía: evita saltos abruptos y produce refuerzos más estables.

Cómo usar la aplicación (guía rápida)
------------------------------------
1. Abrir la app → página de Inicio muestra tu estado.
2. Ir a Hábitos → pulsar '+' para crear un hábito: nombre, frecuencia y sección.
3. Marcar hábito cumplido con el checkbox; la UI se actualiza al instante.
4. Usar el temporizador en Productividad para registrar sesiones.
5. Revisar rachas y calendario para ver días protegidos (descanso) y tendencias.

Requisitos y recomendaciones para desarrollo
-------------------------------------------
- Ejecutar `flutter pub run build_runner build` después de cambiar modelos anotados con @HiveType.
- Usar `flutter analyze` y `flutter test` durante el desarrollo para mantener calidad.

Testing y calidad
-----------------
- La lógica central (rachas, cálculo de energía) está implementada en servicios del dominio y es adecuada para cobertura con tests unitarios.
- Recomendación: añadir tests unitarios para racha_service y energy_service para validar escenarios críticos (uso de descanso, reinicio de racha, topes de energía).

Contribuciones y guía rápida para colaboradores
-----------------------------------------------
1. Fork y branch: crea un branch por feature (feature/mi-feature).
2. Mantén commits pequeños y claros.
3. Ejecuta `flutter pub get` y `build_runner` si modificas modelos Hive.
4. Abre un PR con descripción y capturas/screencast de la funcionalidad.

Licencia
--------
Este proyecto es de código abierto; el README no modifica la licencia. Consulta el archivo de licencia en el repositorio (si existe) para condiciones específicas.

Créditos
--------
- Animaciones del personaje Ivi: Angel Palacio
- Página web de Habivi: Angel Palacio
- Apoyo de diseño de Habivi: Angel Palacio

(La sección de créditos se mantiene exactamente como en el proyecto.)

Contacto
--------
Si tienes preguntas o quieres colaborar, abre un issue o contacta al mantenedor del repositorio.

## Créditos

- Animaciones del personaje Ivi: Angel Palacio
- Página web de Habivi: Angel Palacio
- Apoyo de diseño de Habivi: Angel Palacio

---

**Creado con ❤️ para ayudarte a ser mejor cada día.**
