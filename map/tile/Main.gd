extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_player_die():
	get_tree().change_scene("res://outro/GameOverScene.tscn")


func _on_MapPortal_execute_portal(portal):
	global.player_data = $Player.save_data()
	get_tree().change_scene("res://map/Map2.tscn")
