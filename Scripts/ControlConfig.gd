extends Button

@export var scalex : float = 0.1
@export var scaley : float = 0.1
const TEX_BASE := "res://Images/Botones/Control" 
@export var botonActual = JOY_BUTTON_DPAD_DOWN

# --- mapeo de botones (índice → sufijo PNG) ---
var BTN_NAME : Dictionary = {
	JOY_BUTTON_A:               "A",
	JOY_BUTTON_B:               "B",
	JOY_BUTTON_X:               "X",
	JOY_BUTTON_Y:               "Y",
	JOY_BUTTON_LEFT_SHOULDER:   "LB",
	JOY_BUTTON_RIGHT_SHOULDER:  "RB",
	JOY_BUTTON_BACK:            "Select",
	JOY_BUTTON_START:           "Start",
	JOY_BUTTON_DPAD_UP:         "Up",
	JOY_BUTTON_DPAD_DOWN:       "Down",
	JOY_BUTTON_DPAD_LEFT:       "Left",
	JOY_BUTTON_DPAD_RIGHT:      "Right",
}

var AXIS_NAME : Dictionary = {
	JOY_AXIS_TRIGGER_LEFT:  "LT",
	JOY_AXIS_TRIGGER_RIGHT: "RT",
}

var listening := false

func _ready() -> void:
	toggle_mode = true
	focus_mode  = FOCUS_ALL
	grab_click_focus()

func _on_toggled(on: bool) -> void:
	listening = on
	if on:
		grab_focus()
		$Tecla.scale = Vector2(scalex * 1.25, scaley * 1.25)
	else:
		$Tecla.scale = Vector2(scalex, scaley)
		grab_focus()

func _gui_input(event: InputEvent) -> void:
	if not listening:
		return

	if event is InputEventJoypadButton and event.pressed:
		_process_name(BTN_NAME.get(event.button_index))
		accept_event()                         # detiene navegación UI

	elif event is InputEventJoypadMotion \
			and abs(event.axis_value) > 0.5:   # “pulsado” el gatillo
		_process_name(AXIS_NAME.get(event.axis))
		accept_event()

func _process_name(nameKey: String) -> void:
	if nameKey == null:
		return
	var tex_path := "%s%s.png" % [TEX_BASE, nameKey]
	if ResourceLoader.exists(tex_path):
		$Tecla.texture = load(tex_path)
	else:
		push_warning("Falta textura: %s" % tex_path)
	button_pressed = false
