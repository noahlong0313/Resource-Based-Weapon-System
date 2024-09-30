extends CharacterBody3D
class_name Player

#Player Nodes
@onready var head : Node3D = $Head
@onready var hand: Node3D = $Head/Camera3D/Hand
@onready var camera : Camera3D = $Head/Camera3D
@onready var player_arms : Node3D = $Head/Camera3D/Hand/Player_Arms
@onready var audio_listener : AudioListener3D = $Head/Camera3D/AudioListener3D

#Stats
var speed : int = 15
var moving : bool = false
var jump_velocity : int = 15
var dead : bool = false
var health : int = 100
var max_health : int = 100


# Movement Var
#Speed
var can_move : bool = true
const WALK_SPEED : int = 7
const SPRINT_SPEED : int = 12
const FRICTION : float = 5
#Head Bob
const BOB_FREQ : float = 2.0
const BOB_AMP : float = 0.08
var t_bob : float = 0.0
#Footsteps
var can_step : bool = false
var footstep_offset : float = 0.1
var last_step : AudioStream
#Falling
var in_air : bool = false
var fall_start : Vector3
var fall_end : Vector3

#FOV
const WALK_FOV : float = 65.0
const SPRINT_FOV : float = 75.0


## Ready
func _ready():
	#Send global referenve
	Global.PlayerRef = self
	
	#Set Camera and Ears
	camera.current = true
	audio_listener.current = true
	
	#Allow Player to move and capture mouse to game window
	can_move = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#Update and Connect Player UI
	Global.update_hud.emit()


## Input
func _input(event: InputEvent) -> void:
	#Camera follow mouse
	if event is InputEventMouseMotion and Global.check_menus() == false:
		head.rotate_y(-event.relative.x * GameSettings.mouse_sensitivity)
		camera.rotate_x(-event.relative.y * GameSettings.mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))
	
	#Pause Menu
	if event.is_action_pressed("pause"):
		Global.PauseRef.pause_menu()


## Process | On Tick
func _physics_process(delta: float):
	# Add the gravity.
	check_falling()
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 3
	
	if can_move == true and Global.check_menus() == false:
		#Speed / Sprint
		if Input.is_action_pressed("sprint") and moving == true:
			speed = SPRINT_SPEED
			camera.fov = lerp(camera.fov, SPRINT_FOV, delta * 3)
		else:
			speed = WALK_SPEED
			camera.fov = lerp(camera.fov, WALK_FOV, delta * 5)
		
		
		# Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			SoundManager.play_sfx(SoundManager.STONE_FLOOR_1, self, 0, -10)
		
		
		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var direction := (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				moving = true
			else:
				velocity.x = lerp(velocity.x, direction.x * speed, delta * FRICTION)
				velocity.z = lerp(velocity.z, direction.z * speed, delta * FRICTION)
				moving = false
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * FRICTION)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * FRICTION)
	else:
		return
	
	
	#Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	if GameSettings.head_bob == true:
		hand.transform.origin = head_bob(t_bob) / 2 #Head bob on arms only
	else:
		head_bob(t_bob) / 2
	
	#Move Player
	move_and_slide()

func head_bob(time : float):
	var pos : Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 3) * BOB_AMP
	
	footstep(pos)
	
	#Return pos
	return pos

func footstep(pos : Vector3 = Vector3.ZERO):
	#Footstep
	var low_pos = BOB_AMP - footstep_offset
	if pos.y > - low_pos: #Head Bob has reached height, can play new step
		can_step = true
	
	if pos.y < -low_pos and can_step == true: #Head Bob has is not at peak, play new step
		can_step = false
		
		#Get step sound
		var step : AudioStream = SoundManager.footstep_stone.pick_random()
		
		if last_step != null: #Check if step sound is the same as the previous step sound
			if step == last_step: #If it is, pick a new sound that doesn't match
				for s in SoundManager.footstep_stone:
					if s != last_step:
						step = s
		
		#Play sound and store last step
		last_step = step
		SoundManager.play_sfx(step, self, 0, -15)

func check_falling():
	if is_on_floor() == false: #If player is in air, get their falling start pos
		in_air = true
		
		#Get fall start if this is a new fall
		if fall_start == Vector3.ZERO:
			fall_start = global_position
	
	elif is_on_floor() and in_air == true: #Once they reach the ground, calulate fall damage
		in_air = false
		
		#Get fall end if this is a new fall
		if fall_end == Vector3.ZERO:
			fall_end = global_position
		
		SoundManager.play_sfx(SoundManager.STONE_FLOOR_3, self, 0, -10)
		
		get_fall_damage()


## Stats
#Health
func get_fall_damage():
	var fall_distance : float = fall_start.y - fall_end.y / 4
	
	if fall_distance > 15: #If fall is greater than 20m, take damage
		var fall_damage = snappedf(-fall_distance / 3, 1)
		change_health(fall_damage)
		SoundManager.play_sfx(SoundManager.LANDING, self)
	
	#Reset Fall
	fall_start = Vector3.ZERO
	fall_end = Vector3.ZERO

func change_health(value : int):
	health += value
	
	if health <= 0: #If health reaches zero, die
		death()
	elif health > max_health: #Don't go over max health
		health = max_health
	
	Global.update_hud.emit()

func death():
	print("you're dead")
