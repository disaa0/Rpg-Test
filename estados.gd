extends Node

class_name Estado  # Define esta clase como base para otros estados

@export var nombre: String = "Estado"  # Nombre del estado
@export var duracion: float = 5.0  # Tiempo que dura el estado en segundos

var objetivo  # La entidad que recibe el estado (jugador, enemigo, etc.)
var tiempo_restante: float  

func aplicar(entidad):
	objetivo = entidad
	tiempo_restante = duracion
	iniciar_efecto()

func _process(delta):
	if objetivo:
		tiempo_restante -= delta
		if tiempo_restante <= 0:
			finalizar_efecto()
			queue_free()

func iniciar_efecto():
	pass  # Se sobrescribe en estados específicos

func finalizar_efecto():
	pass  # Se sobrescribe en estados específicos
