extends Node

## Sounds
#Player
const DEAD = preload("res://Sound Effects/dead.mp3")
const LANDING = preload("res://Sound Effects/landing.mp3")

#Footsteps
const STONE_FLOOR_1 = preload("res://Sound Effects/Footsteps/stone_floor_1.mp3")
const STONE_FLOOR_2 = preload("res://Sound Effects/Footsteps/stone_floor_2.mp3")
const STONE_FLOOR_3 = preload("res://Sound Effects/Footsteps/stone_floor_3.mp3")

var footstep_stone : Array[AudioStream] = [
	STONE_FLOOR_1,
	STONE_FLOOR_2,
	STONE_FLOOR_3,
]


func play_sfx(sound : AudioStream, parent, distance : int = 0, volume_gain : int = 0):
	var audioplayer : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audioplayer.stream = sound
	audioplayer.max_distance = distance
	audioplayer.volume_db = volume_gain
	audioplayer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	#When sound is done, delete player
	audioplayer.connect("finished", audioplayer.queue_free)
	#Add player to child
	parent.add_child(audioplayer)
	
	#Play sound
	audioplayer.play()
