extends Node2D

var Player = preload("res://Player.tscn")

var player = null
# Called when the node enters the scene tree for the first time.
func _ready():
	if global.player_data:
		player = Player.instance()
		player.load_data(global.player_data)
		player.connect("player_die", self, "onPlayerDied")
		player.connect("hp_updated", self, "_on_Player_hp_updated")
		player.connect("gold_updated", self, "_on_Player_gold_updated")
		add_child(player)
		player.position = $Position2D.position
		var player_cam = Camera2D.new()
		player.add_child(player_cam)
		player_cam.current=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func onPlayerDied():
	get_tree().change_scene("res://outro/GameOverScene.tscn")

func _on_Enemy_enemy_die():
	pass # Replace with function body.

func _on_Player_hp_updated(unit):
	$HUD.updatePlayerHP(unit.hp, unit.max_hp)


func _on_Player_gold_updated(unit):
	$HUD.updateGold(unit.gold)