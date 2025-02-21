@tool
extends Node2D

# a collection of sound queues to play from
class_name SoundPool2D

@export_category("Settings")
@export var allowRepeats := false
@export var overrideSoundQueueSettings := false
@export var volumeDBModifier := 1.0
@export var minPitch := 1.0
@export var maxPitch := 1.0
#@export var volumeRange := Vector2(1.0,1.0)

var sounds:Array[SoundQueue2D]
var rng := RandomNumberGenerator.new()
var lastIdx:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# goes through each child of the soundPool
	for child in get_children():
		if child is SoundQueue2D:
			var soundQueue = child as SoundQueue2D
			# overrides SoundQueueSettings to match 
			# those of the soundPool if true.
			if overrideSoundQueueSettings:
				soundQueue.volumeDBModifier = volumeDBModifier
				soundQueue.maxPitch = maxPitch
				soundQueue.minPitch = minPitch
				
			# add soundQueues to sounds array
			sounds.push_back(soundQueue)
		
	update_configuration_warnings()

func _get_configuration_warnings():
	var numSoundQueueChildren := 0
	for child in get_children():
		if child is SoundQueue2D:
			numSoundQueueChildren += 1
		
	
	if numSoundQueueChildren < 2:
		return ["Expected two or more children of type SoundQueue2D."]
	
	return 

# plays a random sound form the soundPool
func PlayRandomSound() -> void:
	var idx
	# do-while loop to avoid the same sound being played twice in a row
	while true:
		idx = rng.randi_range(0, sounds.size() - 1)
		if allowRepeats:
			break
		else: if idx != lastIdx:
			break
	
	lastIdx = idx
	sounds[idx].PlaySound()
	
