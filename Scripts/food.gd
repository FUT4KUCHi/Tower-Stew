extends RigidBody3D

@export var item: Ingredient
const SMOKE = preload("res://Scenes/Core/smoke.tscn")
var smoke_instance: GPUParticles3D = null

func _ready():
	add_to_group("Pickupable")
	add_to_group("Ingredients")
	
	var new_visual = item.raw_visual.instantiate()
	smoke_instance = SMOKE.instantiate()
	new_visual.name = "ItemVisual"
	add_child(new_visual)
	add_child(smoke_instance)
	smoke_instance.emitting = false
	
func set_processed():
	var visual_node = get_node("ItemVisual")
	if visual_node:
		visual_node.queue_free()

	var new_visual = item.processed_visual.instantiate()
	new_visual.name = "ItemVisual"
	add_child(new_visual)
	smoke_instance.emitting = true
