extends Node

## Global Control
#References
var PlayerRef : CharacterBody3D
var WorldRef : Node3D

const BULLET_DECAL = preload("res://Game Objects/Decals/bullet_decal.tscn")

## UI Control
#References
var PauseRef : Control

signal update_hud


## UI
func check_menus():
	if PauseRef.is_open == true:
		return true
	else:
		return false
