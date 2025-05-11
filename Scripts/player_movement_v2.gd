extends CharacterBody3D

@onready var skin: MeshInstance3D = $MeshInstance3D
var _last_input_direction = Vector3.ZERO

@export var speed: float = 5.0
@export var camera: Camera3D
@export var navigation_agent : NavigationAgent3D

var rotation_speed: float = 0.2
var gravity: float = 9.8

var nearby_customer: CharacterBody3D = null
var nearby_pickup: Node3D = null
var held_item: Node3D = null

func _physics_process(delta):
	if Input.is_action_just_pressed("interact"):
		if held_item:
			drop_item()
		elif nearby_pickup:
			pickup_item(nearby_pickup)
		elif nearby_customer:
			talk_to_customer(nearby_customer)
			
	if (navigation_agent.is_navigation_finished()):
		return
	move_to_point(delta, speed)
	
	velocity.y -= gravity * delta
	move_and_slide()
	
func _input(event: InputEvent):
	if Input.is_action_just_pressed("Left_Mouse_Button"):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var mouse_pos = get_viewport().get_mouse_position();
		var ray_length = 100000
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from;
		ray_query.to = to;
		var result = space.intersect_ray(ray_query);
		if result:
			navigation_agent.target_position = result.position
			look_at_path(result.position)
		else:
			return
		# print(result)

func move_to_point(delta, speed):
	var target_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	
	if direction.length() > 0.2:
		_last_input_direction = direction.normalized()
	var target_angle := Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	skin.global_rotation.y = lerp_angle(skin.rotation.y, target_angle, rotation_speed * delta)

func look_at_path(direction : Vector3):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_area_3d_body_entered(body):
	print(body)
	if body.is_in_group("Customer"):
		nearby_customer = body
	if body.is_in_group("Pickupable"):
		nearby_pickup = body

func _on_area_3d_body_exited(body):
	if body == nearby_pickup:
		nearby_pickup = null
	elif body == nearby_customer:
		nearby_customer = null

func pickup_item(item: Node3D):
	if held_item:
		drop_item()
	
	held_item = item
	nearby_pickup = null
	var saved_global = item.global_transform
	
	var root = item.get_parent()
	if root:
		root.remove_child(item)
	print("Item scale:", item.scale)
	$Hand/Marker3D.add_child(item)
	item.global_transform = saved_global
	
	var grip = item.get_node_or_null("Soup/GripPoint")
	if grip:
		print("Snapped.")
		item.transform = grip.transform
	else:
		item.transform.origin = Vector3.ZERO
	
	if item is RigidBody3D:
		item.freeze = true
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
	
func drop_item():
	if held_item:
		var world = get_tree().current_scene
		$Hand/Marker3D.remove_child(held_item)
		world.add_child(held_item)
		
		held_item.global_transform = $Hand/Marker3D.global_transform
		if held_item is RigidBody3D:
			held_item.freeze = false
			held_item.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		
		held_item = null

func talk_to_customer(nearby_customer):
	print("Talking with a Customer.")
