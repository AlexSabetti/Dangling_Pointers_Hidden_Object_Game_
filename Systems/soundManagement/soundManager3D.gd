extends Node3D

#class_name SoundManager3D

#singleton
#var Instance:SoundManager3D

var SoundQueuesByName := {}
var SoundPoolsByName := {}

func _ready() -> void:
	SoundQueuesByName = {
		#"BoinkSoundQueue1":$BoinkSoundQueue3D
	}
	SoundPoolsByName = {
		"SP_WoodSteps":$SP_WoodSteps,

	}
	

func PlaySoundPool3D(soundPoolName:String, positon:Vector3)->void:
	if SoundPoolsByName[soundPoolName]:
		SoundPoolsByName[soundPoolName].PlayRandomSoundAt(positon)
	else:
		print("Invalid soundPool name")

func PlaySoundQueue3D(soundQueueName:String, positon:Vector3)->void:
	if SoundQueuesByName[soundQueueName]:
		SoundQueuesByName[soundQueueName].PlaySoundAt(positon)
	else:
		print("Invalid soundQueue name")
