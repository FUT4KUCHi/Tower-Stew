extends CharacterBody3D

const movement_speed: float = 3.0
const gravity: float = 9.8

func _ready():
	add_to_group("Customer")

func _physics_process(delta):
	velocity = Vector3.BACK * movement_speed
	velocity.y -= 2 * gravity * delta
	move_and_slide()

func satisfaction():
	queue_free()
