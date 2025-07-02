extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
var golEquipo1 = 0
var golEquipo2 = 0
var EquipoIzq
var EquipoDer
var en_partida = false
var FinDelJuego = false
var espectadores = []
var JugadoresEquipo1 = []
var JugadoresEquipo2 = []
var jugadores_por_id: Dictionary = {}
var jugadores_pendientes := {} 

var puede_marcar = true

func _process(delta):
	var fps = Engine.get_frames_per_second()
	DisplayServer.window_set_title("Mi Juego de Fútbol - FPS: %d" % fps)

func _on_host_pressed():
	var mi_nombre = get_node("Menu/MenuConfiguracion/Opciones/HBoxContainer/Opciones/Nombre").text.strip_edges()
	await get_tree().create_timer(1.1).timeout
	EquipoDer = get_node("Menu/MenuCrearPartida2/DER/ScrollColores").getNodoActual().get_equipo()
	EquipoIzq = get_node("Menu/MenuCrearPartida2/IZQ/ScrollColores").getNodoActual().get_equipo()
	en_partida = true
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	registrar_jugador(mi_nombre)
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_mapa_lindo()
	if multiplayer.is_server():
		var pelota = preload("res://Scenes/pelota.tscn").instantiate()
		
		pelota.name = "Pelota"
		pelota.set_multiplayer_authority(1)
		pelota.global_position = Vector3(0,5,0)
		pelota.scale = Vector3(3,3,3)
		add_child(pelota)

	_add_player()
	get_node("Button").visible = false
	get_node("Button2").visible = false

func _on_join_pressed(ip):
	en_partida = true

	var ipParseada = ip.split(':')
	peer.create_client(ipParseada[0], int(ipParseada[1]))
	multiplayer.multiplayer_peer = peer
	multiplayer.server_disconnected.connect(_on_disconnected_from_server)
	_add_mapa_lindo()
	await get_tree().create_timer(0.1).timeout
	var mi_nombre = get_node("Menu/MenuConfiguracion/Opciones/HBoxContainer/Opciones/Nombre").text.strip_edges()
	registrar_jugador.rpc_id(1, mi_nombre)

func _add_mapa_lindo():
	if OS.has_feature("editor") or OS.has_feature("windows") or OS.has_feature("x11"):
		var mapa_lindo = preload("res://Scenes/mapa.tscn").instantiate()
		add_child(mapa_lindo)

func _add_player(id = 1):
	sync_score.rpc(golEquipo1, golEquipo2)
	rpc_id(id, "asignarEquiposCliente", equipo_a_diccionario(EquipoIzq), equipo_a_diccionario(EquipoDer))
	var nombre = jugadores_por_id.get(id, "Jugador" + str(id))
	if id == multiplayer.get_unique_id():
		activar_camara_espectador()
	else:
		rpc_id(id, "activar_camara_espectador")
	
	if multiplayer.is_server():
		espectadores.append(nombre)
		actualizar_lista_espectadores(nombre)
		sync_lista_espectadores.rpc(espectadores) 
		rpc_id(id, "sync_lista_jugadores", JugadoresEquipo1, JugadoresEquipo2)

func _remove_player(id: int):
	if not multiplayer.is_server():
		return
	var nombre = jugadores_por_id.get(id, "Jugador" + str(id))
	if nombre in espectadores:
		espectadores.erase(nombre)
	for i in range(JugadoresEquipo1.size()):
		if JugadoresEquipo1[i]["nombre"] == nombre:
			JugadoresEquipo1.remove_at(i)
			break
	for i in range(JugadoresEquipo2.size()):
		if JugadoresEquipo2[i]["nombre"] == nombre:
			JugadoresEquipo2.remove_at(i)
			break
	var nodo = get_node_or_null("Jugador" + str(id))
	if nodo:
		nodo.queue_free()
	jugadores_por_id.erase(id)
	sync_lista_espectadores(espectadores)
	sync_lista_jugadores(JugadoresEquipo1, JugadoresEquipo2)
	sync_lista_espectadores.rpc(espectadores)
	sync_lista_jugadores.rpc(JugadoresEquipo1, JugadoresEquipo2)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		abrir_chat()
	if event is InputEventKey and event.keycode == KEY_TAB:
		if event.pressed and not event.echo:
			alternarEstadisticas()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif not event.pressed:
			alternarEstadisticas()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		abrirMenu()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

func abrir_chat():
	get_node("ChatBox").visible = not get_node("ChatBox").visible
	get_node("ChatBox/Chat").grab_focus()

func _on_arco_1_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server() or not puede_marcar:
		return

	puede_marcar = false

	_on_goal_scored(0)
	golEquipo2 += 1
	sync_score(golEquipo1, golEquipo2)
	sync_score.rpc(golEquipo1, golEquipo2)
	puede_marcar = true

func _on_arco_2_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server() or not puede_marcar:
		return
	puede_marcar = false
	_on_goal_scored(1)
	golEquipo1 += 1
	sync_score(golEquipo1, golEquipo2)
	sync_score.rpc(golEquipo1, golEquipo2)

@rpc("call_remote")
func sync_score(g1: int, g2: int):
	golEquipo1 = g1
	golEquipo2 = g2
	get_node("Control/E1").text = str(golEquipo1)
	get_node("Control/E2").text = str(golEquipo2)
	get_node("Menu/MenuTab/HBoxContainer/PIZQ").text = str(golEquipo1)
	get_node("Menu/MenuTab/HBoxContainer/PDER").text = str(golEquipo2)

@onready var players = get_tree().get_nodes_in_group("players")
@onready var ball = $Pelota
@export var player_spawn_positions := []

func _on_goal_scored(team_id):
	reset(team_id)
	puede_marcar = true

func alternarEstadisticas():
	if en_partida and not get_node("Menu/MenuPrincipal/Menu").visible:
		get_node("Menu/MenuTab").visible = not get_node("Menu/MenuTab").visible
		

	
func cerrarServidor():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		print("Servidor cerrado")
	en_partida = false
	
	for child in get_children():
		if child.name == "Pelota" or child.name.begins_with("Jugador") or child.name == "Mapa":
			remove_child(child)
			child.queue_free()

func _on_disconnected_from_server():
	cerrarServidor()
	get_node("Menu/AnimationPlayer").volverMenuBuscar()

func _on_menu_iniciar_partida() -> void:
	cerrarServidor()
	_on_host_pressed()

func _on_menu_entrar_partida(ip: Variant) -> void:
	cerrarServidor()
	_on_join_pressed(ip)
	
@rpc("any_peer")
func golTransicion():
	var anim_player = get_node("AnimationPlayer")
	if anim_player:
		anim_player.play("Gol")

func reset(equipoGol):
	golTransicion()
	golTransicion.rpc()
	await get_tree().create_timer(1).timeout
	
	pausarPelota()
	await get_tree().create_timer(1).timeout
	
	transicion_y_threshold()
	transicion_y_threshold.rpc()
	
	await get_tree().create_timer(0.6).timeout
	pausar_todos_jugadores()
	activar_camara_gol.rpc(equipoGol)
	activar_camara_gol(equipoGol)
	
	cambiarMostrarGoles.rpc(true)
	cambiarMostrarGoles(true)

	for child in get_children():
		if child.name.begins_with("Jugador"):
			if child.team_sync == equipoGol:
				child.ponerse_triste()
				child.rpc("ponerse_triste")
			else:
				child.saltar()
				child.rpc("saltar")

	await get_tree().create_timer(2.5).timeout
	cambiarMostrarGoles.rpc(false)
	cambiarMostrarGoles(false)
	transicion_y_threshold()
	transicion_y_threshold.rpc()
	await get_tree().create_timer(0.6).timeout
	_instanciar_pendientes() 
	moverAPosicionInicial()
	volver_a_camara_jugador.rpc()
	volver_a_camara_jugador()
	
	reposicionarPelota()
	if FinDelJuego == true:
		return
	reproducir_cuenta_regresiva()
	reproducir_cuenta_regresiva.rpc()
	await get_tree().create_timer(3.533).timeout
	despausar_todos_jugadores()


@rpc("call_remote")
func comenzar_partido():

	await get_tree().create_timer(1).timeout
	pausarPelota()
	pausar_todos_jugadores()

	await get_tree().create_timer(0.6).timeout

	_instanciar_pendientes()
	moverAPosicionInicial()
	reposicionarPelota()

	transicion_y_threshold()
	transicion_y_threshold.rpc()
	await get_tree().create_timer(0.6).timeout

	reproducir_cuenta_regresiva()
	reproducir_cuenta_regresiva.rpc()
	await get_tree().create_timer(3.533).timeout

	despausar_todos_jugadores()
	volver_a_camara_jugador.rpc()
	volver_a_camara_jugador()

@rpc("call_remote")
func activar_camara_gol(equipogol):
	var camara_gol = get_node("CamaraGol")
	if camara_gol:
		camara_gol.current = true
		var anim = get_node_or_null("AnimationPlayer")
		if anim:
			if equipogol:
				anim.play("camaraGol2")
			else:
				anim.play("camaraGol1")
				
@rpc("call_remote")
func activar_camara_espectador():
	for cam in get_tree().get_nodes_in_group("camaras"):
		cam.current = false
	get_node("CamaraEspectador").current = true

@rpc
func volver_a_camara_jugador():
	for child in get_children():
		if child.name.begins_with("Jugador"):
			if child.get_multiplayer_authority() == multiplayer.get_unique_id():
				var animation = child.emit_signal("landed")
				child.velocity = Vector3.ZERO
				var cam_jugador = child.get_node_or_null("Camera3D")
				if cam_jugador:
					cam_jugador.current = true

@rpc					
func transicion_y_threshold() -> void:
	var color_rect = get_node("ColorRect")
	var shader_material = color_rect.material

	var tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/y_threshold", 1.0, 0.6) \
		.from(0.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/y_threshold", 0.0, 0.8) \
		.from(1.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func pausar_todos_jugadores():
	for child in get_children():
		if child.name.begins_with("Jugador"):
			child.pausar()
			child.rpc("pausar")
			
func despausar_todos_jugadores():
	for child in get_children():
		if child.name.begins_with("Jugador"):
			child.despausar()
			child.rpc("despausar")
			
func reposicionarPelota():
	var ball = get_node("Pelota")
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_transform.origin = Vector3.ZERO + Vector3(0,5,0)
	ball.mass = 1

func pausarPelota():
	var ball = get_node("Pelota")
	ball.mass = 1000
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
			
func moverAPosicionInicial():
	var offset = 6.0
	var base_y = 3
	var base_z_izq = -20.0
	var base_z_der = 20.0

	var equipo_izq := []
	var equipo_der := []

	
	for child in get_children():
		if child.name.begins_with("Jugador"):
			if child.team_sync == 0:
				equipo_izq.append(child)
			elif child.team_sync == 1:
				equipo_der.append(child)
				
	var cantidad_izq = equipo_izq.size()
	var cantidad_der = equipo_der.size()

	var ancho_izq = (cantidad_izq - 1) * offset
	var x_inicial_izq = -ancho_izq / 2.0

	var ancho_der = (cantidad_der - 1) * offset
	var x_inicial_der = -ancho_der / 2.0

	for i in range(cantidad_izq):
		var jugador = equipo_izq[i]
		var x_pos = x_inicial_izq + i * offset
		var pos = Vector3(x_pos, base_y, base_z_izq)
		var id = jugador.get_multiplayer_authority()
		if id == multiplayer.get_unique_id():
			jugador.mover_a(pos)
			jugador.look_at(Vector3(x_pos, base_y, base_z_der), Vector3.UP)  # mirar al equipo derecho
		else:
			jugador.rpc_id(id, "mover_a", pos)

	for i in range(cantidad_der):
		var jugador = equipo_der[i]
		var x_pos = x_inicial_der + i * offset
		var pos = Vector3(x_pos, base_y, base_z_der)
		var id = jugador.get_multiplayer_authority()
		if id == multiplayer.get_unique_id():
			jugador.mover_a(pos)
			jugador.look_at(Vector3(x_pos, base_y, base_z_izq), Vector3.UP)  # mirar al equipo izquierdo
		else:
			jugador.rpc_id(id, "mover_a", pos)
			
@rpc("authority", "call_local")
func cambiarMostrarGoles(estado):
	get_node("Control").visible = estado

@rpc("authority", "call_local")
func TiempoFuera():
	get_node("AnimationPlayer").play("TIEMPO")

@rpc("authority", "call_local")
func reproducir_cuenta_regresiva():
	get_node("AnimationPlayer").play("cuenta_regresiva")

@rpc("authority", "call_local")
func asignarEquiposCliente(equipo_izq, equipo_der):
	get_node("Menu/Control/EquipoIzq/EQUIPOS")._asignarColores_desde_dato(equipo_izq)
	get_node("Menu/Control/EquipoDer/EQUIPOS")._asignarColores_desde_dato(equipo_der)
	get_node("Menu/MenuTab/EquipoDer/abr").text = equipo_izq["abreviacion"]
	get_node("Menu/MenuTab/EquipoIzq/abr").text = equipo_der["abreviacion"]
	get_node("Menu/MenuTab/EquipoDer/nombre").text = equipo_izq["nombre"]
	get_node("Menu/MenuTab/EquipoIzq/nombre").text = equipo_der["nombre"]
	
func equipo_a_diccionario(equipo) -> Dictionary:
	return {
		"nombre": equipo.nombre,
		"abreviacion": equipo.abreviacion,
		"colores": equipo.colores
	}

@rpc("call_local")
func actualizar_lista_espectadores(nombre_jugador: String):
	var lista := get_node("Menu/MenuTab/ListaEspectadores/VBoxContainer")
	for i in range(lista.get_child_count()):
		var label = lista.get_child(i)
		if label is Label and label.text == "":
			label.text = nombre_jugador
			break

@rpc("call_remote")
func sync_lista_espectadores(lista: Array):
	var vbox = get_node("Menu/MenuTab/ListaEspectadores/VBoxContainer")
	for i in range(vbox.get_child_count()):
		var label = vbox.get_child(i)
		label.text = ""
	for i in range(min(vbox.get_child_count(), lista.size())):
		vbox.get_child(i).text = lista[i]

func abrirMenu():
	var menuPrincipal = get_node("Menu/MenuPrincipal/Menu")
	var menuTab = get_node("Menu/MenuTab")
	var menuConfig = get_node("Menu/MenuConfiguracion")
	var menuSelect = get_node("Menu/MenuSelectorPartida")
	var menuCrear = get_node("Menu/MenuCrearPartida1")
	var menuCrear2 = get_node("Menu/MenuCrearPartida2")
	var menuAnimation = get_node("Menu/AnimationPlayer")
	if not menuPrincipal.visible:
		menuAnimation.transition_state = 5
		menuConfig.visible = false
		menuSelect.visible = false
		menuCrear.visible = false
		menuCrear2.visible = false
		
	if menuTab.visible and not menuPrincipal.visible:
		menuTab.visible = false
	menuPrincipal.visible = not menuPrincipal.visible
	
@rpc("any_peer")
func solicitar_unirse_equipo(direccion: String):
	if not multiplayer.is_server():
		return

	var id = multiplayer.get_remote_sender_id()
	if id == 0:
		id = multiplayer.get_unique_id()

	var nombre = jugadores_por_id.get(id, "Jugador" + str(id))

	JugadoresEquipo1 = JugadoresEquipo1.filter(func(j): return j.nombre != nombre)
	JugadoresEquipo2 = JugadoresEquipo2.filter(func(j): return j.nombre != nombre)
	espectadores.erase(nombre)

	var team_sync : int
	var jugador_data = {"nombre": nombre, "puntaje": 0}

	if direccion == "izq":
		team_sync = 0
		JugadoresEquipo1.append(jugador_data)
	else:
		team_sync = 1
		JugadoresEquipo2.append(jugador_data)

	var nodo = get_node_or_null("Jugador" + str(id))
	if nodo:
		nodo.queue_free()
		rpc_id(id, "eliminar_jugador_nodo", id)

	jugadores_pendientes[id] = {"nombre": nombre, "team": team_sync}

	_sincronizar_listas()
	
func _instanciar_pendientes() -> void:
	for id in jugadores_pendientes.keys():
		var entry      : Dictionary = jugadores_pendientes[id]
		var nombre     : String     = str(entry["nombre"])
		var team_sync  : int        = int(entry["team"])
		var datos      : Dictionary

		if team_sync == 0:
			datos = equipo_a_diccionario(EquipoIzq)
		else:
			datos = equipo_a_diccionario(EquipoDer)

		instanciar_jugador(id, nombre, team_sync, datos)
		rpc("instanciar_jugador", id, nombre, team_sync, datos)

	jugadores_pendientes.clear()
	
func _sincronizar_listas() -> void:
	sync_lista_espectadores(espectadores)
	sync_lista_jugadores(JugadoresEquipo1, JugadoresEquipo2)
	sync_lista_espectadores.rpc(espectadores)
	sync_lista_jugadores.rpc(JugadoresEquipo1, JugadoresEquipo2)
	
func _on_menu_solicitar_izq(direccion) -> void:
	if multiplayer.get_unique_id() != 1:
		rpc_id(1, "solicitar_unirse_equipo", direccion)
	else:
		solicitar_unirse_equipo(direccion)
		
@rpc("call_remote")
func sync_lista_jugadores(lista_izq: Array, lista_der: Array):
	var cont_izq = get_node("Menu/MenuTab/EquipoIzq/Jugadores/VBoxContainer2")
	var cont_der = get_node("Menu/MenuTab/EquipoDer/Jugadores/VBoxContainer2")

	for i in range(cont_izq.get_child_count()):
		var fila = cont_izq.get_child(i)
		fila.get_node("nombre").text = ""
		fila.get_node("puntaje").text = ""

	for i in range(cont_der.get_child_count()):
		var fila = cont_der.get_child(i)
		fila.get_node("nombre").text = ""
		fila.get_node("puntaje").text = ""

	for i in range(min(lista_izq.size(), cont_izq.get_child_count())):
		var jugador = lista_izq[i]
		var fila = cont_izq.get_child(i)
		fila.get_node("nombre").text = jugador.nombre
		fila.get_node("puntaje").text = str(jugador.puntaje)

	for i in range(min(lista_der.size(), cont_der.get_child_count())):
		var jugador = lista_der[i]
		var fila = cont_der.get_child(i)
		fila.get_node("nombre").text = jugador.nombre
		fila.get_node("puntaje").text = str(jugador.puntaje)


func _on_menu_solicitar_der(dir: Variant) -> void:
	if multiplayer.get_unique_id() != 1:
		rpc_id(1, "solicitar_unirse_equipo", dir)
	else:
		solicitar_unirse_equipo(dir)

@rpc("any_peer")
func solicitar_volver_a_espectador():
	if not multiplayer.is_server():
		return

	var id = multiplayer.get_remote_sender_id()
	if id == 0:
		id = multiplayer.get_unique_id()

	var nombre = jugadores_por_id.get(id, "Jugador" + str(id))

	for i in range(JugadoresEquipo1.size()):
		if JugadoresEquipo1[i].nombre == nombre:
			JugadoresEquipo1.remove_at(i)
			break

	for i in range(JugadoresEquipo2.size()):
		if JugadoresEquipo2[i].nombre == nombre:
			JugadoresEquipo2.remove_at(i)
			break

	if not nombre in espectadores:
		espectadores.append(nombre)

	sync_lista_espectadores(espectadores)
	sync_lista_jugadores(JugadoresEquipo1, JugadoresEquipo2)
	sync_lista_espectadores.rpc(espectadores)
	sync_lista_jugadores.rpc(JugadoresEquipo1, JugadoresEquipo2)
	
	var nodo = get_node_or_null("Jugador" + str(id))
	if nodo:
		nodo.queue_free()
	rpc_id(id, "eliminar_jugador_nodo", id)
	activar_camara_espectador()

func _on_menu_solicitar_espectador() -> void:
	if multiplayer.get_unique_id() != 1:
		rpc_id(1, "solicitar_volver_a_espectador")
	else:
		solicitar_volver_a_espectador()

@rpc("any_peer")
func registrar_jugador(nombre: String):
	var id := multiplayer.get_remote_sender_id()
	if id == 0 or not multiplayer.is_server():
		id = multiplayer.get_unique_id()
	var original := nombre
	var n := 1
	while nombre_ya_usado(nombre):
		nombre = "%s%d" % [original, n]
		n += 1

	jugadores_por_id[id] = nombre

	if !multiplayer.is_server():
		return

	var placeholder := "Jugador" + str(id)

	for i in range(espectadores.size()):
		if espectadores[i] == placeholder:
			espectadores[i] = nombre

	for j in JugadoresEquipo1:
		if j["nombre"] == placeholder:
			j["nombre"] = nombre
			break

	for j in JugadoresEquipo2:
		if j["nombre"] == placeholder:
			j["nombre"] = nombre
			break

	sync_lista_espectadores(espectadores)
	sync_lista_jugadores(JugadoresEquipo1, JugadoresEquipo2)
	sync_lista_espectadores.rpc(espectadores)
	sync_lista_jugadores.rpc(JugadoresEquipo1, JugadoresEquipo2)

func nombre_ya_usado(nombre: String) -> bool:
	for existing_nombre in jugadores_por_id.values():
		if existing_nombre == nombre:
			return true
	return false

@rpc("call_local")
func recibir_teams(equipos: Dictionary) -> void:
	for j_nombre in equipos.keys():
		var j := get_node_or_null(NodePath(j_nombre))
		if j:
			j.team_sync = equipos[j_nombre]

@rpc("call_remote")
func instanciar_jugador(id: int, nombre: String, team: int, datosEquipo: Dictionary):
	var jugador := get_node_or_null("Jugador" + str(id))
	
	if jugador:
		jugador.team_sync = team
		jugador.nombre    = nombre
	else:
		jugador = player_scene.instantiate()
		jugador.name  = "Jugador" + str(id)
		jugador.set_multiplayer_authority(id)
		jugador.team_sync = team
		jugador.nombre = nombre
		jugador.global_position = Vector3(0, 0, 0)
		add_child(jugador)
	var cam = jugador.get_node_or_null("Camera3D")
	if cam:
		cam.current = (id == multiplayer.get_unique_id())
	jugador.get_node("Armature")._asignarColores_desde_dato(datosEquipo)

	if not jugador.is_in_group("players"):
		jugador.add_to_group("players")
		
	if id == multiplayer.get_unique_id():
		volver_a_camara_jugador()
		
		
@onready var timer := $"Timer"
var t := 300        
		
func _on_menu_empezar() -> void:
	if multiplayer.is_server():
		comenzar_partido()
		_instanciar_pendientes()
		var timer = get_node("Timer")
		t = 15
		timer.wait_time = 1       
		timer.start()

@rpc("call_remote")
func actualizar_tiempo_label(s:int):
	get_node("Tiempo").text = "%02d:%02d" % [s/60, s%60]
	get_node("Tiempo").visible = true

func _on_timer_timeout() -> void:    
	if multiplayer.is_server():
		t -= 1
		actualizar_tiempo_label.rpc(t)
		actualizar_tiempo_label(t)
		if t == 0:
			timer.stop()
			pausar_todos_jugadores()
			FinDelJuego = true
			TiempoFuera()
			TiempoFuera.rpc()
