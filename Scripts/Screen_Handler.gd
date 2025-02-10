class_name Screen_Handler
extends Node3D

var main_cam: Camera3D

func _ready():
	if main_cam == null:
		print("Warning: Camera is not set, defaulting to starter camera\n")
		main_cam = get_node("./Main/MainCam")
		if main_cam == null:
			print("(From ScreenHandler.gd) Error: starter camera not found, will proceed but the script will crash down the line")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	