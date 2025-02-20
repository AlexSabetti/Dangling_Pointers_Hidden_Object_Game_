class_name ClickableObject
extends Node3D
@export_group("Object Specifics")
@export var object_name: String
@export var obj_id: int
@onready var col_box: CollisionShape3D = $CollisionShape3D
 # For item interaction requirements, like not being interactable until other objects have been picked up
@export var progress_requirement: int = 0

# This is for when the player clicks on the item but isn't in the proper section (This would happen usually by accident). It just denies the signal unless it's true.
@export var can_interact: bool = false

var signal_manager: SignalBus = Bus

func _ready():
	set_process_input(true)
	signal_manager.connect("camera_changed", _activate_in_scene)
	signal_manager.connect("inc_progress", lower_progress_requirement)

func _activate_in_scene(id_to_activate: int):
	if id_to_activate == obj_id:
		can_interact = true
	else:
		can_interact = false

func lower_progress_requirement():
	progress_requirement -= 1

func finish_pickup():
	get_parent().visible = false
	queue_free()
		
