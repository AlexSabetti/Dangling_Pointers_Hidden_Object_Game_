class_name ClickableObject
extends Node3D
@export_group("Object Specifics")
@export var object_name: String
@export var obj_id: int

# This is for when the player clicks on the item but isn't in the proper section (This would happen usually by accident). It just denies the signal unless it's true.
@export var can_interact: bool = false

var signal_manager: SignalBus = Bus

func _ready():
	set_process_input(true)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_interact:
			signal_manager.emit_signal("object_clicked", object_name)

func _activate_in_scene(id_to_activate: int):
	if id_to_activate == obj_id:
		can_interact = true
	else:
		can_interact = false
		
