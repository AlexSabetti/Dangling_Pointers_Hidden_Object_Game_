class_name PosCam
extends Node3D

@export_group("Location Settings")
# A slot of the pos_list takes from the same numbered slot from the rot_list 
@export var pos_list: PackedVector3Array = []
# Make sure the rot_list entries are in the same order as the pos_list
@export var rot_list: PackedVector3Array = []
# Starting section for camera, will default to 0 if chosen section is beyond scope
@export var camera_start_section = 0

@export_group("Camera Settings")
# This is only here for later use, it is currently not used in the script. The node itself does the positioning and rotating, leaving the camera free for bobbing animations if we want to add it later
@export var main_cam: Camera3D

var signal_manager: SignalBus = Bus

func _ready():
	# Check if we bothered to set up the camera
	if main_cam == null:
		print("Warning: Camera is not set, defaulting to starter camera\n")
		# Try and find the main scene's camera
		main_cam = get_node("./Main/MainCam")
		if main_cam == null:
			print("Error: starter camera not found, will proceed but the script will crash down the line")
	# Check if we didn't bother to match up the lists
	if pos_list.size() != rot_list.size():
		print("Error: pos_list and rot_list are not the same size, or are empty, filling in the gaps with 0,0,0 as default\n")
		# Equalize / Fill in the gaps
		while pos_list.size() < rot_list.size() || pos_list.size() < 1:
			pos_list.append(Vector3(0,0,0))
		while rot_list.size() < pos_list.size():
			rot_list.append(Vector3(0,0,0))
		# Make sure the starting section is within scope
		if camera_start_section > pos_list.size() - 1:
			camera_start_section = 0
			print("Error: camera_start_section is beyond the scope, defaulting to 0\n")
		print("Edit complete, pos_list and rot_list are now the same size for runtime's sake, but the behavior will be wrong\n")
	# Set up the node position and rotations
	global_position = pos_list[camera_start_section]
	global_rotation = rot_list[camera_start_section]
	# Connect the signal
	signal_manager.connect("changeing_cam_section", change_cam_section)

# Basic function to change the position of the holder node
func  change_cam_section(section: int) -> void:
	if section < pos_list.size():
		global_position = pos_list[section]
		global_rotation = rot_list[section]
	else:
		print("Error: section is beyond the scope, defaulting to 0\n")
		global_position = pos_list[0]
		global_rotation = rot_list[0]
	
	