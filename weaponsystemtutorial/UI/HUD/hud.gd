extends Control

@onready var ammo_count_label: Label = $AmmoCount_Label
@onready var health_count_label: Label = $HealthCount_Label


func _ready() -> void:
	Global.update_hud.connect(_on_update_hud)


func _on_update_hud():
	var player : Player = Global.PlayerRef
	
	#Ammo count visibility
	if player.current_gun.type == Gun.GunType.MELEE:
		ammo_count_label.visible = false
	else:
		ammo_count_label.visible = true
	
	
	#Set Labels
	ammo_count_label.text = "%s / %s" % [player.current_bullets, player.ammo[player.current_gun.ammo]]
