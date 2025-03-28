extends Control

@export var label:Label

var float_speed := 50.0
var fade_time := 1.0
var time_passed := 0.0

func _ready():
	label.modulate.a = 1.0
	# Optional: anchor center of screen
	position = get_viewport_rect().size / 2.0

func _process(delta):
	time_passed += delta

	# Move upward
	position.y -= float_speed * delta

	# Fade out
	var alpha = 1.0 - (time_passed / fade_time)
	label.modulate.a = clamp(alpha, 0.0, 1.0)

	# Remove after fade
	if time_passed >= fade_time:
		queue_free()

func set_number(value):
	label.text = str(value)
