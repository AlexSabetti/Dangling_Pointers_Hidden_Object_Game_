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


@export_group("Camera Section")
# camera section selector, as of now, 1 is Camera Stern, 2 is Camera Kitchen, 3 is Camera helm, and 4 is Camera Bedroom. Do not select anything at or below 0.
@export cur_cam_sec: int = 1

var signal_manager: SignalBus = Bus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boatRef = get_parent_node_3d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if enableCamWobble:
		keepCam_Upright()
	if Input.is_action_just_pressed("section_back"):
		if(cur_cam_sec - 1 <= 0) change_cam_Section(max_cams)
		else change_cam_section(cur_cam_sec - 1)
	if Input.is_action_just_pressed("section_next"):
		if(cur_cam_sec + 1 > max_cams) change_cam_Section(1)
		else change_cam_section(cur_cam_sec + 1)
		

# smoothly moves the active camera towards staying upright
func keepCam_Upright()-> void:
	var currentCamPivot = get_viewport().get_camera_3d().get_parent_node_3d()
	currentCamPivot.global_rotation = lerp(currentCamPivot.global_rotation, currentCamPivot.global_rotation + (boatRef.rotation * -0.125), 0.01)

# Changes camera sections depending on which id is provided
func change_cam_section(cam_id: int):
	# Send out signal to properly toggle objects
	signal_manager.emit("camera_changed", cam_id)

	# For camera stern
	if(cam_id == 1):
		get_world_3d().environment.set_ambient_light_sky_contribution(1.0)
		Global.waterPlane.visible = true
		cam_Stern.make_current()
		rocking_ambi.volume_db = -5

	# For camera kitchen
	if(cam_id == 2):
		Global.waterPlane.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.8)
		cam_Kitchen.make_current()
		rocking_ambi.volume_db = -80

	# For camera helm
	if(cam_id == 3):
		Global.waterPlane.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.9)
		cam_Helm.make_current()
		rocking_ambi.volume_db = -80

	# For camera bedroom
	if(cam_id == 4):
		Global.waterPlane.visible = false
		get_world_3d().environment.set_ambient_light_sky_contribution(0.25)
		cam_Bedroom.make_current()
		rocking_ambi.volume_db = -80
	
	
