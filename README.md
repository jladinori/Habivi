# 🎯 **Habivi** - Gestor de Hábitos Inteligente

> **Construye consistencia, mantente motivado y transforma tus hábitos en tu mejor versión**

---

## 📱 ¿Qué es Habivi?

**Habivi** es una aplicación móvil/web innovadora diseñada para ayudarte a **crear, rastrear y mantener hábitos saludables**. Con un personaje dinámico que cambia de estado según tu progreso, recibirás motivación visual constante para mantener la consistencia.

### **Características Principales:**

✅ **Pantalla de Inicio Inteligente**
- Personaje animado que refleja tu estado de ánimo según el cumplimiento de hábitos
- Barra de energía visual que muestra tu progreso
- Navegación rápida a todas las secciones

✅ **Gestión de Hábitos**
- Agregar y eliminar hábitos fácilmente
- Marcar hábitos completados con un solo toque
- Establecer frecuencia semanal (1-7 veces por semana)
- Historial de cumplimiento automático
- Cálculo inteligente del estado según últimos 30 días

✅ **Tareas/Pendientes**
- Crear tareas pendientes con descripción y fechas
- Marcar tareas como completadas
- Historial automático

✅ **Productivity (Métodos de Mejora)**
- **Pomodoro Timer**: Sesiones enfocadas de 25 minutos con alarma
- Alarma sonora cuando se completa el tiempo
- Puntuación de productividad

✅ **Configuración**
- Opción de login para sincronizar datos (próximamente)
- Gestión de preferencias personales

✅ **Persistencia de Datos**
- Toda tu información se guarda localmente en tu dispositivo
- Los datos se guardan automáticamente al marcar hábitos/tareas
- Cierre seguro de datos cuando cierras la app

---

## 🚀 **Instalación y Setup**

### **Prerequisitos:**

Debes tener instalado:
- **Flutter SDK** (versión 3.0.0 o superior)
- **Git**
- **Un editor de código** (VS Code, Android Studio, etc.)

Para verificar tu instalación:
```bash
flutter --version
dart --version
```

### **Paso 1: Clonar el Repositorio**

```bash
git clone https://github.com/tu-usuario/habivi.git
cd habivi
```

### **Paso 2: Instalar Dependencias**

```bash
flutter pub get
```

**Salida esperada:**
```
Resolving dependencies...
Getting packages...
✓ Got dependencies!
32 packages have newer versions incompatible with dependency constraints.
```

### **Paso 3: Generar Archivos Hive (CRÍTICO)**

Habivi usa **Hive** para guardar datos localmente. Debes generar los adaptadores:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Esto genera los archivos `*.g.dart` necesarios para la persistencia de datos.**

**Salida esperada:**
```
[INFO] Building new asset graph completed, took 1234ms
[INFO] Running build...
✓ Cache busted, forcing full code generation
[INFO] Generating build script...
[INFO] Generating output: ...
[INFO] Successfully generated 10 Hive adapters
```

### **Paso 4: Ejecutar en Web (Recomendado para desarrollo)**

```bash
flutter run -d chrome
```

O en debug:
```bash
flutter run -d chrome --debug
```

**La app abrirá en tu navegador Chrome.**

### **Paso 5: Ejecutar en Dispositivo Físico/Emulador**

**Para Android:**
```bash
flutter run -d android
```

**Para iOS:**
```bash
flutter run -d ios
```

**Para verificar dispositivos disponibles:**
```bash
flutter devices
```

---

## 📋 **Verificación de que Hive Funciona Correctamente**

### **Paso 1: Revisar la Consola de Debug**

Cuando inicia la app, deberías ver en la consola:

```
════════════════════════════════════════
🚀 Iniciando Habivi...
════════════════════════════════════════
🔍 Inicializando Hive...
✓ Hive.initFlutter() completado
  ✓ Adaptador Usuario (ID: 0) registrado
  ✓ Adaptador Cuenta (ID: 1) registrado
  ✓ Adaptador Habito (ID: 2) registrado
  ✓ Adaptador Tarea (ID: 4) registrado
  ... (más adaptadores)
✓ Adaptadores registrados
✓ Hive inicializado exitosamente
✓ Base de datos inicializada
════════════════════════════════════════
```

### **Paso 2: Agregar un Hábito y Verificar**

1. Navega a la sección **"Hábitos"**
2. Haz clic en el botón **"+" (Agregar)**
3. Rellena el formulario (Nombre, descripción, aspecto, frecuencia)
4. Presiona **"Agregar"**

**En la consola deberías ver:**
```
🔍 Abriendo caja de hábitos...
✓ Caja de hábitos abierta. Elementos: 0
🔍 Agregando hábito: "Mi Primer Hábito"
✓ Hábito agregado con key: 0
```

### **Paso 3: Marcar Hábito como Completado**

1. En la sección **"Hábitos"**, haz clic en el **check/checkbox** del hábito
2. Deberías ver: `✓ Completaste "Mi Primer Hábito" hoy`

**En la consola:**
```
🔍 Actualizando hábito con key: 0 - "Mi Primer Hábito"
✓ Hábito actualizado exitosamente
```

### **Paso 4: Cerrar y Abrir la App**

1. Cierra completamente la app
2. Abre de nuevo

**Deberías ver:**
- El hábito sigue ahí
- El estado de completado se mantiene
- En la consola: `✓ Leyendo 1 hábitos de la BD`

**Si los datos se pierden, sigue estos pasos de debugging:**

---

## 📊 **Estructura de Datos Guardados**

Habivi guarda automáticamente:

### **Hábitos (`Box: habito`)**
```dart
Habito(
  idHabito: 1,
  nombreHabito: "Ejercicio",
  descripcion: "30 minutos de cardio",
  tipo: "físico|run",           // aspecto|icono
  completadoHoy: true,
  fechaUltimoCompletado: "2024-01-15",
  fechasCompletadas: ["2024-01-13", "2024-01-14", "2024-01-15"],  // Últimos 30 días
  vecesPorSemana: 3,            // Frecuencia esperada
  fechaCreacion: "2024-01-01"
)
```

### **Tareas (`Box: tarea`)**
```dart
Tarea(
  idTarea: 1,
  nombreTarea: "Proyecto importante",
  puntaje: 10,
  fecha: "2024-01-20",
  notas: "Acabar antes de la semana",
  completada: false
)
```

### **Usuario (`Box: usuario`)**
```dart
Usuario(
  nombre: "Juan",
  correo: "juan@example.com",
  energiaMax: 100,
  puntosProductividad: 250,
  estadoPersonaje: "feliz",
  fechaInicio: "2024-01-01"
)
```

---

## 🎯 **Flujo de Uso**

### **Día 1:**
1. Abre Habivi → Ve el personaje neutral
2. Ve a **Hábitos** → Agrega 3-5 hábitos (ejercicio, lectura, meditación, etc.)
3. Marca los que completaste hoy → Energía sube
4. Cierra la app

### **Día 2+:**
1. Abre Habivi → Verás el personaje según tu progreso
2. Si marcaste muchos hábitos ayer → Personaje está **feliz** 😊
3. Si marcaste pocos → Personaje está **frustrado** 😠
4. Usa **Pomodoro** para sesiones de trabajo enfocadas
5. Agrega **tareas** para objetivos específicos
6. Los datos se guardan automáticamente

### **Cálculo de Energía:**
```
Porcentaje de cumplimiento = (Hábitos completados en últimos 30 días) / (Hábitos esperados) × 100

Estado del personaje:
- 80-100% → Feliz 😊
- 60-79%  → Normal 😐
- 40-59%  → Triste 😔
- 20-39%  → Frustrado 😠
- 0-19%   → Sin energía 😴
```

---

## 📂 **Estructura del Proyecto**

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
│   ├── database/             # AppDatabase: centraliza inicialización
│   ├── models/               # Modelos @HiveType + .g.dart
│   └── repositories/         # Acceso a Hive (Singleton pattern)
├── domain/                   # Lógica de negocio sin UI
│   ├── enums/                # CharacterMood, etc.
│   └── services/             # MoodService, HabitMoodService
└── presentation/             # Interfaz de usuario
    ├── shell/                # Navegación inferior (5 pestañas)
    ├── features/             # Pantallas por funcionalidad
    │   ├── home/
    │   ├── habits/
    │   ├── task/
    │   ├── productivity/
    │   ├── settings/
    │   └── auth/
    ├── providers/            # Riverpod providers
    └── shared/widgets/       # Widgets reutilizables
```

### **Pantallas Principales**

| Pantalla | Ruta | Contenido |
|----------|------|----------|
| Inicio | `/home` | Personaje + barra de energía + botones navegación |
| Hábitos | `/habits` | Lista de hábitos, marcar completados, agregar nuevos |
| Productividad | `/productivity` | Pomodoro timer + Métodos de mejora |
| Pendientes | `/tasks` | Gestión de tareas con descripción y fechas |
| Configuración | `/settings` | Preferencias y opción de login |

---

## ⏳ **Roadmap Futuro**

- [ ] **Racha de días** - Mostrar días consecutivos completados
- [ ] **Login y sincronización** - Guardar datos en la nube
- [ ] **Notificaciones** - Recordatorios diarios para hábitos
- [ ] **Estadísticas avanzadas** - Gráficos de progreso por semana/mes
- [ ] **Logros y badges** - Sistema de recompensas
- [ ] **Exportar datos** - Descargar tu historial como PDF

---

## 🛠️ **Troubleshooting Común**

| Problema | Solución |
|----------|----------|
| **La app no inicia** | Ejecuta `flutter pub get` y `flutter pub run build_runner build` |
| **Los datos se pierden** | Verifica que hayas ejecutado `build_runner` y que `flush()` se llamó |
| **Error "Adapter not registered"** | Ejecuta `flutter pub run build_runner build --delete-conflicting-outputs` |
| **Pomodoro no suena** | Verifica que los permisos de audio estén habilitados en el navegador |
| **Personaje no cambia** | Cierra y abre la app, o navega entre pantallas |

---

## 📞 **Verificar**

¿Problemas? Verifica:
1. Que ejecutaste `flutter pub run build_runner build`
2. Que `flutter analyze` no muestra errores
3. Que `flutter build web --release` compila sin errores
4. Que Hive se inicializa en la consola

---

## 📄 **Licencia**

Este proyecto es de código abierto. Siéntete libre de usarlo, modificarlo y distribuirlo.

---

## 🎉 **¡Comienza tu viaje de hábitos hoy!**

Habivi te acompañará en cada paso. Con consistencia, dedicación y el apoyo de tu personaje, **construirás los hábitos que transformarán tu vida**.

**¿Listo para comenzar? 🚀**

```bash
git clone https://github.com/jladinori/habivi.git
cd habivi
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

---

## Créditos

- Animaciones del personaje Ivi: Angel Palacio
- Página web de Habivi: Angel Palacio
- Apoyo de diseño de Habivi: Angel Palacio

---

**Creado con ❤️ para ayudarte a ser mejor cada día.**
