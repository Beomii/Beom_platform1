extends Node2D

var Player = preload("res://Player.tscn")
var Transition = preload("res://transition/Transition.tscn")
var player=null
var player_cam

# Called when the node enters the scene tree for the first time.
func _ready():
	if global.player_data:
		player = Player.instance()
		player.load_data(global.player_data)
		$HUD.updatePlayerHP(player.hp, player.max_hp, false)
		player.connect("player_die", self, "_on_Player_player_die")
		player.connect("hp_updated", self, "_on_Player_hp_updated")
		player.connect("gold_updated", self, "_on_Player_gold_updated")
		add_child(player)
		player.position = $player_spawn_pos.position
		player_cam = Camera2D.new()
		player_cam.limit_left=0
		player_cam.limit_bottom = 600
		player_cam.limit_top = -16
		player_cam.zoom = Vector2(0.5, 0.5)
		player.add_child(player_cam)
		player_cam.current=true
	
	$HUD.skill_panel.set_player_obj(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_gold_updated(unit):
	$HUD.updateGold(player.gold)


func _on_Player_player_die():
	get_tree().change_scene("res://outro/GameOverScene.tscn")


func _on_Player_hp_updated(unit):
	$HUD.updatePlayerHP(player.hp, player.max_hp)


func _on_TrapSwitch_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		$map_objects/ArrowTrap.execute_trap()
		$map_objects/ArrowTrap3.execute_trap()


func _on_TrapSwitch2_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		$map_objects/ArrowTrap2.execute_trap()


func _on_EventArea_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		player.save_data()
		var transition =Transition.instance()
		add_child(transition)
		transition.change("res://map/Dungeon2.tscn",0)
