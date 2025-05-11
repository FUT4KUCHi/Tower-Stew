extends Node3D

@onready var snap_point = $Marker3D
@onready var timer: Timer = $Timer

var player_ref: CharacterBody3D = null
var placed_item = null
var is_processing: bool = false

func _ready():
	add_to_group("SnappingPoints")

func on_item_placed(item: Node3D, player: CharacterBody3D):
	if is_processing or item.item.processed == true:
		print("Processing is either already active or ingredient is already processed.")
		return
		
	placed_item = item
	# Debugging: Log the item groups and the expected group
	print("Item groups: ", item.get_groups().map(str))
	print("Expected group: ", placed_item.item.group)
	
	# placed_item.scale = Vector3(3.0, 3.0, 3.0)
	
	if placed_item.is_in_group("Ingredients"):
		timer.wait_time = placed_item.item.processing_time
		is_processing = true
		player_ref = player
		timer.start()
	
	# Snap player if required by ingredient
	if placed_item.item.requires_player_snap:
		var snap_pos = global_position + Vector3(0, 0, -1)
		print("Snapping player to position: ", snap_pos)
		player_ref.snap_to_position(snap_pos)
	else:
		print("Item does not require chef's attention.")

func _on_timer_timeout():
	print("Timer has finished.")
	if not is_inside_tree():
		print("Snapping point is not inside the tree yet. Returning early.")
		return
		
	if placed_item.item.processed_visual and placed_item.has_method("set_processed"):
		placed_item.set_processed()
	
	if placed_item.item.requires_player_snap and player_ref:
		player_ref.release_from_snap()
	
	is_processing = false
	player_ref = null
	placed_item.item.processed = true
