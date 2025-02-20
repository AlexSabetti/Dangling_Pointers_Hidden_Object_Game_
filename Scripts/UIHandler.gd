extends Control
class_name UIHandler

@onready var inGame_UI: VBoxContainer = $Ingame_UI
@onready var taskBar: HBoxContainer = $Ingame_UI/TaskBar
@onready var pauseMenu: VBoxContainer = $PauseMenu
@onready var barPos : Control = $bar_Pos

# @onready var request_text_a: RichTextLabel = $Ingame_UI/Requests/request_text_a
# @onready var request_text_b: RichTextLabel = $Ingame_UI/Requests/request_text_b
# @onready var request_text_c: RichTextLabel = $Ingame_UI/Requests/request_text_c


var signal_manager: SignalBus = Bus

var isPaused: bool = false
var isTaskBarHidden: bool = false
# var isInMainMenu: bool = false

func _ready():
	signal_manager.pause_game.connect(respond_to_pause)
	signal_manager.unpause_game.connect(respond_to_unpause)
	pauseMenu.get_node("Resume").pressed.connect(_resume_pressed)
	pauseMenu.get_node("Exit").pressed.connect(_exit)


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
	# Not the optimal way to do this
	print(taskBar.get_node("Requests/r_box").get_child_count())
	for i in range(taskBar.get_node("Requests/r_box").get_child_count()):
		taskBar.get_node("Requests/r_box").get_child(0).queue_free()

	for i in range(requests.size()):
		taskBar.get_node("Requests/r_box").add_child(RichTextLabel.new())
		var label: RichTextLabel = taskBar.get_node("Requests/r_box").get_child(i)
		label.text = requests[i]
		label.fit_content = true
		print(taskBar.get_node("Requests/r_box").get_child(i).text)
		

# toggles the taskbar from view
func _on_btn_toggle_bar_pressed() -> void:
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
