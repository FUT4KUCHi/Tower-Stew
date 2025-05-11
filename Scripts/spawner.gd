extends Node3D

const CUSTOMER = preload("res://Scenes/Core/customer.tscn")
var customers: int = 0

func _on_timer_timeout():
	if customers <= 4:
		var newCustomer = CUSTOMER.instantiate()
		get_parent().add_child(newCustomer)
		newCustomer.global_position = global_position

func _on_area_3d_body_entered(body):
	if body.is_in_group("Customer"):
		# print("Customer has entered.")
		customers += 1
