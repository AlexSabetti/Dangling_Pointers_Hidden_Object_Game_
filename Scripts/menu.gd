extends Control

class_name Menu

@onready var FadeToBlack := $FadeToBlack
@onready var FadeTimer := $FadeTimer
@onready var AudioPlayer := $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# fade in from black
	var tween = create_tween()
	tween.tween_property(FadeToBlack, "color", Color(0.0,0.0,0.0,0.0), 1.5).from(Color.BLACK)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# starts the game
func startGame() -> void:
	var tween = create_tween()
	FadeTimer.start()
	# fade to black
	tween.tween_property(FadeToBlack, "color", Color.BLACK, 1.0).from(Color(0.0,0.0,0.0,0.0))

# toggles the settings menu (if one gets added anyway, this is low priority)
func toggleSettings() -> void:
	pass

# exits and closes the game
func exitGame() -> void:
	# gets current scene tree and quits.
	get_tree().quit()

# Signals

func _on_btn_start_pressed() -> void:
	print("startBtnPressed!")
	startGame()

func _on_btn_settings_pressed() -> void:
	print("settingsBtnPressed!")
	toggleSettings()

func _on_btn_exit_pressed() -> void:
	print("exitBtnPressed!")
	exitGame()


func _on_fade_timer_timeout() -> void:
	# change level to game level
	get_tree().change_scene_to_file("res://Scenes/Levels/level_1.tscn")


func _on_btn_focus_entered() -> void:
	AudioPlayer.play()
