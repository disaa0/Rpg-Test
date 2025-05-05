extends Area2D

@export var nombre_objeto: String = "Anillo de Rubi"
@export var cantidad: int = 1

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Jugador":
		body.agregar_al_inventario(nombre_objeto, cantidad)
		queue_free()
