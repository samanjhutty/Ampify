import 'dart:async';
import 'package:ampify/buisness_logic/player_bloc/player_slider_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/repository/library_repo.dart';
import 'package:ampify/data/repository/music_repo.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/services/getit_instance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:rxdart/transformers.dart';
import 'player_events.dart';

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState.init()) {
    on<PlayerInitial>(_onInit);
    on<PlayerStatusChanged>(_onStateChanged);
    on<PlayerTrackLiked>(_onTrackLiked);
    on<PlayerShuffleToggle>(_shuffleToggle);
    on<PlayerQueueReordered>(_onReorder);
    // on<PlayerRepeatToggle>(_repeatToggle);
    on<PlayerQueueAdded>(_onQueueAdded, transformer: _debounce(duration));
    on<PlayerTrackEnded>(_onTrackEnded, transformer: _debounce(longDuration));
    on<PlayerQueueCleared>(_onQueueCleared);
    on<PlayerTrackChanged>(_onTrackChange);
    on<MusicGroupPlayed>(_onMusicGroup);
  }

  @override
  Future<void> close() {
    player.dispose();
    return super.close();
  }

  @override
  void onChange(Change<PlayerState> change) {
    // dprint('Current: ${change.currentState.toString()}\n'
    //     'Next: ${change.nextState.toString()}');
    super.onChange(change);
  }

  final duration = const Duration(milliseconds: 500);
  final longDuration = const Duration(seconds: 2);
  final player = AudioPlayer();
  final MusicRepo _musicRepo = getIt();
  final LibraryRepo _libRepo = getIt();

  Stream<Duration>? positionStream;
  final queue = ConcatenatingAudioSource(children: []);

  _onInit(PlayerInitial event, Emitter<PlayerState> emit) async {
    await player.setAudioSource(queue);
  }

  void onSliderChange(double value) async {
    final pos = Duration(seconds: value.round());
    await player.seek(pos);
  }

  void onPlayPause() => add(PlayerStatusChanged());

  void onTrackLiked(String id, [bool? liked]) {
    add(PlayerTrackLiked(id, liked: liked));
  }

  void onTrackShare(String id) {}

  void onShuffle() => add(PlayerShuffleToggle());

  void onRepeat() => add(PlayerRepeatToggle());

  void clearQueue() => add(PlayerQueueCleared());

  void onPrevious() {}

  void onNext() {}

  void onTrackEnded(PlayerSliderState slider) {
    if (state.playerState == MusicState.loading) return;
    if (slider.current != 0 && state.length != 0) {
      if (slider.current == state.length) {
        add(PlayerTrackEnded());
      }
    }
  }

  void onQueueReorder(int pr, int cr) {
    add(PlayerQueueReordered(previous: pr, current: cr));
  }

  _createPosition(Duration? duration) {
    positionStream = player.createPositionStream(
      steps: duration?.inSeconds ?? 60,
      maxPeriod: duration ?? const Duration(minutes: 1),
    );
  }

  Future<Duration?> _getDuration() async {
    try {
      final compeleter = Completer<Duration>();
      final stream = player.durationStream.listen((data) {
        if (data == null || data.inSeconds == state.length) return;
        Future.delayed(const Duration(seconds: 5)).then((data) {
          try {
            compeleter.isCompleted;
          } catch (_) {
            return;
          }
          if (!compeleter.isCompleted) throw Exception();
        });
        compeleter.complete(data);
      });
      final duration = await compeleter.future;
      stream.cancel();
      return duration;
    } catch (e) {
      logPrint(e, 'Duration');
      return null;
    }
  }

  // _reset() async {
  //   try {
  //     await _player.stop();
  //     await positionStream?.drain();
  //   } catch (e) {
  //     logPrint('Track reset: $e');
  //   }
  // }

  _onReorder(PlayerQueueReordered event, Emitter<PlayerState> emit) async {
    List<TrackDetails> queueTracks = state.queue;
    final reorderedTrack = queueTracks[event.previous];
    queueTracks.removeAt(event.previous);
    queueTracks.insert(event.current, reorderedTrack);
    emit(state.copyWith(queue: queueTracks));

    try {
      queue.removeRange(player.nextIndex ?? 0, queue.length - 1);
      final track = state.queue.first;
      final artist = track.subtitle?.split(',').first;
      final uri = await _musicRepo.searchSong('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
    } catch (e) {
      logPrint(e, 'Queue next');
    }
  }

  _onStateChanged(PlayerStatusChanged event, Emitter<PlayerState> emit) async {
    switch (state.playerState) {
      case MusicState.pause:
        emit(state.copyWith(playerState: MusicState.playing));
        await player.play();
        break;
      case MusicState.playing:
        emit(state.copyWith(playerState: MusicState.pause));
        await player.pause();
        break;
      default:
        return;
    }
  }

  _onTrackLiked(PlayerTrackLiked event, Emitter<PlayerState> emit) async {
    if (event.liked ?? false) {
      try {
        emit(state.copyWith(liked: false));
        final result = await _libRepo.removefromLikedSongs(event.id);
        if (!result) throw Exception();
      } catch (e) {
        emit(state.copyWith(liked: true));
      }
      return;
    }
    try {
      if (state.track.id == event.id) {
        emit(state.copyWith(liked: true));
      }
      final result = await _libRepo.addtoLikedSongs(event.id);
      if (!result) throw Exception();
    } catch (_) {
      if (state.track.id == event.id) {
        emit(state.copyWith(liked: false));
      }
    }
  }

  _shuffleToggle(PlayerShuffleToggle event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(shuffle: !state.shuffle));
    // await player.setShuffleModeEnabled(!state.shuffle);
  }

  // _repeatToggle(PlayerRepeatToggle event, Emitter<PlayerState> emit) async {
  //   switch (player.loopMode) {
  //     case LoopMode.one:
  //       emit(state.copyWith(loopMode: MusicLoopMode.all));
  //       await player.setLoopMode(LoopMode.all);
  //       break;
  //     case LoopMode.all:
  //       emit(state.copyWith(loopMode: MusicLoopMode.off));
  //       await player.setLoopMode(LoopMode.off);
  //       break;

  //     default:
  //       emit(state.copyWith(loopMode: MusicLoopMode.once));
  //       await player.setLoopMode(LoopMode.one);
  //       break;
  //   }
  // }

  _onQueueAdded(PlayerQueueAdded event, Emitter<PlayerState> emit) async {
    try {
      if (!(state.showPlayer ?? false)) {
        showToast(StringRes.noQueue);
        return;
      }
      showToast(StringRes.queueAdded);
      final track = await Utils.getTrackDetails(event.track);
      emit(state.copyWith(queue: [...state.queue, track]));
      if (state.upNext.isNotEmpty) {
        await queue.removeRange(player.nextIndex ?? 0, queue.length - 1);
      }
      if (player.hasNext) return;
      logPrint('song added instaneously...');
      final artist = track.subtitle?.split(',').first;
      final uri = await _musicRepo.searchSong('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
    } catch (e) {
      logPrint(e, 'Queue instaneous');
    }
  }

  _onTrackEnded(PlayerTrackEnded event, Emitter<PlayerState> emit) async {
    if (state.queue.isEmpty && state.upNext.isEmpty) {
      logPrint('empty queue...');
      emit(state.copyWith(playerState: MusicState.pause, showPlayer: false));
      return;
    }
    emit(state.copyWith(playerState: MusicState.loading));
    TrackDetails? track;
    if (state.queue.isNotEmpty) {
      track = state.queue.first;
      logPrint(track.title, 'next from queue');
      try {
        final newQueue = state.queue.skip(1).toList();
        emit(state.copyWith(
            track: track, queue: newQueue, length: 0, durationLoading: true));
        final duration = await _getDuration();
        _createPosition(duration);
        emit(state.copyWith(
            playerState: MusicState.playing,
            length: duration?.inSeconds ?? 0,
            durationLoading: false));
      } catch (e) {
        emit(state.copyWith(playerState: MusicState.pause));
        logPrint(e, 'Duration');
      }

      if (state.queue.isEmpty) {
        if (state.upNext.isEmpty) return;
        track = state.upNext.first;
      } else {
        track = state.queue.first;
      }

      final artist = track.subtitle?.split(',').first;
      try {
        final uri = await _musicRepo.searchSong('${track.title} $artist');
        final source = AudioSource.uri(uri!);
        await queue.add(source);
      } catch (e) {
        logPrint(e, 'Queue next');
      }
      return;
    }
    try {
      track = state.upNext.first;
    } catch (e) {
      return;
    }
    try {
      final upNext = state.upNext.skip(1).toList();
      emit(state.copyWith(
          track: track, upNext: upNext, length: 0, durationLoading: true));
      final duration = await _getDuration();
      _createPosition(duration);
      emit(state.copyWith(
          playerState: MusicState.playing,
          length: duration?.inSeconds ?? 0,
          durationLoading: false));
    } catch (e) {
      emit(state.copyWith(playerState: MusicState.pause));
      logPrint(e, 'Duration');
    }
    if (state.upNext.isEmpty) return;
    track = state.upNext.first;
    final artist = track.subtitle?.split(',').first;
    try {
      final uri = await _musicRepo.searchSong('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
    } catch (e) {
      logPrint(e, 'Up next');
    }
  }

  void _onQueueCleared(PlayerQueueCleared event, Emitter<PlayerState> emit) {
    try {
      queue.removeRange(player.nextIndex ?? 0, queue.length - 1);
    } catch (e) {
      logPrint(e, 'Queue clear');
    }
    emit(state.copyWith(queue: []));
  }

  _onMusicGroup(MusicGroupPlayed event, Emitter<PlayerState> emit) async {
    player.pause();
    final track = await Utils.getTrackDetails(event.tracks.first);
    emit(state.copyWith(
        musicGroupId: event.id,
        track: track,
        length: 0,
        liked: event.liked,
        showPlayer: true,
        playerState: MusicState.loading));
    await queue.clear();
    List<TrackDetails> upNext = [];
    event.tracks.skip(1).forEach((e) async {
      final details = await Utils.getTrackDetails(e);
      upNext.add(details);
    });

    emit(state.copyWith(queue: [], upNext: upNext));
  }

  _onTrackChange(PlayerTrackChanged event, Emitter<PlayerState> emit) async {
    player.pause();
    final track = await Utils.getTrackDetails(event.track);
    emit(state.copyWith(
        track: track,
        length: 0,
        liked: event.liked,
        showPlayer: true,
        playerState: MusicState.loading));
    try {
      await queue.clear();
      emit(state.copyWith(queue: []));
      final artist = track.subtitle?.split(',').first;
      final uri = await _musicRepo.searchSong('${track.title} $artist');
      final source = AudioSource.uri(uri!);
      await queue.add(source);
      final duration = await _getDuration();
      _createPosition(duration);
      emit(state.copyWith(
        playerState: MusicState.playing,
        length: duration?.inSeconds ?? 0,
      ));
      await player.play();
    } catch (e) {
      logPrint(e, 'Track Change');
      showToast(StringRes.somethingWrong);
      emit(state.copyWith(playerState: MusicState.pause));
    }
  }
}
