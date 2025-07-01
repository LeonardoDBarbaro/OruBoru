extends Control

@onready var Equipos 		= get_node("data/Equipos")
@onready var NombreServidor = get_node("data/NombreServidor")
@onready var Cancha 		= get_node("data/Cancha")
@onready var Estado 		= get_node("data/Estado")
@onready var Jugadores		= get_node("data/Jugadores")
@onready var Tiempo 		= get_node("data/Tiempo")
@onready var serverData		= get_node("nodata/servidor")
@onready var http := HTTPRequest.new()

@onready var refresher_timer  = Timer.new() 
@onready var SERVER_IP   = get_parent().get_parent().get_parent().get_parent().get_node("NUEVA IP/DirIP").get_text()
@onready var SERVER_PORT = get_parent().get_parent().get_parent().get_parent().get_node("NUEVA IP/PUERTO").get_text()

@export var refresh_interval_seconds := 5.0 
# --- Configuración ---
const ENDPOINT    := "/servidor.json"

func _ready() -> void:
	get_node("data").visible = false
	get_node("nodata").visible = true
	get_node("nodata/AnimationPlayer").play("giro")
	add_child(http)
	# Configurar timeout
	http.timeout = 3.0  # tiempo máximo de espera en segundos

	# Conectar el HTTPRequest
	http.request_completed.connect(_on_request_completed)

	# Crear y configurar el Timer
	refresher_timer.one_shot = false
	refresher_timer.wait_time = refresh_interval_seconds
	refresher_timer.timeout.connect(_request_server)
	add_child(refresher_timer)
	refresher_timer.start()

	_request_server()

func _request_server() -> void:
	if not is_visible_in_tree(): return
	if http.get_http_client_status() == HTTPClient.STATUS_REQUESTING:
		return
	var url := "http://%s:%s%s" % [SERVER_IP, SERVER_PORT, ENDPOINT]
	http.request(url)

func _on_request_completed(_result, response_code, _headers, body):
	serverData.set_text("%s:%s"% [SERVER_IP, SERVER_PORT])
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			var datos = json
			Equipos.set_text(datos["equipos"])
			NombreServidor.set_text(datos["nombre_servidor"])
			Cancha.set_text(datos["cancha"])
			Estado.set_text(datos["estado"])
			Jugadores.set_text(str(int(datos["jugadores_actuales"])) + "/" + str(int(datos["jugadores_totales"])))
			Tiempo.set_text(datos["tiempo"])
			get_node("data").visible = true
			get_node("nodata").visible = false
			get_node("nodata/AnimationPlayer").stop()
		else:
			print("Error al parsear el JSON")
	else:
		get_node("data").visible = false
		get_node("nodata").visible = true
		get_node("nodata/AnimationPlayer").play("giro")
