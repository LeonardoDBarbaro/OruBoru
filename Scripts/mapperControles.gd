extends VBoxContainer

var botones : Array = [
	KEY_W,          # Adelante
	KEY_A,          # Izquierda
	KEY_S,          # Atrás
	KEY_D,          # Derecha
	KEY_SPACE,      # Salto
	KEY_CTRL,       # Tiro alto
	KEY_1,          # Emote 1
	KEY_2,          # Emote 2
	KEY_3,          # Emote 3
	KEY_T,          # Chat grupal
	KEY_Y           # Chat global
]

var controles : Array = [
	null,           # Adelante
	null,           # Izquierda
	null,           # Atrás
	null,           # Derecha
	JOY_BUTTON_A,   # Salto
	JOY_BUTTON_LEFT_SHOULDER,         # Tiro alto (LT)
	JOY_BUTTON_DPAD_UP,    # Emote 1
	JOY_BUTTON_DPAD_LEFT,  # Emote 2
	JOY_BUTTON_DPAD_DOWN,  # Emote 3
	null,           # Chat grupal
	null            # Chat global
]

func _ready():
	inputPredeterminado()

func inputPredeterminado():
	var iteracion = 0
	for control in get_children():
		var botonTeclado = control.get_node("Button2")
		var botonControl = control.get_node("Button3")
		botonTeclado.teclaActual = botones[iteracion]
		botonTeclado._cargar_textura(botonTeclado.teclaActual)
		botonControl.botonActual = controles[iteracion]
		if controles[iteracion] != null:
			botonControl._process_name(botonControl.BTN_NAME.get(controles[iteracion]))
		iteracion += 1

func _on_reestablecer_pressed():
	inputPredeterminado()
