class_name ClickableObject
extends Node3D

@export var object_name: String
# This is for when the player clicks on the item but isn't in the proper section (This would happen usually by accident). It just denies the signal unless it's true.
@export var can_interact: bool = false

var signal_manager: SignalBus = Bus

func _ready():
	set_process_input(true)

func  