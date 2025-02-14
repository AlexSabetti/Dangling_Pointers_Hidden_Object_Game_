extends Node3D

# controlls the active camera and changing camera position
class_name CameraController

@export var enableCamWobble = true

var boatRef

@onready var cam_Stern= $Pivot_Stern/Camera3D_Stern
@onready var cam_Kitchen = $Pivot_Kitchen/Camera3D_Kitchen
@onready var cam_Helm = $Pivot_Helm/Camera3D_Helm
@onready var cam_Bedroom= $Pivot_Bedroom/Camera3D_Bedroom

@onready var rocking_ambi = $"../BoatRockingAmbience1"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boatRef = get_parent_node_3d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if enableCamWobble:
		keepCam_Upright()
	
	if Input.is_action_pressed("num_1"):
		get_world_3d().environment.set_ambient_light_sky_contribution(1.0)
		Global.waterPlane.visible = true
		cam_Stern.make_current()
		rocking_ambi.volume_db = -5
		
	else: if Input.is_action_pressed("num_2"):
		Global.waterPlane.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.8)
		cam_Kitchen.make_current()
		rocking_ambi.volume_db = -80
		
	else: if Input.is_action_pressed("num_3"):
		Global.waterPlane.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.9)
		cam_Helm.make_current()
		rocking_ambi.volume_db = -80
		
	else: if Input.is_action_pressed("num_4"):
		Global.waterPlane.visible = false
		get_world_3d().environment.set_ambient_light_sky_contribution(0.25)
		cam_Bedroom.make_current()
		rocking_ambi.volume_db = -80
		

# smoothly moves the active camera towards staying upright
func keepCam_Upright()-> void:
	var currentCamPivot = get_viewport().get_camera_3d().get_parent_node_3d()
	currentCamPivot.global_rotation = lerp(currentCamPivot.global_rotation, currentCamPivot.global_rotation + (boatRef.rotation * -0.125), 0.01)
	
