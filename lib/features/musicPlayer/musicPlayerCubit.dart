import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

abstract class MusicPlayerState {}

class MusicPlayerInitial extends MusicPlayerState {}

class MusicPlayerLoading extends MusicPlayerState {}

class MusicPlayerSuccess extends MusicPlayerState {
  final AudioPlayer audioPlayer;
  final Duration audioDuration;

  MusicPlayerSuccess({required this.audioDuration, required this.audioPlayer});
}

class MusicPlayerFailure extends MusicPlayerState {
  final String errorMessage;

  MusicPlayerFailure(this.errorMessage);
}

class MusicPlayerCubit extends Cubit<MusicPlayerState> {
  MusicPlayerCubit() : super(MusicPlayerInitial());

  void initPlayer(String url) async {
    if (state is MusicPlayerSuccess) {
      (state as MusicPlayerSuccess).audioPlayer.dispose();
    }
    emit(MusicPlayerLoading());
    try {
      AudioPlayer audioPlayer = AudioPlayer();
      var result = await audioPlayer.setUrl(url);
      emit(MusicPlayerSuccess(
        audioDuration: result!,
        audioPlayer: audioPlayer,
      ));
    } catch (e) {
      print(e.toString());
      emit(MusicPlayerFailure("Error while plyaing music"));
    }
  }

  @override
  Future<void> close() async {
    if (state is MusicPlayerSuccess) {
      (state as MusicPlayerSuccess).audioPlayer.dispose();
    }
    super.close();
  }
}
