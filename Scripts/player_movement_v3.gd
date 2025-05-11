extends CharacterBody3D

@onready var camera: Camera3D = %Camera3D
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

var speed: float = 5.0
var rotation_speed: float = 0.2
var gravity: float = 9.8
var _last_input_direction = Vector3.ZERO

var held_item: Node3D = null
var nearby_item: Node3D = null

@onready var skin: MeshInstance3D = $MeshInstance3D

func _physics_process(delta):
	Global.debug.add_property("   Position", "(X: " + "%.2f" % position.x + ") (Y: " + "%.2f" % position.y + ")", 4)
	Global.debug.add_property("   Held Item", str(held_item), 5)
	
	
	if Input.is_action_just_pressed("interact"):
		if held_item:
			drop_item()
		else:
			var nearby_item = find_nearby_target("Pickupable", 2.0)
			if nearby_item:
				pickup_item(nearby_item)
			else:
				var nearby_customer = find_nearby_target("Customer", 3.0)
				if nearby_customer:
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

func find_nearby_target(group_name: String, max_distance: float) -> Node3D:
	var closest_node = null
	var shortest_distance = max_distance
	for node in get_tree().get_nodes_in_group(group_name):
		if node == self:
			continue
		var distance = global_position.distance_to(node.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_node = node
	return closest_node

func talk_to_customer(nearby_customer):
	print("Talking with ", nearby_customer.name)

func pickup_item(nearby_item):
	if held_item:
		drop_item()
	
	held_item = nearby_item
	print("Item scale:", held_item.scale, ", Item name: ", held_item.item.name, ", Processed: ", held_item.item.processed)
	
	var saved_global = held_item.global_transform
	var root = held_item.get_parent()
	if root:
		root.remove_child(nearby_item)
	$Hand/Marker3D.add_child(nearby_item)
	held_item.global_transform = saved_global
	
	var grip = held_item.get_node_or_null("Soup/GripPoint")
	if grip:
		held_item.transform = grip.transform
	else:
		held_item.transform.origin = Vector3.ZERO
	
	if held_item is RigidBody3D:
		held_item.freeze = true
		held_item.linear_velocity = Vector3.ZERO
		held_item.angular_velocity = Vector3.ZERO

func drop_item():
	var saved_global = held_item.global_transform
	var nearby_snapping_point = find_nearby_target("SnappingPoints", 2.0)
	if nearby_snapping_point:
		if held_item:
			$Hand/Marker3D.remove_child(held_item)
			nearby_snapping_point.add_child(held_item)
			# held_item.global_transform = $Hand/Marker3D.global_transform
			nearby_snapping_point.on_item_placed(held_item, self)
			held_item.scale = Vector3(2.0, 2.0, 2.0)
			
# 	else: # Overcooked Logic, Probably Not Need it Design Wise.
# 		if held_item is RigidBody3D:
# 			held_item.freeze = false
# 			held_item.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	# held_item.global_transform = saved_global
	

	held_item = null

func snap_to_position(snap_pos):
	print("Chef is paying attention to the dish.")

func release_from_snap():
	print("Chef is done cooking!")
