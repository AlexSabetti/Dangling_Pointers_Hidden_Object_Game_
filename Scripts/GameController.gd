extends Node3D
class_name GameController

@onready var UI = $"../Boat/cameraController/ui_hud"
@export var progress_order: Array = ["logbook", "duck", "photos", "ship keys", "fishing rod", "spyglass", "cassette tape"]
var mouse: Vector2 = Vector2.ZERO
const MAX_DIST = 800

var signal_manager: SignalBus = Bus

var paused: bool = false
func _ready():

	signal_manager.emit_signal("camera_changed", 1)
	UI._update_requests(["- find the " + progress_order[0]])

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if !mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			get_mouse_pos(mouse)

func get_mouse_pos(mouse_loc: Vector2):
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse_loc)
	var end = get_viewport().get_camera_3d().project_position(mouse_loc, MAX_DIST)
	var space_state = get_world_3d().direct_space_state

	var para = PhysicsRayQueryParameters3D.new()
	para.from = start
	para.to = end
	
	var result = space_state.intersect_ray(para)
	if result.size() > 0:
		var obj = result.get("collider")
		if obj is ClickableObject:
			print(obj)
			var click_obj: ClickableObject = obj
			if click_obj.can_interact and click_obj.progress_requirement == 0:
				signal_manager.emit_signal("valid_object_clicked", obj)
				mark_off(click_obj)
	else:
		print("No object clicked")

func mark_off(obj: ClickableObject):
	print("clicked")
	signal_manager.emit_signal("inc_progress")
	progress_order.remove_at(0)
	UI._update_requests(["- find the " + progress_order[0]])
	obj.finish_pickup()

func toggle_pause_menu() -> void:
	if paused:
		paused = false
		signal_manager.emit_signal("unpause_game")
	else:
		paused = true
		signal_manager.emit_signal("pause_game")
