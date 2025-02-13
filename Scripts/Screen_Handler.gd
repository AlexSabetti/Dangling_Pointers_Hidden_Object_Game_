class_name Screen_Handler
extends Node3D

var main_cam: Camera3D
var ui: Control

var signal_manager: SignalBus = bus

func _ready():
	if main_cam == null:
		print("Warning: Camera is not set, defaulting to starter camera\n")
		main_cam = get_node("./Main/MainCam")
		if main_cam == null:
			print("(From ScreenHandler.gd) Error: starter camera not found, will proceed but the script will crash down the line")
	if ui == null:
		print("Warning: UI is not set, defaulting to starter UI\n")
		ui = get_node("./Main/MainCam/UI")
		if ui == null:
			print("(From ScreenHandler.gd) Error: starter UI not found, will proceed but the script will crash down the line")
	signal_manager = Bus

			
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("section_back"):
		