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


func _on_Player_hp_updated(unit):
	$HUD.updatePlayerHP(unit.hp, unit.max_hp)


func _on_Player_gold_updated(unit):
	$HUD.updateGold(unit.gold)


func _on_fire_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if body.has_method("damaging"):
			body.damaging(null, 10)


func _on_Player_breath_updated(unit):
	$HUD.updatePlayerBreath(unit.breath, unit.MAX_BREATH)
