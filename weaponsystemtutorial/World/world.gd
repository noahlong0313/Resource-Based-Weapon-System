extends Node3D

@onready var pause_menu: Control = $CanvasLayer/pause_menu


func _ready() -> void:
	Global.WorldRef = self
