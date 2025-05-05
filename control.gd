extends Control

@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioStreamPlayer2D

func iniciar_creditos():
	animation_player.play("Creditines")

func _ready():
	iniciar_creditos()
	audio_player.play()

	audio_player.connect("finished", _on_audio_finished)

func _on_audio_finished():
	get_tree().quit()
	
