extends Node2D

var Player = preload("res://Player.tscn")

var player = null
# Called when the node enters the scene tree for the first time.
func _ready():
	if global.player_data:
		player = Player.instance()
		player.load_data(global.player_data)
		player.connect("player_die", self, "onPlayerDied")
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