extends Node3D

# controlls the active camera and changing camera position
class_name CameraController

@export var enableCamWobble = true
@export var waterPlaneRef:MeshInstance3D
var boatRef

# default rotation positions
var cam_Stern_rot
var cam_Kitchen_rot
var cam_Helm_rot
var cam_Bedroom_rot

@onready var cam_Stern = $Pivot_Stern/Camera3D_Stern
@onready var cam_Kitchen = $Pivot_Kitchen/Camera3D_Kitchen
@onready var cam_Helm = $Pivot_Helm/Camera3D_Helm
@onready var cam_Bedroom = $Pivot_Bedroom/Camera3D_Bedroom
var max_cams: int = 4
@onready var rocking_ambi = $"../BoatRockingAmbience1"

@onready var UI = $ui_hud
@onready var FadeTimer : Timer = $FadeTimer
var rng := RandomNumberGenerator.new()
# array of possible step sounds
var stepSounds:Array = ["res://Resources/Sounds/SFX/WoodStep1.mp3", "res://Resources/Sounds/SFX/WoodStep2.mp3", "res://Resources/Sounds/SFX/WoodStep3.mp3", "res://Resources/Sounds/SFX/WoodStep4.mp3"]
var isChangingCam:bool = false

# Used for when the pause menu needs to return to the previous camera
var previous_cam_id: int = 1
# Used for camera transions
var target_cam_id: int = 1

@export_group("Camera Section")
# camera section selector, as of now, 1 is Camera Stern, 2 is Camera Kitchen, 3 is Camera helm, and 4 is Camera Bedroom. Do not select anything at or below 0.
@export var cur_cam_sec: int = 1
@export_group("Camera Control Toggles")

# Whether or not the camera controls are disabled at the moment, should start as true so the main menu and / or pause menu isn't interupted
@export var controls_disabled: bool = true


var signal_manager: SignalBus = Bus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# the boat should be it's parent
	boatRef = get_parent_node_3d()
	
	# get default rotations for each camera. used to prevent bug in cammera wobble effect
	cam_Stern_rot = cam_Stern.global_rotation
	cam_Kitchen_rot = cam_Kitchen.global_rotation
	cam_Helm_rot = cam_Helm.global_rotation
	cam_Bedroom_rot = cam_Bedroom.global_rotation

	# Connect to the signal manager
	signal_manager.pause_game.connect(respond_to_pause)
	signal_manager.unpause_game.connect(respond_to_unpause)
	
	# start off unpaused
	signal_manager.unpause_game.emit()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if enableCamWobble:
		keepCam_Upright()
	if Input.is_action_just_pressed("section_back") and !controls_disabled and !isChangingCam: #if Input.is_action_just_pressed("section_back") and !controls_disabled: <- re-add this once you setup the keys in settings
		UI._on_btn_left_pressed()
		#redirect(-1)
		#UI.fade_to_black()
		#FadeTimer.start()
		#playStepSound()
		#isChangingCam = true
	if Input.is_action_just_pressed("section_next") and !controls_disabled and !isChangingCam: #if Input.is_action_just_pressed("section_next") and !controls_disabled: <- re-add this once you setup the keys in settings
		UI._on_btn_right_pressed()
		#redirect(1)
		#UI.fade_to_black()
		#FadeTimer.start()
		#playStepSound()
		#isChangingCam = true
	if Input.is_action_just_pressed("menu"): #if "menu" key is pressed, toggle pause menu
		if UI.isPaused: # if game is already paused, unpause it
			signal_manager.unpause_game.emit()
		else: # if game is currently  unpaused, pause it
			signal_manager.pause_game.emit()
	if Input.is_action_just_pressed("toggle_bar"): #if "menu" key is pressed, toggle pause menu
		signal_manager.toggle_bar.emit()

# smoothly moves the active camera towards staying upright
func keepCam_Upright()-> void:
	var currentCamPivot = get_viewport().get_camera_3d().get_parent_node_3d()
	currentCamPivot.global_rotation = lerp(currentCamPivot.global_rotation, currentCamPivot.global_rotation + (boatRef.rotation * -0.125), 0.01)

# begins moving the player to the give target room
# used mainly just for the ui move buttons
func change_room(target:int):
	UI.fade_to_black()
	FadeTimer.start()
	SoundManager2D.PlaySoundPool2D("SP_WoodSteps")
	isChangingCam = true
	target_cam_id = target


# NOTE: When activating Pause menu it will call this function with the id of -4 to disable all clickables. 

# Changes camera sections depending on which id is provided
func change_cam_section(cam_id: int):
	# Send out signal to properly toggle objects
	signal_manager.camera_changed.emit(cam_id)

	# For camera stern
	if(cam_id == 1):
		get_world_3d().environment.set_ambient_light_sky_contribution(1.0)
		waterPlaneRef.visible = true
		cam_Stern.make_current()
		cam_Stern.global_rotation = cam_Stern_rot
		rocking_ambi.volume_db = -5
		print("cam changed to Stern")
		previous_cam_id = 1
		
		UI.set_left_btn(true, 3, "to helm")
		UI.set_right_btn(true, 2, "to cabin")


	# For camera kitchen
	if(cam_id == 2):
		waterPlaneRef.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.8)
		cam_Kitchen.make_current()
		cam_Kitchen.global_rotation = cam_Kitchen_rot
		rocking_ambi.volume_db = -80
		print("cam changed to Kitchen")
		previous_cam_id = 2
		
		UI.set_left_btn(false, 0, " ")
		UI.set_right_btn(true, 1, "to stern")

	# For camera helm
	if(cam_id == 3):
		waterPlaneRef.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(0.9)
		cam_Helm.make_current()
		cam_Helm.global_rotation = cam_Helm_rot
		rocking_ambi.volume_db = -80
		print("cam changed to Helm")
		previous_cam_id = 3
		
		UI.set_left_btn(true, 1, "to stern")
		UI.set_right_btn(true, 4, "to bunkroom")

	# For camera bedroom
	if(cam_id == 4):
		waterPlaneRef.visible = false
		get_world_3d().environment.set_ambient_light_sky_contribution(0.4)
		cam_Bedroom.make_current()
		cam_Bedroom.global_rotation = cam_Bedroom_rot
		rocking_ambi.volume_db = -80
		print("cam changed to Bedroom")
		previous_cam_id = 4
		
		UI.set_left_btn(false, 0, " ")
		UI.set_right_btn(true, 3, "to helm")
	
	cur_cam_sec = cam_id
	

	# For Pasue menu, basically same as camera Stern, just with disabled controls
	if(cam_id == -4):
		waterPlaneRef.visible = true
		get_world_3d().environment.set_ambient_light_sky_contribution(1.0)
		cam_Stern.make_current()
		cam_Stern.global_rotation = cam_Stern_rot
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
	

func _on_fade_timer_timeout() -> void:
	change_cam_section(target_cam_id)
	UI.fade_from_black()
	isChangingCam = false

func redirect(move: int) -> void:
	if move == 1:
		if cur_cam_sec == 1:
			target_cam_id = 2
		elif cur_cam_sec == 3:
			target_cam_id = 1
		elif cur_cam_sec == 4:
			target_cam_id = 3
	elif move == -1:
		if cur_cam_sec == 1:
			target_cam_id = 3
		elif cur_cam_sec == 2:
			target_cam_id = 1
		elif cur_cam_sec == 3:
			target_cam_id = 4
	
