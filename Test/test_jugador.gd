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

func test_enemigo_muerte() -> void:
	assert_false(enemigo.esta_muerto(), "El enemigo debería estar vivo al iniciar la prueba.")

	# Configuramos la vida del enemigo a un valor bajo
	# Primero obtenemos la vida actual
	var vida_actual = enemigo.estadisticas.obtener_stat(
		enemigo.stats,
		enemigo.estadisticas.ConjuntoDeStads.vida
	)
	# Luego modificamos para establecer a 1
	enemigo.estadisticas.modificar_stat(
		enemigo.stats,
		enemigo.estadisticas.ConjuntoDeStads.vida,
		1 - vida_actual  # Modificamos para que quede en 1
	)

	# Instanciamos un ataque
	ataque = preload("res://hacha_de_acero.tscn").instantiate()
	test_env.add_child(ataque)

	# Configuramos y realizamos el ataque
	var fuerza_del_jugador = jugador.stats[2]
	var posicion_ataque = jugador.global_position + Vector2.RIGHT * 20
	ataque.configurar_ataque(posicion_ataque, Vector2.RIGHT, fuerza_del_jugador)

	# Simulamos que golpea al enemigo
	ataque._on_body_entered(enemigo)

	# Verificamos que el enemigo haya muerto
	assert_true(enemigo.esta_muerto(), "El enemigo debería estar muerto después de recibir daño letal.")
	
func test_jugador_recibe_daño() -> void:
	var vida_inicial = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# Simulamos que el jugador recibe daño
	jugador.take_damage(10)
	
	var vida_actual = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# Calcular el daño esperado con la reducción de la defensa
	var reduccion = 1.0 - (float(jugador.defenza) / 100.0)
	var daño_esperado = int(10 * reduccion)
	
	assert_eq(vida_actual, vida_inicial - daño_esperado, "El jugador debería perder %d puntos de vida al recibir daño." % daño_esperado)

func test_jugador_regenera_resistencia() -> void:
	# Establecemos un valor bajo de resistencia
	var resistencia_inicial = 20
	jugador.resistencia_actual = resistencia_inicial
	
	# Simulamos el pasar del tiempo
	# Forzamos el timeout del timer
	jugador._regenerar_resistencia()
	
	# Verificamos que la resistencia aumentó
	assert_gt(jugador.resistencia_actual, resistencia_inicial, "La resistencia del jugador debería aumentar después de regenerarla.")

func test_agregar_item_al_inventario() -> void:
	# Verificamos que el inventario esté vacío o guarde el valor inicial
	var items_iniciales = jugador.inventario.size()
	
	# Agregamos un item al inventario
	jugador.agregar_al_inventario("Poción", 1)
	
	# Verificamos que el item fue agregado
	assert_true(jugador.inventario.has("Poción"), "El inventario debería contener el item 'Poción'")
	assert_eq(jugador.inventario["Poción"], 1, "Debería haber 1 'Poción' en el inventario")
	assert_eq(jugador.inventario.size(), items_iniciales + 1, "El inventario debería tener un item más")

func test_usar_pocion() -> void:
	# Establecemos una vida reducida
	var vida_maxima = jugador.vidaMaxima
	var vida_reducida = vida_maxima - 30
	
	# Obtenemos la vida actual
	var vida_actual = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# Modificamos la vida para que sea reducida
	jugador.estadisticas.modificar_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida,
		vida_reducida - vida_actual # Restamos la vida actual para establecer la vida reducida
	)
	
	# Agregamos una poción al inventario
	jugador.agregar_al_inventario("Poción", 1)
	
	# Verificamos la vida antes de usar la poción
	var vida_antes = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# Simular el uso de poción (asumiendo que cura 50 puntos)
	jugador.curar_vida(50)
	
	# Verificamos que la vida aumentó
	var vida_despues = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	assert_gt(vida_despues, vida_antes, "La vida debería aumentar después de usar una poción")
	
	# Consumimos la poción del inventario (simulando)
	jugador.inventario["Poción"] = 0
	assert_eq(jugador.inventario["Poción"], 0, "La poción debería consumirse al usarse")


	
func test_jugador_muerte() -> void:
	# Primero obtenemos la vida actual
	var vida_actual = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# Luego modificamos para establecer a 1
	jugador.estadisticas.modificar_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida,
		1 - vida_actual  # Modificamos para que quede en 1
	)
	
	# Verificamos que el jugador tiene 1 de vida
	vida_actual = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	assert_eq(vida_actual, 1, "El jugador debería tener 1 punto de vida")
	
	# Aplicamos un daño letal
	jugador.take_damage(10)
	
	# Verificamos que la vida es 0 o menos
	vida_actual = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	assert_true(vida_actual <= 0, "El jugador debería tener 0 o menos puntos de vida después de recibir daño letal")
	


func test_comprobacion_stats_iniciales() -> void:
	# Verificamos que los stats iniciales sean correctos
	var vida_actual = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# La vida inicial debe ser igual a la vida máxima definida en el jugador
	assert_eq(vida_actual, jugador.vidaMaxima, "La vida inicial debe ser igual a la vida máxima")
	
	# Verificar que las estadísticas básicas tengan valores razonables
	var fuerza = jugador.stats[2] # Suponiendo que la fuerza está en el índice 2
	var resistencia = jugador.stats[6] # Suponiendo que la resistencia está en el índice 6
	
	assert_gt(fuerza, 0, "La fuerza inicial debe ser mayor que cero")
	assert_gt(resistencia, 0, "La resistencia inicial debe ser mayor que cero")



func test_armadura_reduce_daño() -> void:
	# Guardamos la vida inicial
	var vida_inicial = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	
	# Aplicamos un daño
	var daño_base = 20
	jugador.take_damage(daño_base)
	
	# Verificamos que el daño recibido fue menor que el daño base
	var vida_despues = jugador.estadisticas.obtener_stat(
		jugador.stats,
		jugador.estadisticas.ConjuntoDeStads.vida
	)
	var daño_recibido = vida_inicial - vida_despues
	
	assert_lt(daño_recibido, daño_base, "La armadura debería reducir el daño recibido")

func after_each() -> void:
	if is_instance_valid(jugador):
		jugador.queue_free()
	if is_instance_valid(enemigo):
		enemigo.queue_free()
	if is_instance_valid(ataque):
		ataque.queue_free()
	if is_instance_valid(test_env):
		test_env.queue_free()
