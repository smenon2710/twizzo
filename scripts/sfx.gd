extends Node

# Procedurally synthesized SFX — generated once at boot into AudioStreamWAV
# buffers, no external audio files. Consistent with the rest of this
# codebase (every visual is _draw()-code too, zero external assets).

const MIX_RATE: int = 44100

var _pop_stream: AudioStreamWAV
var _shot_stream: AudioStreamWAV
var _win_stream: AudioStreamWAV
var _lose_stream: AudioStreamWAV
var _tap_stream: AudioStreamWAV

func _ready() -> void:
	_pop_stream = _build_pop()
	_shot_stream = _build_shot()
	_win_stream = _build_win()
	_lose_stream = _build_lose()
	_tap_stream = _build_tap()

# ---- public playback API ----

func play_pop(match_size: int = 3) -> void:
	# bigger matches get a slightly lower/beefier pop instead of just louder
	var pitch: float = clampf(1.0 - float(match_size - 3) * 0.035, 0.78, 1.0)
	_play(_pop_stream, pitch, 0.0)

func play_fall() -> void:
	# quieter/duller variant reused for the floating-orb fall-away
	_play(_pop_stream, 0.68, -9.0)

func play_shot() -> void:
	_play(_shot_stream, randf_range(0.96, 1.04), -4.0)

func play_win() -> void:
	_play(_win_stream, 1.0, 0.0)

func play_lose() -> void:
	_play(_lose_stream, 1.0, 0.0)

func play_tap() -> void:
	_play(_tap_stream, randf_range(0.98, 1.02), -6.0)

func _play(stream: AudioStreamWAV, pitch: float, volume_db: float) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

# ---- synthesis helpers ----

# Renders `duration` seconds of mono 16-bit PCM. `freq_fn(t)` gives the
# instantaneous frequency and `amp_fn(t)` the envelope (0..1) at time t.
func _samples(duration: float, freq_fn: Callable, amp_fn: Callable, wave: String = "sine") -> PackedByteArray:
	var frame_count: int = int(MIX_RATE * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(frame_count * 2)
	var phase: float = 0.0
	for i in range(frame_count):
		var t: float = float(i) / MIX_RATE
		var freq: float = freq_fn.call(t)
		phase += TAU * freq / MIX_RATE
		var s: float
		if wave == "square":
			s = 1.0 if sin(phase) >= 0.0 else -1.0
		elif wave == "triangle":
			s = (2.0 / PI) * asin(sin(phase))
		else:
			s = sin(phase)
		var amp: float = amp_fn.call(t)
		var sample: float = clampf(s * amp, -1.0, 1.0)
		data.encode_s16(i * 2, int(sample * 32767.0))
	return data

func _to_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream

func _build_pop() -> AudioStreamWAV:
	var duration: float = 0.14
	var data: PackedByteArray = _samples(duration,
		func(t): return lerp(720.0, 260.0, t / duration),
		func(t): return exp(-t * 16.0),
		"sine")
	return _to_stream(data)

func _build_shot() -> AudioStreamWAV:
	var duration: float = 0.09
	var data: PackedByteArray = _samples(duration,
		func(t): return lerp(320.0, 880.0, t / duration),
		func(t): return exp(-t * 22.0),
		"triangle")
	return _to_stream(data)

func _build_tap() -> AudioStreamWAV:
	var duration: float = 0.05
	var data: PackedByteArray = _samples(duration,
		func(t): return lerp(620.0, 500.0, t / duration),
		func(t): return exp(-t * 42.0),
		"sine")
	return _to_stream(data)

func _build_win() -> AudioStreamWAV:
	# cheerful ascending major arpeggio
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.5]
	var note_dur: float = 0.14
	var data: PackedByteArray = PackedByteArray()
	for freq in notes:
		data.append_array(_samples(note_dur,
			func(_t): return freq,
			func(t): return exp(-t * 7.0),
			"sine"))
	return _to_stream(data)

func _build_lose() -> AudioStreamWAV:
	# two descending low notes — a small "aw" without being harsh
	var notes: Array[float] = [329.63, 246.94]
	var note_dur: float = 0.26
	var data: PackedByteArray = PackedByteArray()
	for freq in notes:
		data.append_array(_samples(note_dur,
			func(_t): return freq,
			func(t): return exp(-t * 6.0),
			"square"))
	return _to_stream(data)
