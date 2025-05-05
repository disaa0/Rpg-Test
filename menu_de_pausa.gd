extends Control

@onready var stats_label = $StatsLabel
@onready var save_button = $VBoxContainer/SaveButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var resolution_button = $VBoxContainer/ResolutionButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var inventario_scene = $Inventario
@onready var inventario_button = $VBoxContainer/InventarioButton

func _ready():
	hide()  # Oculta el menú al iniciar
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not save_button.pressed.is_connected(_on_save_button_pressed):
		save_button.pressed.connect(_on_save_button_pressed)
		
	if not load_button.pressed.is_connected(_on_load_button_pressed):
		load_button.pressed.connect(_on_load_button_pressed)
	if not exit_button.pressed.is_connected(_on_exit_button_pressed):
		exit_button.pressed.connect(_on_exit_button_pressed)
	if not inventario_button.pressed.is_connected(_on_inventario_pressed):
		inventario_button.pressed.connect(_on_inventario_pressed)

func toggle_menu():
	if visible:
		hide()
		get_tree().paused = false
	else:
		show()
		get_tree().paused = true

  # Evita que se registren inputs extra cuando se cierra



func _on_save_button_pressed() -> void:
	get_node("/root/Main").guardar_partida()
	print("Guardar partida")  

func _on_load_button_pressed() -> void:
	get_node("/root/Main").cargar_partida()
	print("Cargando partida")  


func _on_exit_button_pressed() -> void:
	hide()
	get_tree().paused = false
	print("Estado del juego pausado tras salir:", get_tree().paused)
	
	
func _on_inventario_pressed() -> void:
	inventario_scene.abrir()
