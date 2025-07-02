extends AnimationPlayer

var is_jumping = false
var last_anim = ""
@export var current_anim: String = "idle"

@onready var anim_tree = $"../AnimationTree"
@onready var anim_state = anim_tree.get("parameters/playback")

func _ready():
	var player = get_parent()
	player.connect("jumped", Callable(self, "_on_jumped"))
	player.connect("jumped2", Callable(self, "_on_jumped2"))
	player.connect("landed", Callable(self, "_on_landed"))
	player.connect("running", Callable(self, "_on_running"))
	player.connect("cameraMov", Callable(self, "_on_rotating"))
	player.connect("kickL", Callable(self, "_on_KickingL"))
	player.connect("kickR", Callable(self, "_on_KickingR"))
	player.connect("Triste", Callable(self, "_on_Triste"))
	player.connect("Gol", Callable(self, "_on_Gol"))
	anim_tree.active = true

# Función RPC que ejecutan todos los jugadores
@rpc("any_peer")
func sync_animation(anim_name: String):
	anim_state.travel(anim_name)

# Métodos que cambian la animación y la sincronizan
func _on_jumped():
	_send_anim("JumpStart")
#
func _on_jumped2():
	_send_anim("DobleSalto")

func _on_landed():
	_send_anim("Idle")

func _on_running():
	_send_anim("Run")

func _on_rotating():
	_send_anim("Run")
#
#func _on_KickingL():
	#_send_anim("KickL")
#
func _on_HeadButt():
	_send_anim("HeadButt")
	
func _on_KickingL():
	_send_anim("KickL")
	
func _on_KickingR():
	_send_anim("KickR")
	
func _on_Triste():
	_send_anim("Triste")

func _on_Gol():
	_send_anim("Gol")

# Envía animación si es el jugador dueño
func _send_anim(anim_name: String):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		anim_state.travel(anim_name)
		rpc("sync_animation", anim_name)
