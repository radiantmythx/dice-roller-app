extends RigidBody3D

signal die_landed(die: RigidBody3D, result: int)

@export var face_markers: Array[Marker3D]
@export var face_values: Array[int]

func _ready():
	connect("sleeping_state_changed", _on_sleeping_state_changed)

func _on_sleeping_state_changed():
	if sleeping:
		var result = get_upward_face()
		die_landed.emit(self, result)

func get_upward_face() -> int:
	var highest_y = -INF
	var top_index = 0
	for i in face_markers.size():
		var y = face_markers[i].global_transform.origin.y
		if y > highest_y:
			highest_y = y
			top_index = i
	return face_values[top_index]
