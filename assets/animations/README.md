# assets/animations

Carpeta para los GIFs (o videos cortos) que muestra el personaje segun su estado de animo.

## Archivos esperados

Pon aqui exactamente estos archivos (mismo nombre, en minusculas):

| Archivo | Cuando se muestra |
|---|---|
| `feliz.gif` | Cuando el usuario cumplio >= 70% de sus habitos hoy |
| `neutral.gif` | Cuando cumplio entre 30% y 70% |
| `triste.gif` | Cuando cumplio menos del 30% |

## Recomendaciones tecnicas

- **Formato**: GIF animado o WebP animado (mas liviano).
- **Tamaño**: maximo 500x500 px y < 500 KB. GIFs grandes lagean la app.
- **Loop**: el GIF debe estar en bucle (continuous loop) cuando lo exportes.
- **Fondo**: transparente si es posible (no todos los GIFs soportan transparencia bien — si no, usa el color de fondo de la app: `#12151A`).

## Mientras no haya GIFs

Si la carpeta esta vacia, el widget `RiveCharacter` muestra automaticamente un icono de Material como placeholder. NO crashea.

## Como agregar nuevos estados de animo

1. Anadir el caso al enum `lib/domain/enums/character_mood.dart`.
2. Anadir el caso al `switch` en `lib/presentation/shared/widgets/rive_character.dart`.
3. Poner el GIF aqui con el mismo nombre del caso (ej. `emocionado.gif`).
4. Actualizar `lib/domain/services/mood_service.dart` para que pueda devolverlo.
