extends CharacterBody2D

@onready var estadisticas = $Estadisticas
@export var speed: float = 50.0  
@export var fireball_scene: PackedScene = preload("res://disparo_de_veneno.tscn")
@export var esqueleto_scene: PackedScene = preload("res://esqueleto_guerrero.tscn")
@export var damage_text_scene: PackedScene = preload("res://dañito_flotante_uw_u.tscn")
@export var distancia_optima: float = 100.0  
@export var margen: float = 10.0  
@export var tiempo_fallo_disparo: float = 1.5  
@export var tiempo_entre_invocaciones: float = 5.0
var max_esqueletos = 5
var esqueletos_invocados = []

var stats = [200, 10, 15, 20, 4, 6, 3, 10, 8, 3, 15, 18]
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D  

var jugador: Node2D  
var direccion_actual = Vector2.ZERO  
var ultima_direccion_disparo = Vector2.RIGHT 
var fallos_consecutivos = 0  
var max_fallos = 2  

func _ready():
	jugador = get_tree().get_nodes_in_group("Jugador")[0] if get_tree().has_group("Jugador") else null
	lanzar_veneno()
	invocar_esqueletos()

func _physics_process(_delta):
	if jugador:
		ajustar_distancia_al_jugador()

func ajustar_distancia_al_jugador():
	var direccion_hacia_jugador = (jugador.global_position - global_position).normalized()
	var distancia_al_jugador = jugador.global_position.distance_to(global_position)
	var nueva_direccion = Vector2.ZERO
	
	if abs(direccion_hacia_jugador.x) > abs(direccion_hacia_jugador.y):
		if distancia_al_jugador < distancia_optima - margen:
			nueva_direccion = Vector2.RIGHT if direccion_hacia_jugador.x < 0 else Vector2.LEFT  
		elif distancia_al_jugador > distancia_optima + margen:
			nueva_direccion = Vector2.LEFT if direccion_hacia_jugador.x < 0 else Vector2.RIGHT 
	else:
		if distancia_al_jugador < distancia_optima - margen:
			nueva_direccion = Vector2.DOWN if direccion_hacia_jugador.y < 0 else Vector2.UP  
		elif distancia_al_jugador > distancia_optima + margen:
			nueva_direccion = Vector2.UP if direccion_hacia_jugador.y < 0 else Vector2.DOWN 
	
	if fallos_consecutivos >= max_fallos:
		nueva_direccion = ajustar_posicion_para_atinar()
		fallos_consecutivos = 0  
	
	if nueva_direccion != Vector2.ZERO:
		direccion_actual = nueva_direccion
	
	velocity = direccion_actual * speed
	move_and_slide()
	actualizar_animacion()

func actualizar_animacion():
	if direccion_actual == Vector2.RIGHT:
		sprite.scale.x = -1  
		animation_player.play("Enemigo_Izquierda")
	elif direccion_actual == Vector2.LEFT:
		sprite.scale.x = 1  
		animation_player.play("Enemigo_Izquierda") 
	elif direccion_actual == Vector2.UP:
		animation_player.play("Enemigo_Arriba")
	elif direccion_actual == Vector2.DOWN:
		animation_player.play("Enemigo_Abajo")

func lanzar_veneno():
	while jugador:
		await get_tree().create_timer(2.0).timeout  
		var direccion_disparo = obtener_direccion_hacia_jugador()
		ultima_direccion_disparo = direccion_disparo  
		
		var bola = fireball_scene.instantiate()
		bola.global_position = global_position
		bola.set_direccion(direccion_disparo)
		
		if direccion_disparo == Vector2.RIGHT:
			bola.rotation_degrees = 90
		elif direccion_disparo == Vector2.LEFT:
			bola.rotation_degrees = -90
		elif direccion_disparo == Vector2.UP:
			bola.rotation_degrees = 0
		elif direccion_disparo == Vector2.DOWN:
			bola.rotation_degrees = 180
		
		var inteligencia = stats[4] 
		var daño_calculado = 10 * (inteligencia / 10) 
		bola.set_dano(daño_calculado)
		
		get_parent().add_child(bola)
		await get_tree().create_timer(tiempo_fallo_disparo).timeout
		if bola and is_instance_valid(bola):
			fallos_consecutivos += 1
		else:
			fallos_consecutivos = 0  

func obtener_direccion_hacia_jugador() -> Vector2:
	var direccion_hacia_jugador = (jugador.global_position - global_position).normalized()
	if abs(direccion_hacia_jugador.x) > abs(direccion_hacia_jugador.y):
		return Vector2.RIGHT if direccion_hacia_jugador.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if direccion_hacia_jugador.y > 0 else Vector2.UP

func ajustar_posicion_para_atinar() -> Vector2:
	if ultima_direccion_disparo == Vector2.RIGHT or ultima_direccion_disparo == Vector2.LEFT:
		return Vector2.UP if randi() % 2 == 0 else Vector2.DOWN
	else:
		return Vector2.LEFT if randi() % 2 == 0 else Vector2.RIGHT

func invocar_esqueletos():
	while jugador:
		await get_tree().create_timer(tiempo_entre_invocaciones).timeout
		if esqueletos_invocados.size() < max_esqueletos:
			var esqueleto = esqueleto_scene.instantiate()
			esqueleto.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			esqueleto.connect("tree_exited", Callable(self, "esqueleto_muerto"))
			get_parent().add_child(esqueleto)
			esqueletos_invocados.append(esqueleto)

func esqueleto_muerto():
	for i in range(esqueletos_invocados.size()):
		if !is_instance_valid(esqueletos_invocados[i]):
			esqueletos_invocados.remove_at(i)
			break

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
		get_tree().change_scene_to_file("res://creditos.tscn")
