extends Node3D

@onready var arms_mesh: MeshInstance3D = $Arms_Mesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal reload


## Meshes
func update_mesh(new_mesh : ArrayMesh):
	arms_mesh.mesh = new_mesh


## Animations
func play_gun_anim(animation_name : String, speed_scale : float = 1):
	animation_player.stop() #Stop any currently playing animation
	
	animation_player.speed_scale = speed_scale #Set animation speed
	animation_player.play(animation_name) #Play set animation

func reload_finished():
	reload.emit()
