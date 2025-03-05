extends Control

@export var is_hidden := true
var volume_bus_name := "Master"
var volume_bus_idx: int


@onready var barPos := $bar_Pos
@onready var settings_UI := $settings
@onready var volume_slider := $settings/settings_panel/MarginContainer/VBoxContainer/HBoxContainer/VolumeSlider
@onready var volume_number := $settings/settings_panel/MarginContainer/VBoxContainer/HBoxContainer/VolumeNumber
@onready var brightness_slider := $settings/settings_panel/MarginContainer/VBoxContainer/HBoxContainer2/BrightnessSlider
@onready var brightness_number := $settings/settings_panel/MarginContainer/VBoxContainer/HBoxContainer2/BrightnessNumber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_bus_idx = AudioServer.get_bus_index(volume_bus_name)
	
	AudioServer.set_bus_volume_db(volume_bus_idx, linear_to_db(Global.global_volume))
	volume_slider.value = Global.global_volume
	volume_number.text = str(volume_slider.value * 100) + "%"
	Global.global_world_env.environment.adjustment_brightness = Global.global_brightness
	brightness_slider.value = Global.global_brightness
	brightness_number.text = str(brightness_slider.value * 100) + "%"
	
	if is_hidden:
		settings_UI.set_position(Vector2(barPos.position.x, barPos.position.y + 32))
	else:
		show_settings_menu()

func toggle_settings_menu() -> void:
	if is_hidden:
		show_settings_menu()
		
	else:
		hide_settings_menu()
		

func hide_settings_menu() -> void:
	SoundManager2D.PlaySoundPool2D("SP_WoodDrawer")
	# tweens between current position and off screen positon relative to the bar_pos node
	var tween = create_tween()
	var pos:Vector2 = Vector2(barPos.position.x, barPos.position.y + 32)
	tween.tween_property(settings_UI, "position", pos, 0.3).set_trans(Tween.TRANS_SINE)
	is_hidden = true
	print("hiding settings")
	

func show_settings_menu() -> void:
	SoundManager2D.PlaySoundPool2D("SP_WoodDrawer")
	# tweens between current position and on screen positon relative to the bar_pos node
	var tween = create_tween()
	var pos:Vector2 = Vector2(barPos.position.x, barPos.position.y - 200)
	tween.tween_property(settings_UI, "position", pos, 0.3).set_trans(Tween.TRANS_SINE)
	is_hidden = false
	print("showing settings")
	

func _on_volume_slider_value_changed(value: float) -> void:
	Global.global_volume = value
	AudioServer.set_bus_volume_db(volume_bus_idx, linear_to_db(value))
	volume_number.text = str(value * 100) + "%"
	

func _on_brightness_slider_value_changed(value: float) -> void:
	Global.global_brightness = value
	Global.global_world_env.environment.adjustment_brightness = value
	brightness_number.text = str(value * 100) + "%"

func _on_cam_wobble_check_box_toggled(toggled_on: bool) -> void:
	Global.global_camera_wobble = toggled_on
