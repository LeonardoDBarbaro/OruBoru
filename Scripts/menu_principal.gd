extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
var golEquipo1 = 0
var golEquipo2 = 0
var en_partida = false

func _process(delta):
	var fps = Engine.get_frames_per_second()
	DisplayServer.window_set_title("Mi Juego de Fútbol - FPS: %d" % fps)

func _on_host_pressed():
	en_partida = true
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
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

	get_node("Button").visible = false
	get_node("Button2").visible = false

func _add_mapa_lindo():
	if OS.has_feature("editor") or OS.has_feature("windows") or OS.has_feature("x11"):
		var mapa_lindo = preload("res://Scenes/mapa.tscn").instantiate()
		add_child(mapa_lindo)

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = "Jugador" + str(id)
	player.global_position = Vector3(0, 10, 0)
	sync_score.rpc(golEquipo1, golEquipo2)
	player.set_multiplayer_authority(id) 
	add_child(player)
	await get_tree().create_timer(0.1).timeout
	if not multiplayer.is_server():
		player.team_sync = 0
	else: 
		player.team_sync = 1
	sync_teams_con_cliente(id)
	
func _remove_player(id: int):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		abrir_chat()
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		abrirEstadisticas()
	if event is InputEventKey and event.is_released() and event.keycode == KEY_TAB:
		cerrarEstadisticas()

func abrir_chat():
	get_node("ChatBox").visible = not get_node("ChatBox").visible
	get_node("ChatBox/Chat").grab_focus()

func _on_arco_1_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server(): return
	_on_goal_scored(1)
	golEquipo1 += 1
	sync_score(golEquipo1, golEquipo2)
	sync_score.rpc(golEquipo1, golEquipo2)

func _on_arco_2_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server(): return
	_on_goal_scored(1)
	golEquipo2 += 1
	sync_score(golEquipo1, golEquipo2)
	sync_score.rpc(golEquipo1, golEquipo2)

@rpc("call_remote")
func sync_score(g1: int, g2: int):
	golEquipo1 = g1
	golEquipo2 = g2
	get_node("Control/E1").text = str(golEquipo1)
	get_node("Control/E2").text = str(golEquipo2)

@onready var players = get_tree().get_nodes_in_group("players")
@onready var ball = $Pelota
@export var player_spawn_positions := []

func _on_goal_scored(team_id):
	reset()

func abrirEstadisticas():
	if en_partida:
		get_node("Menu/MenuTab").visible = true
	
func cerrarEstadisticas():
	get_node("Menu/MenuTab").visible = false
	
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
	
func sync_teams_con_cliente(peer_id: int):
	var equipos := {}

	for child in get_children():
		if child.name.begins_with("Jugador"):
			equipos[child.name] = child.team_sync

	rpc_id(peer_id, "recibir_teams", equipos)

func reset():
	
	var offset = 6.0
	var base_y = 0.0
	var base_z_izq = -20.0
	var base_z_der = 20.0

	var equipo_izq := []
	var equipo_der := []
	var ball = get_node("Pelota")
	
	await get_tree().create_timer(1).timeout
	ball.mass = 1000
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	
	await get_tree().create_timer(2).timeout
	
	activar_camara_gol.rpc()
	await get_tree().create_timer(0.3).timeout
	get_node("Control").visible = true
	activar_camara_gol()
	get_node("AnimationPlayer").play("camaraGol1")
	# Animaciones de celebración
	for child in get_children():
		if child.name.begins_with("Jugador"):
			if child.team_sync == 1:
				child.ponerse_triste()
				child.ponerse_triste.rpc()
			else:
				child.saltar()
				child.saltar.rpc()

	await get_tree().create_timer(2).timeout
	for child in get_children():
		if child.name.begins_with("Jugador"):
			if child.team_sync == 0:
				equipo_izq.append(child)
			elif child.team_sync == 1:
				equipo_der.append(child)
	
	for i in range(equipo_izq.size()):
		var jugador = equipo_izq[i]
		var pos = Vector3(i * offset, base_y, base_z_izq)
		var id = jugador.get_multiplayer_authority()
		if id == multiplayer.get_unique_id():
			jugador.ir_a(pos)
		else:
			jugador.rpc_id(id, "ir_a", pos)

	for i in range(equipo_der.size()):
		var jugador = equipo_der[i]
		var pos = Vector3(i * offset, base_y, base_z_der)
		var id = jugador.get_multiplayer_authority()
		if id == multiplayer.get_unique_id():
			jugador.ir_a(pos)
		else:
			jugador.rpc_id(id, "ir_a", pos)

	await get_tree().create_timer(2.7).timeout
	get_node("Control").visible = false
	await get_tree().create_timer(0.3).timeout
	volver_a_camara_jugador.rpc()
	volver_a_camara_jugador()
	
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_transform.origin = Vector3.ZERO
	ball.mass = 1

@rpc("call_remote")
func activar_camara_gol():
	var camara_gol = get_node("CamaraGol")
	if camara_gol:
		camara_gol.current = true
		var anim = get_node_or_null("AnimationPlayer")
		if anim:
			anim.play("camaraGol1")
			
@rpc("call_remote")
func volver_a_camara_jugador():
	for child in get_children():
		if child.name.begins_with("Jugador"):
			if child.get_multiplayer_authority() == multiplayer.get_unique_id():
				var cam_jugador = child.get_node_or_null("Camera3D")
				if cam_jugador:
					cam_jugador.current = true
