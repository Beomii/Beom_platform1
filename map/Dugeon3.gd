extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.skill_panel.set_player_obj($Player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_gold_updated(unit):
	$HUD.updateGold($Player.gold)


func _on_Player_player_die():
	get_tree().change_scene("res://outro/GameOverScene.tscn")


func _on_Player_hp_updated(unit):
	$HUD.updatePlayerHP($Player.hp, $Player.max_hp)


func _on_TrapSwitch_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		$map_objects/ArrowTrap.execute_trap()
		$map_objects/ArrowTrap3.execute_trap()


func _on_TrapSwitch2_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		$map_objects/ArrowTrap2.execute_trap()
