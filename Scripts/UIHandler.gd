extends Control
class_name UIHandler

@onready var inGame_UI: VBoxContainer = $Ingame_UI
@onready var taskBar: HBoxContainer = $Ingame_UI/TaskBar
@onready var pauseMenu: VBoxContainer = $PauseMenu
@onready var barPos : Control = $bar_Pos
@onready var UI_SFX : AudioStreamPlayer2D = $UI_SFX
@onready var UI_SFX2 : AudioStreamPlayer2D = $UI_SFX2
@onready var FadeToBlack : ColorRect = $FadeToBlack

var fadeBlackColor : Color = Color(0.08,0.02,0.04,1.0)
var fadeTransColor : Color = Color(0.08,0.02,0.04,0.0)

# @onready var request_text_a: RichTextLabel = $Ingame_UI/Requests/request_text_a
# @onready var request_text_b: RichTextLabel = $Ingame_UI/Requests/request_text_b
# @onready var request_text_c: RichTextLabel = $Ingame_UI/Requests/request_text_c

var rng := RandomNumberGenerator.new()

var signal_manager: SignalBus = Bus

var isPaused: bool = false
var isTaskBarHidden: bool = false
# var isInMainMenu: bool = false

func _ready():
	signal_manager.pause_game.connect(respond_to_pause)
	signal_manager.unpause_game.connect(respond_to_unpause)
	pauseMenu.get_node("Resume").pressed.connect(_resume_pressed)
	pauseMenu.get_node("Exit").pressed.connect(_exit)
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


# This is only to make sure everything reacts to an unpause at the same time
func _resume_pressed():
	signal_manager.emit_signal("unpause_game")

func _exit():
	get_tree().quit()

func _update_requests(requests: Array):
	UI_SFX.pitch_scale = rng.randf_range(0.9, 1.15)
	UI_SFX.play()
	# Not the optimal way to do this
	print(taskBar.get_node("Requests/r_box").get_child_count())

	var label: RichTextLabel = taskBar.get_node("Requests/r_box").get_child(0)
	label.text = requests[0]
	label.fit_content = true
	
		
	# open taskbar to show new task if it's currently hidden
	if isTaskBarHidden:
		show_bar()

# toggles the taskbar from view
func _on_btn_toggle_bar_pressed() -> void:
	UI_SFX2.play()
	if isTaskBarHidden: # show bar
		show_bar()
	else: # hide bar
		hide_bar()

# Moves the bar on screen
func show_bar():
	# tweens between current position and on screen positon relative to the bar_pos node
	var tween = create_tween()
	var pos:Vector2 = Vector2(barPos.position.x, barPos.position.y - 121)
	tween.tween_property(inGame_UI, "position", pos, 0.2).set_trans(Tween.TRANS_SINE)
	isTaskBarHidden = false
	print("showing bar")

# Moves the bar off screen
func hide_bar():
	# tweens between current position and off screen positon relative to the bar_pos node
	var tween = create_tween()
	var pos:Vector2 = Vector2(barPos.position.x, barPos.position.y - 33)
	tween.tween_property(inGame_UI, "position", pos, 0.2).set_trans(Tween.TRANS_SINE)
	isTaskBarHidden = true
	print("hiding bar")

# fade to black
func fade_to_black():
	var tween = create_tween()
	tween.tween_property(FadeToBlack, "color", fadeBlackColor, 1.0).from(fadeTransColor).set_trans(Tween.TRANS_SINE)

# fade in from black
func fade_from_black():
	var tween = create_tween()
	tween.tween_property(FadeToBlack, "color", fadeTransColor, 1.0).from(fadeBlackColor).set_trans(Tween.TRANS_SINE)

# when button is hovered over
func _on_btn_mouse_entered() -> void:
	UI_SFX2.play()
