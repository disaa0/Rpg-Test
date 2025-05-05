extends Area2D

@export var speed = 200  
@export var max_distance = 500  

var start_position = Vector2.ZERO
var direccion = Vector2.ZERO  
var daño = 50  

func _ready():
	start_position = position
	connect("body_entered", Callable(self, "_on_body_entered"))  

func _physics_process(delta):
	position += direccion * speed * delta  
	if position.distance_to(start_position) > max_distance:
		queue_free()  

func _on_body_entered(body):
	if body.is_in_group("Enemigo"):  
		body.take_damage(daño)  
		queue_free()

func set_direccion(nueva_direccion: Vector2):
	direccion = nueva_direccion

func set_dano(nuevo_daño: float):
	daño = nuevo_daño
