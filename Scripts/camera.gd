extends Camera3D

@onready var raycast: RayCast3D = $RayCast3D
@onready var player: CharacterBody3D = $"../../Player"
@onready var restaurent: Node3D = $"../../Restaurent"
@onready var camera_pivot = $".."
@onready var camera = $"."

var mouse_position: Vector2
var rotation_speed: float = 0.015
var mouse_sensitivity: float = 0.5


func _input(event):
	# Camera Rotation
	if event is InputEventMouseMotion and Input.is_action_pressed("Right_Mouse_Button") and !raycast.is_colliding():
		camera_pivot.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		
	# Camera Zoom
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if size <= 20: size += 0.2
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if size > 10: size -= 0.2

	Global.debug.add_property("   Camera Rotation", camera_pivot.rotation, 1)
	Global.debug.add_property("   Camera Zoom Sizing", "%.2f" % size, 2)
