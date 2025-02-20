extends Control
class_name UIHandler

@onready var inGame_UI: HBoxContainer = $Ingame_UI
@onready var pauseMenu: VBoxContainer = $PauseMenu

# @onready var request_text_a: RichTextLabel = $Ingame_UI/Requests/request_text_a
# @onready var request_text_b: RichTextLabel = $Ingame_UI/Requests/request_text_b
# @onready var request_text_c: RichTextLabel = $Ingame_UI/Requests/request_text_c


var signal_manager: SignalBus = Bus

var isPaused: bool = false
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
	print(inGame_UI.get_node("Requests/r_box").get_child_count())
	for i in range(inGame_UI.get_node("Requests/r_box").get_child_count()):
		inGame_UI.get_node("Requests/r_box").get_child(0).queue_free()

	for i in range(requests.size()):
		inGame_UI.get_node("Requests/r_box").add_child(RichTextLabel.new())
		var label: RichTextLabel = inGame_UI.get_node("Requests/r_box").get_child(i)
		label.text = requests[i]
		label.fit_content = true
		print(inGame_UI.get_node("Requests/r_box").get_child(i).text)
		

 
