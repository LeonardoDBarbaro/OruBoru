extends VBoxContainer

@onready var ROJO = get_node("NumberR")
@onready var VERDE = get_node("NumberG")
@onready var AZUL = get_node("NumberB")

func _on_slider_r_value_changed(value):
	var hex = "%02X" % value
	ROJO.set_text(hex)

func _on_slider_g_value_changed(value):
	var hex = "%02X" % value
	VERDE.set_text(hex)

func _on_slider_b_value_changed(value):
	var hex = "%02X" % value
	AZUL.set_text(hex)
