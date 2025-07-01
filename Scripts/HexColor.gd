extends LineEdit

@onready var _hex_re := RegEx.new()

func _ready() -> void:
	_hex_re.compile("^[A-Fa-f0-9]$")   # un solo dígito hex
	max_length = 6                     # 6 dígitos RGB
	text = "000000"                    # valor inicial
	caret_column = 0                   # empieza al principio

func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventKey and ev.pressed and not ev.echo:
		# ──────────── teclas especiales ────────────
		match ev.keycode:
			KEY_BACKSPACE:
				if caret_column > 0:
					
					caret_column -= 1
					var caret = caret_column
					# sustituye la posición por '0'
					text = text.substr(0, caret_column) + "0" + text.substr(caret_column + 1)
					caret_column = caret
				accept_event()
				return
			KEY_LEFT, KEY_RIGHT, KEY_HOME, KEY_END:
				return   # deja que LineEdit maneje las flechas/Home/End

		# ignora atajos con Ctrl/Alt/Meta
		if ev.ctrl_pressed or ev.alt_pressed or ev.meta_pressed:
			return

		# ──────────── sobre-escritura del dígito ────────────
		var ch := ev.as_text()
		if not _hex_re.search(ch):
			accept_event()
			return

		var pos := caret_column
		if pos >= max_length:
			accept_event()
			return

		text = text.substr(0, pos) + ch + text.substr(pos + 1)
		caret_column = pos + 1
		accept_event()

# ──────────────────────────────────────
#  Actualización del texto vía sliders
# ──────────────────────────────────────
func _on_slider_r_value_changed(value: float) -> void:
	text = "%02X" % int(value) + text.right(4)

func _on_slider_g_value_changed(value: float) -> void:
	text = text.left(2) + "%02X" % int(value) + text.right(2)

func _on_slider_b_value_changed(value: float) -> void:
	text = text.left(4) + "%02X" % int(value)
