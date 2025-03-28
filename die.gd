extends RigidBody3D

@export var face_markers: Array[Marker3D]  # Assign one per face in the editor
@export var face_values: Array[int]        # Match indices to marker directions

func get_upward_face() -> int:
	var highest_y = -INF
	var top_index = 0
	for i in face_markers.size():
		var marker = face_markers[i]
		var y_pos = marker.global_transform.origin.y
		if y_pos > highest_y:
			highest_y = y_pos
			top_index = i
	return face_values[top_index]

func _ready():
	self.connect("sleeping_state_changed", Callable(self, "_on_sleeping_state_changed"))

func _on_sleeping_state_changed():
	if sleeping:
		var result = get_upward_face()
		print("Result:", result)
		var floating_number = preload("res://FloatingNumber.tscn").instantiate()
		floating_number.set_number(result)
		get_tree().current_scene.add_child(floating_number)
