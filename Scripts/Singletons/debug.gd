extends PanelContainer

@onready var property_container = %VBoxContainer

var frames_per_second: String

func _input(event):
	# Toggles Debug Menu
	if event.is_action_pressed("toggle-debug-menu"):
		visible = !visible

func _ready():
	# Global Reference
	Global.debug = self
	
	# Hides on Load
	visible = false

func _process(delta):
	if visible:
		add_property("   Frames Per Second", "%.2f" % (1.0/delta), 0)

func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false)

	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)

	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
