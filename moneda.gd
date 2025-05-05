# Moneda.gd
extends Area2D

@export var valor: int = 1  # Valor de la moneda, por defecto 1

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Jugador":
		body.añadir_monedas(valor)
		queue_free()  # Elimina la moneda de la escena
