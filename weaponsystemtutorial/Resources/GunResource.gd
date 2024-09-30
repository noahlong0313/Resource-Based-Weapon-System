extends Resource
class_name Gun

enum GunType {
	MELEE,
	REVOLVER,
	SHOTGUN,
	SMG,
}


@export var type : GunType
@export var ammo : String
@export var mesh : ArrayMesh
@export var cooldown : float = 0.2 #Time in seconds
@export var sway : float = 0.15
@export var automatic : bool = false

@export_category("Sounds")
@export var firing_sounds : Array[AudioStream]
@export var reload_sound : AudioStream
@export var dry_fire_sound : AudioStream = preload("res://Sound Effects/Guns/shot_dry.wav")

@export_category("Bullet Stats")
@export var damage : int
@export var spread : float
@export var max_mag : int
@export var bullet_amt : int = 1
@export var bullet_range : int = 40
