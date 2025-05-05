extends CharacterBody2D

@onready var estadisticas = $Estadisticas
@export var speed: float = 50.0  
@export var distancia_ataque: float = 30.0  
@export var tiempo_entre_ataques: float = 1.5  
var stats = [200, 10, 10, 20, 4, 6, 3, 10, 8, 3, 15, 18]
@export var damage_text_scene: PackedScene = preload("res://dañito_flotante_uw_u.tscn")
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D  
@onready var area_ataque = $AreaAtaque  
var defensa= stats[1]
var jugador: Node2D  
var direccion_actual = Vector2.ZERO  
var puede_atacar = true  

func _ready():
	jugador = get_tree().get_nodes_in_group("Jugador")[0] if get_tree().has_group("Jugador") else null

func _physics_process(_delta):
	if jugador:
		mover_hacia_jugador()
		atacar_si_es_posible()

func mover_hacia_jugador():
	var direccion_hacia_jugador = (jugador.global_position - global_position).normalized()
	var distancia_al_jugador = jugador.global_position.distance_to(global_position)

	if distancia_al_jugador > distancia_ataque:
		direccion_actual = direccion_hacia_jugador
		velocity = direccion_actual * speed
		move_and_slide()
		actualizar_animacion()
	else:
		direccion_actual = Vector2.ZERO
		velocity = Vector2.ZERO

func actualizar_animacion():
	if direccion_actual.x > 0:
		sprite.scale.x = -1  
		animation_player.play("Enemigo_Izquierda")
	elif direccion_actual.x < 0:
		sprite.scale.x = 1  
		animation_player.play("Enemigo_Izquierda") 
	elif direccion_actual.y < 0:
		animation_player.play("Enemigo_Arriba")
	elif direccion_actual.y > 0:
		animation_player.play("Enemigo_Abajo")

func atacar_si_es_posible():
	if jugador and puede_atacar:
		var distancia_al_jugador = jugador.global_position.distance_to(global_position)
		if distancia_al_jugador <= distancia_ataque:
			puede_atacar = false
			animation_player.play("Ataque")
			inflict_damage()
			await get_tree().create_timer(tiempo_entre_ataques).timeout
			puede_atacar = true

func inflict_damage():
	if jugador:
		var fuerza = stats[3]  
		var daño = 10 * (fuerza / 10) 
		jugador.take_damage(daño)

func take_damage(amount: int):
	var vida = estadisticas.obtener_stat(stats, estadisticas.ConjuntoDeStads.vida)
	vida -= amount
	estadisticas.modificar_stat(stats, estadisticas.ConjuntoDeStads.vida, -amount)  
	if damage_text_scene:
		var damage_text = damage_text_scene.instantiate()
		damage_text.position = global_position + Vector2(0, -20) 
		get_parent().add_child(damage_text) 
		damage_text.set_damage(amount, Color.BLUE)
	if vida <= 0:
		if jugador:
			jugador.añadir_puntos(10)
		queue_free()
