extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@export var damage: int = 50 

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	if animation_player:
		animation_player.connect("animation_finished", Callable(self, "_on_animacion_terminada"))

func configurar_ataque(posicion, direccion,fuerza):
	position = posicion + (direccion * 10)  
	damage+=(fuerza/2)
	if direccion == Vector2.UP:
		rotation_degrees = 0
	elif direccion == Vector2.DOWN:
		rotation_degrees = 180
	elif direccion == Vector2.LEFT:
		rotation_degrees = -90
	elif direccion == Vector2.RIGHT:
		rotation_degrees = 90

	reproducir_animacion()

func reproducir_animacion():
	if animation_player:
		animation_player.play("Golpe de hacha")
	else:
		print("ERROR: AnimationPlayer no encontrado en Hacha de Acero.")

func _on_animacion_terminada(_anim_name):
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Enemigo"):
		if body.has_method("take_damage"):
			body.take_damage(damage)  
		queue_free()  
