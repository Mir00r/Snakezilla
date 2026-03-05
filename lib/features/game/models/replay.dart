import 'dart:math';

import '../models/direction.dart';
import '../models/position.dart';

/// A single recorded game event for the replay system.
class ReplayEvent {
  final int tick;
  final String type; // 'move', 'eat', 'boost', 'die', 'kill', 'combo'
  final Map<String, dynamic> data;

  const ReplayEvent({
    required this.tick,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toMap() => {
        'tick': tick,
        'type': type,
        'data': data,
      };

  factory ReplayEvent.fromMap(Map<String, dynamic> map) => ReplayEvent(
        tick: map['tick'] as int,
        type: map['type'] as String,
        data: Map<String, dynamic>.from(map['data'] as Map),
      );
}

/// Holds the full replay data for one game session.
class GameReplay {
  final String id;
  final DateTime dateTime;
  final String gameMode;
  final int finalScore;
  final int maxCombo;
  final int duration; // total ticks
  final List<ReplayEvent> events;
  final int gridWidth;
  final int gridHeight;

  const GameReplay({
    required this.id,
    required this.dateTime,
    required this.gameMode,
    required this.finalScore,
    required this.maxCombo,
    required this.duration,
    required this.events,
    this.gridWidth = 20,
    this.gridHeight = 20,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'gameMode': gameMode,
        'finalScore': finalScore,
        'maxCombo': maxCombo,
        'duration': duration,
        'events': events.map((e) => e.toMap()).toList(),
        'gridWidth': gridWidth,
        'gridHeight': gridHeight,
      };

  factory GameReplay.fromMap(Map<String, dynamic> map) => GameReplay(
        id: map['id'] as String,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            map['dateTime'] as int),
        gameMode: map['gameMode'] as String,
        finalScore: map['finalScore'] as int? ?? 0,
        maxCombo: map['maxCombo'] as int? ?? 0,
        duration: map['duration'] as int? ?? 0,
        events: (map['events'] as List<dynamic>?)
                ?.map((e) =>
                    ReplayEvent.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        gridWidth: map['gridWidth'] as int? ?? 20,
        gridHeight: map['gridHeight'] as int? ?? 20,
      );
}

/// Records game events during play for replay.
class ReplayRecorder {
  final List<ReplayEvent> _events = [];
  int _tick = 0;
  bool _recording = false;

  bool get isRecording => _recording;
  int get currentTick => _tick;
  List<ReplayEvent> get events => List.unmodifiable(_events);

  void start() {
    _events.clear();
    _tick = 0;
    _recording = true;
  }

  void stop() {
    _recording = false;
  }

  void tick() {
    if (_recording) _tick++;
  }

  void recordMove(Direction dir, List<Position> snake) {
    if (!_recording) return;
    _events.add(ReplayEvent(
      tick: _tick,
      type: 'move',
      data: {
        'direction': dir.name,
        'headX': snake.first.x,
        'headY': snake.first.y,
        'length': snake.length,
      },
    ));
  }

  void recordEat(Position pos, int score) {
    if (!_recording) return;
    _events.add(ReplayEvent(
      tick: _tick,
      type: 'eat',
      data: {'x': pos.x, 'y': pos.y, 'score': score},
    ));
  }

  void recordCombo(int comboCount) {
    if (!_recording) return;
    _events.add(ReplayEvent(
      tick: _tick,
      type: 'combo',
      data: {'count': comboCount},
    ));
  }

  void recordBoost(bool start) {
    if (!_recording) return;
    _events.add(ReplayEvent(
      tick: _tick,
      type: 'boost',
      data: {'start': start},
    ));
  }

  void recordKill(String target) {
    if (!_recording) return;
    _events.add(ReplayEvent(
      tick: _tick,
      type: 'kill',
      data: {'target': target},
    ));
  }

  void recordDeath(int finalScore) {
    if (!_recording) return;
    _events.add(ReplayEvent(
      tick: _tick,
      type: 'die',
      data: {'score': finalScore},
    ));
    stop();
  }

  /// Build a complete replay from the recorded events.
  GameReplay buildReplay({
    required String gameMode,
    required int finalScore,
    required int maxCombo,
  }) {
    return GameReplay(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      dateTime: DateTime.now(),
      gameMode: gameMode,
      finalScore: finalScore,
      maxCombo: maxCombo,
      duration: _tick,
      events: List.of(_events),
    );
  }
}
