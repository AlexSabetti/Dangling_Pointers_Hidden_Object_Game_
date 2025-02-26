extends Node3D
class_name GameController

@onready var UI = $"../Boat/cameraController/ui_hud"
@export var progress_order: Array = ["logbook", "fishing rod", "polaroid photos", "ship keys", "decoy duck", "spyglass", "boot", "cassette tape", "compass"]


var mouse: Vector2 = Vector2.ZERO
const MAX_DIST = 800

var signal_manager: SignalBus = Bus

var paused: bool = false
func _ready():
	
	signal_manager.emit_signal("camera_changed", 1)
	UI._update_requests(["- find " + progress_order[0], "- find " + progress_order[1], "- find " + progress_order[2]])
	

func _input(event):
	if event.is_action_pressed("ui_cancel") && !UI.settings_locked:
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
			if click_obj.can_interact and click_obj.progress_requirement <= 0:
				signal_manager.emit_signal("valid_object_clicked", obj)
				mark_off(click_obj)
	else:
		print("No object clicked")

# marks the given object as found and removes it from the progress order list
func mark_off(obj: ClickableObject):
	print("clicked")
	signal_manager.emit_signal("inc_progress")
	
	# find index of clicked item in progress order list
	var idx_to_remove :int= -1
	var temp := 0
	for name in progress_order:
		if name == obj.object_name:
			idx_to_remove = temp
			break
		temp += 1
		
	# removes item at given index if found
	if idx_to_remove != -1:
		progress_order.remove_at(idx_to_remove)
		#print("object [" + obj.object_name + "] removed from progress_order list at " + str(idx_to_remove))
		print("progress_order: " + str(progress_order))
	else:
		print("can not find object '" + obj.object_name + "' in progress_order list.")
	
	#progress_order.remove_at(0)
	
	# checks if there's any objects left
	if progress_order.size() > 0:
		# this feels like a weird way to do it, but eh...
		# adds top 3 objects from progress_order array to requests array and updates the requests
		var requests: Array = []
		var count := 0
		for item in progress_order:
			requests.push_back(("- find " + item))
			count += 1
			if count >= 3:
				break
			
		UI._update_requests(requests)
	else: # if no objects are left, win game
		UI._update_requests(["- leave ship"])
		win_game()
		
	obj.finish_pickup()
	# update object blurb to display
	UI._update_blurb(obj.obj_blurb)

func toggle_pause_menu() -> void:
	if paused:
		paused = false
		signal_manager.emit_signal("unpause_game")
	else:
		paused = true
		signal_manager.emit_signal("pause_game")


# function for when the player finds everything
func win_game() -> void:
	print("you found everything.")
	
	Global.gameWon = true
	
