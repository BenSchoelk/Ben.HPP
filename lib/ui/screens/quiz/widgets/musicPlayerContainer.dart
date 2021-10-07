import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/musicPlayer/musicPlayerCubit.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerContainer extends StatelessWidget {
  const MusicPlayerContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CurrentDurationContainer(),
              Spacer(),
              PlayerControlContainer(),
              Spacer(),
              BlocBuilder<MusicPlayerCubit, MusicPlayerState>(
                bloc: context.read<MusicPlayerCubit>(),
                builder: (context, state) {
                  if (state is MusicPlayerSuccess) {
                    String time = "";

                    final audioDuration = state.audioDuration;
                    if (audioDuration.inHours != 0) {
                      time = "${audioDuration.inHours}:";
                    }
                    if (audioDuration.inMinutes != 0) {
                      time = "$time${audioDuration.inMinutes - (24 * audioDuration.inHours)}:";
                    }
                    if (audioDuration.inSeconds != 0) {
                      time = "$time${audioDuration.inSeconds - (60 * audioDuration.inMinutes)}";
                    }
                    return Text(
                      time,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }
                  return Text(
                    "0:0",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
              ),
            ],
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BufferedDurationContainer(),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CurrentDurationSliderContainer(),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}

class PlayerControlContainer extends StatefulWidget {
  PlayerControlContainer({Key? key}) : super(key: key);

  @override
  _PlayerControlContainerState createState() => _PlayerControlContainerState();
}

class _PlayerControlContainerState extends State<PlayerControlContainer> {
  StreamSubscription<ProcessingState>? _processingStateStreamSubscription;

  late bool _isPlaying = false;
  late bool _isBuffering = false;
  late bool _hasCompleted = false;
  late bool _isLoading = false;

  @override
  void dispose() {
    _processingStateStreamSubscription?.cancel();
    super.dispose();
  }

  void processingStateListener(ProcessingState event) {
    print(event.toString());
    if (event == ProcessingState.ready) {
      //set loading to false once audio loaded
      if (_isLoading) {
        _isLoading = false;
      }
      (context.read<MusicPlayerCubit>().state as MusicPlayerSuccess).audioPlayer.play();
      _isPlaying = true;
      _isBuffering = false;
      _hasCompleted = false;
    } else if (event == ProcessingState.buffering) {
      _isBuffering = true;
    } else if (event == ProcessingState.completed) {
      _hasCompleted = true;
    }

    setState(() {});
  }

  Widget _buildButton({required Function onPressed, required IconData icon}) {
    return IconButton(
        color: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          onPressed();
        },
        icon: Icon(icon));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MusicPlayerCubit, MusicPlayerState>(builder: (context, state) {
      if (state is MusicPlayerInitial || state is MusicPlayerLoading) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      }
      if (state is MusicPlayerFailure) {
        return _buildButton(onPressed: () {}, icon: Icons.error);
      }

      if (_isLoading || _isBuffering) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      }
      if (_hasCompleted) {
        return _buildButton(
            onPressed: () {
              (context.read<MusicPlayerCubit>().state as MusicPlayerSuccess).audioPlayer.seek(Duration.zero);
            },
            icon: Icons.restart_alt);
      }

      if (_isPlaying) {
        return _buildButton(
            onPressed: () {
              (state as MusicPlayerSuccess).audioPlayer.pause();
              setState(() {
                _isPlaying = false;
              });
            },
            icon: Icons.pause);
      }

      return _buildButton(
          onPressed: () {
            (state as MusicPlayerSuccess).audioPlayer.play();
            setState(() {
              _isPlaying = true;
            });
          },
          icon: Icons.play_arrow);
    }, listener: (context, state) {
      if (state is MusicPlayerSuccess) {
        if (!_isLoading) {
          _isLoading = true;
          setState(() {});
        }
        _processingStateStreamSubscription?.cancel();
        _processingStateStreamSubscription = state.audioPlayer.processingStateStream.listen(processingStateListener);
      }
    });
  }
}

class CurrentDurationSliderContainer extends StatefulWidget {
  CurrentDurationSliderContainer({Key? key}) : super(key: key);

  @override
  _CurrentDurationSliderContainerState createState() => _CurrentDurationSliderContainerState();
}

class _CurrentDurationSliderContainerState extends State<CurrentDurationSliderContainer> {
  double currentValue = 0.0;
  double max = 0.0;

  StreamSubscription<Duration>? streamSubscription;

  void currentDurationListener(Duration duration) {
    currentValue = duration.inSeconds.toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerCubit, MusicPlayerState>(
      bloc: context.read<MusicPlayerCubit>(),
      listener: (context, state) {
        if (state is MusicPlayerSuccess) {
          currentValue = 0.0;
          max = state.audioDuration.inSeconds.toDouble();
          streamSubscription?.cancel();
          streamSubscription = state.audioPlayer.positionStream.listen(currentDurationListener);
          setState(() {});
        }
      },
      child: SliderTheme(
        data: Theme.of(context).sliderTheme.copyWith(
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
              trackHeight: 5,
              trackShape: CustomTrackShape(),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 6.5,
              ),
            ),
        child: Container(
          height: 5.0,
          width: MediaQuery.of(context).size.width,
          child: Slider(
              min: 0.0,
              max: max,
              activeColor: Theme.of(context).primaryColor.withOpacity(0.6),
              inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
              value: currentValue,
              thumbColor: Theme.of(context).colorScheme.secondary,
              onChanged: (value) {
                if (context.read<MusicPlayerCubit>().state is MusicPlayerSuccess) {
                  setState(() {
                    currentValue = value;
                  });
                  (context.read<MusicPlayerCubit>().state as MusicPlayerSuccess).audioPlayer.seek(Duration(seconds: value.toInt()));
                }
              }),
        ),
      ),
    );
  }
}

class BufferedDurationContainer extends StatefulWidget {
  BufferedDurationContainer({Key? key}) : super(key: key);

  @override
  _BufferedDurationContainerState createState() => _BufferedDurationContainerState();
}

class _BufferedDurationContainerState extends State<BufferedDurationContainer> {
  late double bufferedPercentage = 0.0;

  StreamSubscription<Duration>? streamSubscription;

  void bufferedDurationListener(Duration duration) {
    if (context.read<MusicPlayerCubit>().state is MusicPlayerSuccess) {
      bufferedPercentage = (duration.inSeconds / ((context.read<MusicPlayerCubit>().state as MusicPlayerSuccess).audioDuration.inSeconds));
      setState(() {});
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerCubit, MusicPlayerState>(
      bloc: context.read<MusicPlayerCubit>(),
      listener: (context, state) {
        if (state is MusicPlayerSuccess) {
          if (bufferedPercentage != 0) {
            bufferedPercentage = 0.0;
            setState(() {});
          }
          streamSubscription?.cancel();

          streamSubscription = state.audioPlayer.bufferedPositionStream.listen(bufferedDurationListener);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * bufferedPercentage,
        height: 5.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.5),
          color: Theme.of(context).primaryColor.withOpacity(0.6),
        ),
      ),
    );
  }
}

class CurrentDurationContainer extends StatefulWidget {
  CurrentDurationContainer({Key? key}) : super(key: key);

  @override
  _CurrentDurationContainerState createState() => _CurrentDurationContainerState();
}

class _CurrentDurationContainerState extends State<CurrentDurationContainer> {
  StreamSubscription<Duration>? currentAudioDurationStreamSubscription;
  late Duration currentDuration = Duration.zero;

  void currentDurationListener(Duration duration) {
    setState(() {
      currentDuration = duration;
    });
  }

  @override
  void dispose() {
    currentAudioDurationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerCubit, MusicPlayerState>(
      bloc: context.read<MusicPlayerCubit>(),
      listener: (context, state) {
        if (state is MusicPlayerSuccess) {
          if (currentDuration.inSeconds != 0) {
            currentDuration = Duration.zero;
            setState(() {});
          }
          currentAudioDurationStreamSubscription?.cancel();
          currentAudioDurationStreamSubscription = state.audioPlayer.positionStream.listen(currentDurationListener);
        }
      },
      child: Text(
        "${currentDuration.inSeconds}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 0,
  }) {
    return Offset(offset.dx, offset.dy) & Size(parentBox.size.width, sliderTheme.trackHeight!);
  } //
}
