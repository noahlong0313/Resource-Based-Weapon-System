extends Node

@export var parent : CharacterBody3D
@onready var cooldown_timer: Timer = $CooldownTimer

var current_gun : Gun


func player_ready():
	if parent.name == "Player":
		parent.player_arms.reload.connect(player_reload)


## Shoot
func shoot():
	current_gun = parent.current_gun
	
	if parent.can_shoot == true and parent.current_bullets > 0:
		var valid_bullets : Array[Dictionary] = get_bullet_raycasts()
		
		if current_gun.type != Gun.GunType.MELEE: #Subtract bullets if weapon uses bullets
			parent.current_bullets -= 1
		
		#Cooldown
		parent.can_shoot = false
		cooldown_timer.start(current_gun.cooldown)
		
		#Sound Effect
		SoundManager.play_sfx(current_gun.firing_sounds.pick_random(), parent)
		
		#Player Only
		if parent.name == "Player":
			parent.player_arms.play_gun_anim("recoil", 2)
			Global.update_hud.emit()
		
		#If any bullets hit, do all this stuff
		if valid_bullets.is_empty() == false:
			for b in valid_bullets:
				#Enemy Damage
				if b.hit_target.is_in_group("Enemy"): #Check if is enemy
					b.hit_target.change_health(current_gun.damage * -1) #Hurt / Damage / Kill enemy
				
				#Spawn Decal
				var bullet = Global.BULLET_DECAL.instantiate()
				b.hit_target.add_child(bullet)
				bullet.global_transform.origin = b.collision_point
				
				#Match decal direction to surface normal
				if b.collision_normal == Vector3(0, 1, 0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				elif b.collision_normal == Vector3(0, -1, 0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				else:
					bullet.look_at(b.collision_point+ b.collision_normal, Vector3.DOWN)
				
				#Add to decal counting array
				GameSettings.spawned_decals.append(bullet)
				
				#Check for Decal Amount
				if GameSettings.spawned_decals.size() > GameSettings.max_decals:
					GameSettings.spawned_decals[0].queue_free() #Remove oldest decal from the world
					GameSettings.spawned_decals.remove_at(0) #Remove freed decal from list

func get_bullet_raycasts():
	current_gun = parent.current_gun
	
	var bullet_raycast = parent.bullet_raycast
	var valid_bullets : Array[Dictionary]
	
	for b in current_gun.bullet_amt:
		#Get Spread Amount
		var spread_x : float = randf_range(current_gun.spread * -1, current_gun.spread)
		var spread_y : float = randf_range(current_gun.spread * -1, current_gun.spread)
		
		#Set Spread
		bullet_raycast.target_position = Vector3(spread_x, spread_y, -current_gun.bullet_range)
		
		#Get collided data
		bullet_raycast.force_raycast_update()
		var hit_target = bullet_raycast.get_collider()
		var collision_point = bullet_raycast.get_collision_point()
		var collision_normal = bullet_raycast.get_collision_normal()
		
		#If the bullet hit an object, get it's data
		if hit_target != null: 
			var valid_bullet : Dictionary = {
				"hit_target" : hit_target,
				"collision_point" : collision_point,
				"collision_normal" : collision_normal,
			}
			
			#Add valid bullet data to array
			valid_bullets.append(valid_bullet)
	
	#Send valid bullet data
	return valid_bullets


## Reload
func reload():
	current_gun = parent.current_gun
	
	if current_gun.type != Gun.GunType.MELEE:
		#If mag is missing bullets and player has required bullets
		if parent.current_bullets < current_gun.max_mag:
			parent.can_shoot = false
			parent.is_reloading = true
			
			#Player Only
			if parent.name == "Player":
				if parent.ammo[current_gun.ammo] > 0: #If player has the required ammo
					parent.player_arms.play_gun_anim("reload") #When player reload animation is finished, reload gun (check player_arms.gd)
					SoundManager.play_sfx(current_gun.reload_sound, parent) #Play reload sound
					return
	
	#Allow player to shoot and update the HUD
	parent.can_shoot = true
	parent.is_reloading = false
	Global.update_hud.emit()


func player_reload():
	current_gun = parent.current_gun
	
	#Ammo Var
	var ammo_amt : int = parent.ammo[current_gun.ammo] #Get Player ammo amount for required ammo
	var missing_ammo : int = current_gun.max_mag - parent.current_bullets
	
	match ammo_amt >= current_gun.max_mag: #Check if the player has enough ammo to fill the mag
		true: #Fill Mag
			parent.current_bullets = current_gun.max_mag
			parent.ammo[current_gun.ammo] -= missing_ammo
		false: #Paritially Fill Mag
			parent.current_bullets += parent.ammo[current_gun.ammo]
			parent.ammo[current_gun.ammo] = 0
	
	#Allow player to shoot and update the HUD
	parent.can_shoot = true
	parent.is_reloading = false
	Global.update_hud.emit()


## Cooldown
func _on_cooldown_timer_timeout() -> void:
	parent.can_shoot = true
