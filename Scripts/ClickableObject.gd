class_name ClickableObject
extends Node3D
@export_group("Object Specifics")
# the name of the object
@export var object_name: String
# the room id of the object
@export var obj_id: int
# the text to be displayed upon picking up the object
@export var obj_blurb: String
# the collision box used for the object
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
	if progress_requirement > 0:
		progress_requirement -= 1
	else:
		progress_requirement = 0

func finish_pickup():
	get_parent().visible = false
	queue_free()
		
