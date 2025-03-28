extends Node3D

@onready var camera = $Camera3D
var held_die: RigidBody3D = null
var grab_offset: Vector3
var drag_plane_y = 1.0  # The height above ground where the die follows the mouse

var all_dice: Array[RigidBody3D] = []
var grabbed_dice: Array[RigidBody3D] = []
var landed_dice: Dictionary = {}  # die: result
var waiting_for_landing: bool = false

@export var die_scene:PackedScene

func _on_spawn_pressed():
	var die = die_scene.instantiate()
	die.global_transform.origin = Vector3(
		randf_range(-2, 2), 1, randf_range(-2, 2)
	)
	die.die_landed.connect(_on_die_landed)
	get_tree().current_scene.add_child(die)
	all_dice.append(die)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_pickup_die()
		else:
			_release_die()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_pickup_all_dice()
		if !event.pressed:
			_release_all_dice()

func _pickup_all_dice():
	grabbed_dice.clear()
	for die in all_dice:
		grabbed_dice.append(die)

func _process(_delta):
	if held_die:
		_drag_die()

func _try_pickup_die():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100

	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result and result.collider is RigidBody3D:
		held_die = result.collider
		held_die.freeze = true
		grab_offset = result.position - held_die.global_transform.origin


func _drag_die():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100

	var plane = Plane(Vector3.UP, drag_plane_y)
	var intersection = plane.intersects_ray(from, to)
	if intersection != null:
		held_die.global_transform.origin = intersection - grab_offset

func _release_die():
	if held_die:
		held_die.freeze = false
		await get_tree().process_frame
		# Apply random torque (angular velocity)
		var random_torque = Vector3(
			randf_range(-10.0, 10.0),
			randf_range(-10.0, 10.0),
			randf_range(-10.0, 10.0)
		)
		held_die.apply_torque_impulse(random_torque)
		held_die.apply_impulse(Vector3.UP * randf_range(4.0, 6.0))
		held_die = null
		
func _release_all_dice():
	landed_dice.clear()
	waiting_for_landing = true

	for die in grabbed_dice:
		die.freeze = false
		die.global_transform.origin.y += 3
		die.apply_torque_impulse(Vector3(
			randf_range(-50, 50),
			randf_range(-50, 50),
			randf_range(-50, 50)
		))
	grabbed_dice.clear()

func _on_die_landed(die: RigidBody3D, result: int):
	if waiting_for_landing and die in all_dice:
		if not landed_dice.has(die):
			landed_dice[die] = result

		if landed_dice.size() == all_dice.size():
			_show_total_result()
			
func _show_total_result():
	waiting_for_landing = false
	var total = 0
	for result in landed_dice.values():
		total += result

	var floating_number = preload("res://FloatingNumber.tscn").instantiate()
	floating_number.set_number(total)
	get_tree().current_scene.add_child(floating_number)
	
func _on_clear_dice_pressed():
	for die in all_dice:
		if is_instance_valid(die):
			die.queue_free()
	all_dice.clear()
	
func roll_all_dice():
	_pickup_all_dice()
	_release_all_dice()
