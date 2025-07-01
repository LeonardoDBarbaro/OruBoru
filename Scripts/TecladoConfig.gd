extends Button

@export var scalex: float = 0.1
@export var scaley: float = 0.1
const TEX_BASE := "res://Images/Botones/Teclado"

@export var teclaActual : Key = KEY_0

var listening := false

func _ready() -> void:
	toggle_mode = true
	focus_mode  = FOCUS_ALL
	grab_click_focus()

func _on_toggled(on: bool):
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
	if event is InputEventKey and event.pressed and not event.echo:
		_cargar_textura(event.keycode)
		button_pressed = false
		accept_event()

func _cargar_textura(keycode: Key) -> void:
	var key_name := OS.get_keycode_string(keycode)
	var tex_path := "%s%s.png" % [TEX_BASE, key_name]
	if ResourceLoader.exists(tex_path):
		$Tecla.texture = load(tex_path)
	else:
		push_warning("No existe textura: %s" % key_name)
