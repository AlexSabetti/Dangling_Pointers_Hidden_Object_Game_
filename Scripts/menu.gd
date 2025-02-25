extends Control

class_name Menu

@onready var FadeToBlack := $FadeToBlack
@onready var FadeTimer := $FadeTimer

var fadeBlackColor : Color = Color(0.08,0.02,0.04,1.0)
var fadeTransColor : Color = Color(0.08,0.02,0.04,0.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# fade in from black
	var tween = create_tween()
	tween.tween_property(FadeToBlack, "color", fadeTransColor, 1.5).from(fadeBlackColor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# starts the game
func startGame() -> void:
	if !$settings_menu.is_hidden:
		$settings_menu.hide_settings_menu()
	
	var tween = create_tween()
	#FadeTimer.start()
	# fade to black
	tween.tween_property(FadeToBlack, "color", fadeBlackColor, 1.0)
	tween.chain().tween_property($VBoxContainer, "modulate", Color.WHITE, 1.0).from(Color.TRANSPARENT)
	$VBoxContainer/btn_continue.disabled = false
	$FadeToBlack.mouse_filter = MOUSE_FILTER_STOP

# toggles the settings menu (if one gets added anyway, this is low priority)
func toggleSettings() -> void:
	$settings_menu.toggle_settings_menu()

# exits and closes the game
func exitGame() -> void:
	# gets current scene tree and quits.
	get_tree().quit()

# Signals

func _on_btn_start_pressed() -> void:
	print("startBtnPressed!")
	SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
	startGame()

func _on_btn_settings_pressed() -> void:
	print("settingsBtnPressed!")
	SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
	toggleSettings()

func _on_btn_exit_pressed() -> void:
	print("exitBtnPressed!")
	SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
	exitGame()


func _on_fade_timer_timeout() -> void:
	# change level to game level
	get_tree().change_scene_to_file("res://Scenes/Levels/level_1.tscn")


func _on_btn_focus_entered() -> void:
	#AudioPlayer.play()
	SoundManager2D.PlaySoundQueue2D("SQ_Tick1")


func _on_continue_button_pressed() -> void:
	SoundManager2D.PlaySoundQueue2D("SQ_Tick2")
	$VBoxContainer/btn_continue.disabled = true
	var tween = create_tween()
	FadeTimer.start()
	tween.tween_property($VBoxContainer, "modulate", Color.TRANSPARENT, 1.0).from(Color.WHITE)
