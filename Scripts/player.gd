extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
const movement_speed: float = 5.00

var next_position: Vector3
var direction: Vector3

func _physics_process(delta):
	nav_agent.target_position = next_position
	direction = nav_agent.get_next_path_position() - global_position
	velocity = direction.normalized() * movement_speed
	
	move_and_slide()

func move_character(collided_position: Vector3):
	next_position = collided_position

func interact():
	pass
