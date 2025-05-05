extends Node2D

@onready var estadisticas = $Jugador/Estadisticas
@onready var hud = $Jugador/Camera2D2/HUD
@onready var audio_player = $AudioStreamPlayer2D
@onready var BarradeVida_label = hud.get_node("VBoxContainer/Vida")
@onready var Puntaje_label = hud.get_node("VBoxContainer/Puntos")
@onready var Resistencia_label = hud.get_node("VBoxContainer/Resistencia")
@onready var Mente_label = hud.get_node("VBoxContainer/Mente")
@onready var Jugadorcin = $Jugador
@onready var resistencia_timer = Timer
@onready var spawn_points = [
	$SpawnPoint1,
	$SpawnPoint2,
	$SpawnPoint3,
	$SpawnPoint4,
	$SpawnPoint5
]

@export var Slime: PackedScene = preload("res://amalgama.tscn")
@export var Necromancer: PackedScene = preload("res://necromancer.tscn")

var enemigos_actuales = 0
var enemigos_derrotados = 0
const MAX_ENEMIGOS = 6
const Puntitos_Ricos = 150
var spawn_necromancer = false

func _ready() -> void:
	audio_player.play()
	actualizar_vida(Jugadorcin.stats[0])  
	actualizar_puntaje(Jugadorcin.stats[12])
	actualizar_resistencia(Jugadorcin.stats[6])  
	actualizar_mente(Jugadorcin.stats[10])
	# Incio el cosito que se invoquen los enemigos y tal
	$SpawnTimer.start()
	
func actualizar_vida(vida):
	BarradeVida_label.text = "Vida: " + str(vida)
func actualizar_resistencia(nueva_resistencia):
	Resistencia_label.text = "Resistencia: " + str(nueva_resistencia)
func _on_save_button_pressed() -> void:
	get_tree().get_root().get_node("Main").guardar_partida()
	print("Partida guardada desde el menú de pausa")

func _on_load_button_pressed() -> void:
	get_tree().get_root().get_node("Main").cargar_partida()
	print("Partida cargada desde el menú de pausa")


func actualizar_mente(mente):
	Mente_label.text = "Mente: " + str(mente)
	
func actualizar_puntaje(puntos):
	Puntaje_label.text = "Puntos: " + str(puntos)
	if puntos >= Puntitos_Ricos and not spawn_necromancer:
		spawn_necromancer = true
		limpiar_enemigos()
		spawn_boss()

func spawn_enemy():
	if enemigos_actuales >= MAX_ENEMIGOS or spawn_necromancer:
		return  

	if spawn_points.is_empty():
		print("Error: No hay spawn points definidos.")
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]

	if spawn_point == null:
		print("Error: spawn_point es null")
		return

	var enemigo = Slime.instantiate()
	enemigo.global_position = spawn_point.global_position  # Usamos global_position
	add_child(enemigo)
	enemigos_actuales += 1




func spawn_boss():
	if not Necromancer:
		print("Error: No se ha asignado la escena del Necromancer.")
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var boss = Necromancer.instantiate()
	boss.position = spawn_point.position
	add_child(boss)

	print("¡Necromancer ha aparecido!")

func limpiar_enemigos():
	for enemigo in get_children():
		if enemigo is CharacterBody2D and enemigo != Jugadorcin:
			enemigo.queue_free()

	enemigos_actuales = 0  # Resetear el contador de enemigos

#Aun no hay optencion de puntos aun por que al matar al primer enemigo ganas y tal... y por que no tube tiempo... pero hay daño al enemigo :D


func _on_spawn_timer_timeout() -> void:
	spawn_enemy()  


func _on_timer_timeout() -> void:
	if not estadisticas:  
		print("Error: No se encontró el nodo de estadísticas.")
		return

	if not estadisticas.has_method("get_resistencia") or not estadisticas.has_method("get_resistencia_max"):
		print("Error: Estadísticas no tiene los métodos esperados.")
		return

	var resistencia_actual = estadisticas.get_resistencia()
	var resistencia_maxima = estadisticas.get_resistencia_max()

	if resistencia_actual < resistencia_maxima:
		estadisticas.set_resistencia(resistencia_actual + 1)  
		actualizar_resistencia(estadisticas.get_resistencia())  
		
func guardar_partida():
	var datos = {
		"posicion_jugador": {"x": Jugadorcin.global_position.x, "y": Jugadorcin.global_position.y},
		"estadisticas": Jugadorcin.stats
	}

	var archivo = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()
	print("Partida guardada")

func cargar_partida():
	if not FileAccess.file_exists("user://savegame.json"):
		print("No hay partida guardada")
		return

	var archivo = FileAccess.open("user://savegame.json", FileAccess.READ)
	var contenido = archivo.get_as_text()
	archivo.close()

	var datos = JSON.parse_string(contenido)
	if datos:
		Jugadorcin.global_position = Vector2(datos["posicion_jugador"]["x"], datos["posicion_jugador"]["y"])
		Jugadorcin.stats = datos["estadisticas"]
		actualizar_vida(Jugadorcin.stats[0]) 
		actualizar_puntaje(Jugadorcin.stats[12])  
		print("Partida cargada")
	else:
		print("Error al cargar la partida")
