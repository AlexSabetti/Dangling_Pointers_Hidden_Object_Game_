extends Node3D

class_name BoatController

@export var isMenuBoat := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if isMenuBoat:
		$cameraController.controls_disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
