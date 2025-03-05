extends Control
class_name UIHandler
# reference to the camera controller
var camControllerRef: CameraController

@onready var inGame_UI: VBoxContainer = $Ingame_UI
@onready var taskBar: HBoxContainer = $Ingame_UI/TaskBar
@onready var pauseMenu: VBoxContainer = $PauseMenu
@onready var barPos : Control = $bar_Pos
@onready var FadeToBlack : ColorRect = $FadeToBlack

@onready var rb_container := $Ingame_UI/TaskBar/Panel3/MarginContainer/HBoxContainer/RB_VBoxContainer
@onready var lb_container := $Ingame_UI/TaskBar/Panel3/MarginContainer/HBoxContainer/LB_VBoxContainer
@onready var blurbContainer := $Ingame_UI/TaskBar/MarginContainer/Panel2/MarginContainer/RichTextLabel
@onready var blurbTimer := $BlurbTimer
@onready var settingsMenu := $settings_menu
@onready var FadeTimer : Timer = $FadeTimer

var fadeBlackColor : Color = Color(0.08,0.02,0.04,1.0)
var fadeTransColor : Color = Color(0.08,0.02,0.04,0.0)

# @onready var request_text_a: RichTextLabel = $Ingame_UI/Requests/request_text_a
# @onready var request_text_b: RichTextLabel = $Ingame_UI/Requests/request_text_b
# @onready var request_text_c: RichTextLabel = $Ingame_UI/Requests/request_text_c

var settings_locked: bool = false 
var rng := RandomNumberGenerator.new()

var signal_manager: SignalBus = Bus

var blurb_text: String = ""

# the cam to send player to when left button is pressed
var lb_cam:int
# the cam to send player to when right button is pressed
var rb_cam:int

var isPaused: bool = false
var isTaskBarHidden: bool = false
# var isInMainMenu: bool = false

func _ready():
	Global.gameWon = false
	signal_manager.pause_game.connect(respond_to_pause)
	signal_manager.unpause_game.connect(respond_to_unpause)
	signal_manager.toggle_bar.connect(_on_btn_toggle_bar_pressed)
	pauseMenu.get_node("Resume").pressed.connect(_resume_pressed)
	pauseMenu.get_node("Settings").pressed.connect(_settings_pressed)
	pauseMenu.get_node("Exit").pressed.connect(_exit)
	camControllerRef = $".."
	
	fade_from_black()


func respond_to_pause():
	isPaused = true
	inGame_UI.hide()
	inGame_UI.mouse_filter = Control.MOUSE_FILTER_IGNORE

	pauseMenu.show()
	pauseMenu.mouse_filter = Control.MOUSE_FILTER_STOP

func respond_to_unpause():
	isPaused = false
	inGame_UI.show()
	inGame_UI.mouse_filter = Control.MOUSE_FILTER_PASS
	
	pauseMenu.hide()
	pauseMenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if !settingsMenu.is_hidden:
		settingsMenu.hide_settings_menu()


# This is only to make sure everything reacts to an unpause at the same time
func _resume_pressed():
	signal_manager.emit_signal("unpause_game")

func _settings_pressed():
	settingsMenu.toggle_settings_menu()

func _exit():
	get_tree().quit()

func _update_requests(requests: Array):
	SoundManager2D.PlaySoundQueue2D("SQ_Scribble")
	# Not the optimal way to do this
	print(taskBar.get_node("Requests/MarginContainer/r_box").get_child_count())
	
	# add top most 3 items from request list
	var idx := 0
	for child in taskBar.get_node("Requests/MarginContainer/r_box").get_children():
		var label: RichTextLabel = child
		if idx < requests.size():
			label.text = requests[idx]
		else:
			label.text = " "
		label.fit_content = true
		idx += 1
	
	#var label: RichTextLabel = taskBar.get_node("Requests/MarginContainer/r_box").get_child(0)
	#label.text = requests[0]
	#label.fit_content = true
	
		
	# open taskbar to show new task if it's currently hidden
	if isTaskBarHidden:
		show_bar()

# updates the blurb text in the middle of the task bar
func _update_blurb(blurbText: String):
	blurbContainer.modulate = Color(0.0,0.0,0.0,0.0) # hide container
	blurbContainer.text = "..." # empties out blurb to return scroll bar to top if there was one prior
	blurbTimer.start() # short pause, but when timer is done, updatees blurb
	blurb_text = blurbText

# toggles the taskbar from view
func _on_btn_toggle_bar_pressed() -> void:
	if isTaskBarHidden: # show bar
		show_bar()
	else: # hide bar
		hide_bar()

# Moves the bar on screen
func show_bar():
	SoundManager2D.PlaySoundPool2D("SP_WoodDrawer")
	# tweens between current position and on screen positon relative to the bar_pos node
	var tween = create_tween()
	var pos:Vector2 = Vector2(barPos.position.x, barPos.position.y - 130)
	tween.tween_property(inGame_UI, "position", pos, 0.3).set_trans(Tween.TRANS_SINE)
	isTaskBarHidden = false
	print("showing bar")

# Moves the bar off screen
func hide_bar():
	SoundManager2D.PlaySoundPool2D("SP_WoodDrawer")
	# tweens between current position and off screen positon relative to the bar_pos node
	var tween = create_tween()
	var pos:Vector2 = Vector2(barPos.position.x, barPos.position.y - 33)
	tween.tween_property(inGame_UI, "position", pos, 0.3).set_trans(Tween.TRANS_SINE)
	isTaskBarHidden = true
	print("hiding bar")

# fade to black
func fade_to_black():
	var tween = create_tween()
	tween.tween_property(FadeToBlack, "color", fadeBlackColor, 1.0).set_trans(Tween.TRANS_SINE)

# fade in from black
func fade_from_black():
	var tween = create_tween()
	tween.tween_property(FadeToBlack, "color", fadeTransColor, 1.0).from(fadeBlackColor).set_trans(Tween.TRANS_SINE)

# set status of left button
func set_left_btn(isActive:bool, camNum:int, displayText:String):
	if isActive:
		# activate button
		lb_container.get_node("Btn_Left").disabled = false
		lb_container.get_node("Btn_Left").mouse_filter = MOUSE_FILTER_STOP
		# change text
		lb_container.get_node("TextLabel").text = displayText
		
		# set camera number to use when pressed
		lb_cam = camNum
	else:
		# deactivate button
		lb_container.get_node("Btn_Left").disabled = true
		lb_container.get_node("Btn_Left").mouse_filter = MOUSE_FILTER_IGNORE
		# remove text
		lb_container.get_node("TextLabel").text = ""

# set status of right button
func set_right_btn(isActive:bool, camNum:int, displayText:String):
	if isActive:
		# activate button
		rb_container.get_node("Btn_Right").disabled = false
		rb_container.get_node("Btn_Right").mouse_filter = MOUSE_FILTER_STOP
		# change text
		rb_container.get_node("TextLabel").text = displayText
		
		# set camera number to use when pressed
		rb_cam = camNum
	else:
		# deactivate button
		rb_container.get_node("Btn_Right").disabled = true
		rb_container.get_node("Btn_Right").mouse_filter = MOUSE_FILTER_IGNORE
		# remove text
		rb_container.get_node("TextLabel").text = ""

func show_end_button(show:bool):
	if show:
		$Ingame_UI/MarginContainer/btn_EndGame.mouse_filter = MOUSE_FILTER_STOP
		$Ingame_UI/MarginContainer/btn_EndGame.visible = true
	else:
		$Ingame_UI/MarginContainer/btn_EndGame.mouse_filter = MOUSE_FILTER_IGNORE
		$Ingame_UI/MarginContainer/btn_EndGame.visible = false


# when button is hovered over
func _on_btn_mouse_entered() -> void:
	SoundManager2D.PlaySoundQueue2D("SQ_Tick1")

# when left button is pressed
func _on_btn_left_pressed() -> void:
	if !camControllerRef.controls_disabled and !camControllerRef.isChangingCam and !lb_container.get_node("Btn_Left").disabled:
		SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
		set_left_btn(false, 0, "")
		set_right_btn(false, 0, "")
		camControllerRef.change_room(lb_cam)

# when right button is pressed
func _on_btn_right_pressed() -> void:
	if !camControllerRef.controls_disabled and !camControllerRef.isChangingCam and !rb_container.get_node("Btn_Right").disabled:
		SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
		set_left_btn(false, 0, "")
		set_right_btn(false, 0, "")
		camControllerRef.change_room(rb_cam)

# ends the game
func _on_btn_end_game_pressed() -> void:
	endGame()

# updates blurb when timer is done.
# this is for the purpose of giving the text box enough time to reset the scroll bar to the top.
func _on_blurb_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(blurbContainer, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0).from(Color(0.0,0.0,0.0,0.0))
	blurbContainer.text = blurb_text

func endGame():
	inGame_UI.hide()
	if !settingsMenu.hidden:
		settingsMenu.hide_settings_menu()
	
	var tween = create_tween()
	#FadeTimer.start()
	# fade to black
	tween.tween_property(FadeToBlack, "color", fadeBlackColor, 1.0)
	tween.chain().tween_property($VBoxContainer, "modulate", Color.WHITE, 1.0).from(Color.TRANSPARENT)
	$VBoxContainer/btn_continue.disabled = false
	$FadeToBlack.mouse_filter = MOUSE_FILTER_STOP
	settings_locked = true

func _on_fade_timer_timeout() -> void:
	# change level to game level
	get_tree().change_scene_to_file("res://Scenes/Levels/main_menu_screen.tscn")

func _on_continue_button_pressed() -> void:
	SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
	$VBoxContainer/btn_continue.disabled = true
	var tween = create_tween()
	FadeTimer.start()
	tween.tween_property($VBoxContainer, "modulate", Color.TRANSPARENT, 1.0).from(Color.WHITE)
	
