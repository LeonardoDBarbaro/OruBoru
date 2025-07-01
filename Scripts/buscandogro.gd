extends Label

var punto_estado := 0
var punto_timer := Timer.new()

func _ready():
	# Guardar el texto original como metadato para no perderlo
	set_meta("base_text", text)

	punto_timer.wait_time = 0.8
	punto_timer.one_shot = false
	punto_timer.timeout.connect(_actualizar_puntos)
	add_child(punto_timer)

	if is_visible_in_tree():
		punto_timer.start()

	visibility_changed.connect(_verificar_visibilidad)

func _verificar_visibilidad():
	if is_visible_in_tree():
		punto_timer.start()
	else:
		punto_timer.stop()
		text = get_meta("base_text")

func _actualizar_puntos():
	punto_estado = (punto_estado + 1) % 4
	text = get_meta("base_text") + "\n" + ". ".repeat(punto_estado)
