extends Node2D

func _ready():
	pass 

func _process(delta):
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	

func _on_salir_pressed():
	get_tree().quit()
