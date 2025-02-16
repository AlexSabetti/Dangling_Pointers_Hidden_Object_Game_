extends Node3D

# controlls the active camera and changing camera position
class_name CameraController

@export var enableCamWobble = true

var boatRef

@onready var cam_Stern= $Pivot_Stern/Camera3D_Stern
@onready var cam_Kitchen = $Pivot_Kitchen/Camera3D_Kitchen
@onready var cam_Helm = $Pivot_Helm/Camera3D_Helm
@onready var cam_Bedroom= $Pivot_Bedroom/Camera3D_Bedroom
var max_cams: int = 4
@onready var rocking_ambi = $"../BoatRockingAmbience1"

# Used for when the pause menu needs to return to the previous camera
var previous_cam_id: int = 1

@export_group("Camera Section")
# camera section selector, as of now, 1 is Camera Stern, 2 is Camera Kitchen, 3 is Camera helm, and 4 is Camera Bedroom. Do not select anything at or below 0.
@export var cur_cam_sec: int = 1
@export_group("Camera Control Toggles")

# Whether or not the camera controls are disabled at the moment, should start as true so the main menu and / or pause menu isn't interupted
@export var controls_disabled: bool = true


var signal_manager: SignalBus = Bus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boatRef = get_parent_node_3d()

	# Connect to the signal manager
	signal_manager.connect("pause_game", respond_to_pause())
	signal_manager.connect("unpause_game", respond_to_unpause())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if enableCamWobble:
		keepCam_Upright()
	if Input.is_action_just_pressed("section_back") and !controls_disabled: #if Input.is_action_just_pressed("section_back") and !controls_disabled: <- re-add this once you setup the keys in settings
		if(cur_cam_sec - 1 <= 0): change_cam_section(max_cams)
		else: change_cam_section(cur_cam_sec - 1)
	if Input.is_action_just_pressed("section_next") and !controls_disabled: #if Input.is_action_just_pressed("section_next") and !controls_disabled: <- re-add this once you setup the keys in settings
		if(cur_cam_sec + 1 > max_cams): change_cam_section(1)
		else: change_cam_section(cur_cam_sec + 1)
		

# smoothly moves the active camera towards staying upright
func keepCam_Upright()-> void:
	var currentCamPivot = get_viewport().get_camera_3d().get_parent_node_3d()
	currentCamPivot.global_rotation = lerp(currentCamPivot.global_rotation, currentCamPivot.global_rotation + (boatRef.rotation * -0.125), 0.01)


# NOTE: When activating Pause menu it will call this function with the id of -4 to disable all clickables. 

# Changes camera sections depending on which id is provided
func change_cam_section(cam_id: int):
	# Send out signal to properly toggle objects
	#signal_manager.emit("camera_changed", cam_id) # commented out cuz not finished and was causing crashes

	# For camera stern
	if(cam_id == 1):
		get_world_3d().environment.set_ambient_light_sky_contribution(1.0)
		Global.waterPlane.visible = true
		cam_Stern.make_current()
		rocking_ambi.volume_db = -5
		print("cam changed to Stern")
		previous_cam_id = 1


	# For camera kitchen
	if(cam_id == 2):
		Global.waterPlane.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.8)
		cam_Kitchen.make_current()
		rocking_ambi.volume_db = -80
		print("cam changed to Kitchen")
		previous_cam_id = 2

	# For camera helm
	if(cam_id == 3):
		Global.waterPlane.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.9)
		cam_Helm.make_current()
		rocking_ambi.volume_db = -80
		print("cam changed to Helm")
		previous_cam_id = 3

	# For camera bedroom
	if(cam_id == 4):
		Global.waterPlane.visible = false
		get_world_3d().environment.set_ambient_light_sky_contribution(0.25)
		cam_Bedroom.make_current()
		rocking_ambi.volume_db = -80
		print("cam changed to Bedroom")
    previous_cam_id = 4
    
	cur_cam_sec = cam_id
	

	# For Pasue menu, basically same as camera Stern, just with disabled controls
	if(cam_id == -4):
		get_world_3d().environment.set_ambient_light_sky_contribution(1.0)
		Global.waterPlane.visible = true
		cam_Stern.make_current()
		rocking_ambi.volume_db = -5
		controls_disabled = true


func reenable_controls():
	controls_disabled = false

func disable_controls():
	controls_disabled = true

func respond_to_pause():
	change_cam_section(-4)

func respond_to_unpause():
	change_cam_section(previous_cam_id)
	reenable_controls()
	
