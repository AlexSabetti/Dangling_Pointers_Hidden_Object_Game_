extends Node2D

#class_name SoundManager3D

#singleton
#var Instance:SoundManager3D

var SoundQueuesByName := {}
var SoundPoolsByName := {}

func _ready() -> void:
	SoundQueuesByName = {
		"SQ_Scribble":$SQ_Scribble,
		"SQ_Tick1":$SQ_Tick1,
		"SQ_Tick2":$SQ_Tick2,
	}
	SoundPoolsByName = {
		"SP_RotoryTick":$SP_RotoryTick,
		"SP_WoodSteps":$SP_WoodSteps,
	}
	

func PlaySoundPool2D(soundPoolName:String)->void:
	if SoundPoolsByName[soundPoolName]:
		SoundPoolsByName[soundPoolName].PlayRandomSound()
	else:
		print("Invalid soundPool name")

func PlaySoundQueue2D(soundQueueName:String)->void:
	if SoundQueuesByName[soundQueueName]:
		SoundQueuesByName[soundQueueName].PlaySound()
	else:
		print("Invalid soundQueue name")
