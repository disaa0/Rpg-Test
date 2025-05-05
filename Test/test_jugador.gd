extends GutTest

var test_env: Node
var jugador: Node
var enemigo: Node
var ataque: Node

func before_each() -> void:
	test_env = preload("res://test_environment.tscn").instantiate()
	add_child(test_env)

	jugador = preload("res://jugador.tscn").instantiate()
	enemigo = preload("res://enemigo.tscn").instantiate()
	test_env.add_child(jugador)
	test_env.add_child(enemigo)

func test_hacha_daño_correcto() -> void:
	assert_false(enemigo.esta_muerto(), "El enemigo debería estar vivo al iniciar la prueba.")

	# Instanciamos manualmente el ataque
	ataque = preload("res://hacha_de_acero.tscn").instantiate()
	test_env.add_child(ataque)

	# Configuramos el ataque como lo haría el jugador
	var fuerza_del_jugador = jugador.stats[2]  # fuerza está en índice 2
	var posicion_ataque = jugador.global_position + Vector2.RIGHT * 20
	ataque.configurar_ataque(posicion_ataque, Vector2.RIGHT, fuerza_del_jugador)
	var vida_inicial = enemigo.estadisticas.obtener_stat(
		enemigo.stats,
		enemigo.estadisticas.ConjuntoDeStads.vida
	)

	# Simulamos que golpea al enemigo
	ataque._on_body_entered(enemigo)

	# Ahora verificamos la vida del enemigo
	var vida_actual = enemigo.estadisticas.obtener_stat(
	enemigo.stats, 
	enemigo.estadisticas.ConjuntoDeStads.vida
)
  # Suponiendo que tu enemigo tiene este método
	var vida_esperada = vida_inicial - ataque.damage  # Daño base del hacha + (fuerza/2)

	assert_eq(vida_actual, vida_esperada, "El enemigo debería recibir exactamente el daño esperado.")

func after_each() -> void:
	if is_instance_valid(jugador):
		jugador.queue_free()
	if is_instance_valid(enemigo):
		enemigo.queue_free()
	if is_instance_valid(ataque):
		ataque.queue_free()
	if is_instance_valid(test_env):
		test_env.queue_free()
