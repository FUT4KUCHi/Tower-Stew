extends Node

const main = preload("res://Scenes/Core/main.tscn")

func _ready():
	$VideoStreamPlayer.play()

func _on_video_stream_player_finished():
	var start = main.instantiate()
	add_child(start)
