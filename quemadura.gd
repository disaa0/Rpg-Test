extends Estado

class_name Quemadura  # Define esta clase como un tipo de Estado

@export var daño_por_segundo: int = 10  # Cantidad de daño por segundo

func iniciar_efecto():
	print(objetivo.name, " Ha sido quemado!")

func _process(delta):
	if objetivo:
		objetivo.recibir_daño(daño_por_segundo * delta)
	super._process(delta)

func finalizar_efecto():
	print(objetivo.name, " Dejó de estar quemado!")
