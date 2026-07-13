import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:habivi/data/repositories/user_repository.dart';
import 'package:habivi/domain/services/habit_mood_service.dart';
import 'package:habivi/presentation/providers/mood_provider.dart';
import 'package:habivi/presentation/shared/widgets/racha_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoFuture;
  String _currentVideoAsset = '';
  String _lastSavedMoodState = '';

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _setVideoForMood(String asset) async {
    if (_currentVideoAsset == asset && _videoController != null) {
      return;
    }
 
    _videoController?.dispose();
    _currentVideoAsset = asset;
    _videoController = VideoPlayerController.asset(asset);
    _initializeVideoFuture = _videoController!.initialize().then((_) {
      _videoController!
        ..setLooping(true)
        ..setVolume(0);
      return _videoController!.play();
    });
 
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveMoodState(double moodPercentage) async {
    final moodState = HabitMoodService.getMoodState(moodPercentage);
    if (moodState == _lastSavedMoodState) return;
    _lastSavedMoodState = moodState;

    final userRepo = UserRepository();
    final usuarios = await userRepo.readAll();
    if (usuarios.isEmpty) return;

    final firstKey = usuarios.keys.first;
    final usuario = usuarios.values.first;
    usuario.estadoPersonaje = moodState;
    await userRepo.updateAt(firstKey, usuario);
  }

  @override
  Widget build(BuildContext context) {
    // Watch el provider de mood para que se recargue automáticamente
    final moodAsync = ref.watch(moodPercentageProvider);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Habivi'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
              tooltip: 'Configuración',
            ),
          ],
        ),
        body: Stack(
          children: [
            // === FONDO: video que ocupa TODA la pantalla según el estado de ánimo ===
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: moodAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error: $error',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  data: (moodPercentage) {
                    final videoAsset = HabitMoodService.getMoodVideo(moodPercentage);
                    if (_currentVideoAsset != videoAsset) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _setVideoForMood(videoAsset);
                      });
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _saveMoodState(moodPercentage);
                    });

                    if (_videoController == null || _initializeVideoFuture == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return FutureBuilder<void>(
                      future: _initializeVideoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            _videoController != null &&
                            _videoController!.value.isInitialized) {
                          return SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              clipBehavior: Clip.hardEdge,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          );
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                ),
              ),
            ),

            // === OVERLAY: Barra de energía con rachas encima ===
            moodAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (moodPercentage) {
                final moodColor = HabitMoodService.getMoodColor(moodPercentage);
                final moodPercentInt = (moodPercentage * 100).toInt();
                
                // Extraer el emoji del estado de ánimo (ej: "Feliz 😊" → "😊")
                final moodStateStr = HabitMoodService.getMoodState(moodPercentage);
                final emoji = moodStateStr.isNotEmpty ? moodStateStr.split(' ').last : '😐';

                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // === RACHAS ENCIMA DE LA BARRA ===
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: const RachaIndicator(),
                        ),
                        
                        // Barra de estado compacta
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: moodColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // === EMOJI DEL ESTADO DE IVY (IZQUIERDA) ===
                              Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: moodPercentage,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.1),
                                    valueColor:
                                        AlwaysStoppedAnimation(moodColor),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$moodPercentInt%',
                                style: TextStyle(
                                  color: moodColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
