extends CharacterBody2D
@onready var estadisticas = $Estadisticas
@export var speed: float = 120.0  
var ataque_escena: PackedScene = preload("res://hacha_de_acero.tscn")
@export var damage_text_scene: PackedScene = preload("res://dañito_flotante_uw_u.tscn")

var objeto_cercano = null



var estados_activos = []#se borro, tomo mamaba Jeje
#conjunto de estadisticas para que optenga sus facultades cada Personaje
var stats = [1000, 50, 70,5,4,6,100,10,8,3,60,18,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0]
var fuerza=stats[2]
var vidaMaxima=stats[0]
var defenza=stats[1]
var resistenciaFis=stats[13]
var resistencia_timer = Timer.new()
var resistencia_actual = stats[6]  
var resistencia_base = stats[6]  
var inventario = {}

@onready var animation_player = $AnimationPlayer  
@onready var sprite = $Sprite2D  
@onready var menu = get_node("Camera2D2/MenuDePausa")

var en_pausa = false
var ultima_direccion = Vector2.RIGHT  
var manaMaxima = 100  
var manaActual = manaMaxima  

func _ready():
	resistencia_timer.wait_time = 1.0  
	resistencia_timer.autostart = true
	resistencia_timer.one_shot = false
	resistencia_timer.timeout.connect(_regenerar_resistencia) 
	add_child(resistencia_timer)
	menu = get_node_or_null("Camera2D2/MenuDePausa")
	#Defini la estaminitia
	
func agregar_al_inventario(nombre: String, cantidad: int = 1):
	if inventario.has(nombre):
		inventario[nombre] += cantidad
	else:
		inventario[nombre] = cantidad
	
	get_parent().actualizar_inventario(inventario)
	
func _process(_delta):
	var direction = Vector2.ZERO
	#Controles de movimiento
	if Input.is_action_pressed("Arriba"):
		direction.y -= 1
		ultima_direccion = Vector2.UP
		animation_player.play("Animacion_Arriba")
	elif Input.is_action_pressed("Abajo"):
		direction.y += 1
		ultima_direccion = Vector2.DOWN
		animation_player.play("Animacion_Abajo")
	elif Input.is_action_pressed("Izq"):
		direction.x -= 1
		ultima_direccion = Vector2.LEFT
		sprite.scale.x = 1  
		animation_player.play("Animacion_Izquierda")
	elif Input.is_action_pressed("Der"):
		direction.x += 1
		ultima_direccion = Vector2.RIGHT
		sprite.scale.x = -1 
		animation_player.play("Animacion_Izquierda")  
	
	# Si no se está presionando ningún botón de movimiento, detener la animación en el primer frame
	if direction == Vector2.ZERO:
		animation_player.stop()
	
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("ClicIzq"):
		realizar_ataque()
		
	if Input.is_action_just_pressed("Habilidad 1"):
			curar_vida(50)

	if Input.is_action_just_pressed("Pausa"):
		if menu.visible:
			menu.hide()
			get_tree().paused = false
		else:
			menu.show()
			get_tree().paused = true
			

func curar_vida(cantidad: int):
	var vida_actual = estadisticas.obtener_stat(stats, estadisticas.ConjuntoDeStads.vida)
	var nueva_vida = vida_actual + cantidad
	
	if nueva_vida > vidaMaxima:
		cantidad = vidaMaxima - vida_actual  # Solo curar hasta el máximo
		nueva_vida = vidaMaxima
	
	if cantidad > 0:
		estadisticas.modificar_stat(stats, estadisticas.ConjuntoDeStads.vida, cantidad)
		get_parent().actualizar_vida(nueva_vida)

func realizar_ataque():
	if resistencia_actual < 20:
		print("No tienes suficiente resistencia para atacar")
		return  
	resistencia_actual -= 20  # Restamos 20 de resistencia
	get_parent().actualizar_resistencia(resistencia_actual)  # Actualizar HUD
	var ataque = ataque_escena.instantiate()

	var posicion_ataque = global_position + (ultima_direccion * 20)

	get_parent().add_child(ataque)

	ataque.configurar_ataque(posicion_ataque, ultima_direccion,fuerza)

	
	if ataque.has_method("reproducir_animacion"):
		ataque.reproducir_animacion()
		
func añadir_monedas(cantidad: int):
	estadisticas.modificar_stat(stats, estadisticas.ConjuntoDeStads.monedas, cantidad)
	get_parent().actualizar_monedas(estadisticas.obtener_stat(stats, estadisticas.ConjuntoDeStads.monedas))
	#esta wea acomula los puntos que consigue el jugador, tomando el caso de que tenga puntos iniciales
	
func añadir_puntos(cantidad: int):
	estadisticas.modificar_stat(stats, estadisticas.ConjuntoDeStads.almas, cantidad)
	get_parent().actualizar_puntaje(estadisticas.obtener_stat(stats, estadisticas.ConjuntoDeStads.almas))
	#esta wea acomula los puntos que consigue el jugador, tomando el caso de que tenga puntos iniciales
	
func _regenerar_resistencia():
	if resistencia_actual < resistencia_base:
		resistencia_actual += 10
		if resistencia_actual > resistencia_base:
			resistencia_actual = resistencia_base  # No superar el valor base
		get_parent().actualizar_resistencia(resistencia_actual)  # Actualizar HUD
		
func take_damage(amount: int):
	var vida_actual = estadisticas.obtener_stat(stats, estadisticas.ConjuntoDeStads.vida)
	var reduccion = 1.0 - (float(defenza) / 100.0)
	var FinalDamage = int(amount * reduccion)  
	vida_actual -= FinalDamage
	estadisticas.modificar_stat(stats, estadisticas.ConjuntoDeStads.vida, -FinalDamage)

	
	if damage_text_scene:
		var damage_text = damage_text_scene.instantiate()
		damage_text.position = global_position  
		get_parent().add_child(damage_text) 
		damage_text.set_damage(amount, Color.CRIMSON)
	
	get_parent().actualizar_vida(vida_actual)

	if vida_actual <= 0:
		get_tree().change_scene_to_file("res://menu_de_inicio.tscn")
	
