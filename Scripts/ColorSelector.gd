extends Control

var last_pressed
var last_action
var prev_color : Color
var colores_guardados : Array[Color] = []
var iteradorPartes = 0

signal shader_modificado

@export var colores : Array[Color] = [
	Color(1, 0, 0),
	Color(0, 1, 1),
	Color(0, 1, 0),
	Color(1, 1, 0),
	Color(1, 0, 1),
	Color(1, 1, 1)
]

func cambioDeEquipo(equipo_node,value):
	colores = equipo_node.colores.duplicate()
	var botones = get_node("Botones").get_children()
	for i in range(min(colores.size(), botones.size())):
		var sb = botones[i].get_theme_stylebox("panel").duplicate()
		botones[i].add_theme_stylebox_override("panel", sb)
		sb.bg_color = colores[i]
		botones[i].queue_redraw()

func _ready():
	var selector = get_parent().get_parent().get_node("Equipos/Selector/ScrollColores")
	selector.connect("equipo_cambiado", Callable(self, "cambioDeEquipo"))
	var botones = get_node("Botones").get_children()
	for boton in botones:
		var sb
		var base = boton.get_theme_stylebox("panel")
		sb = base.duplicate() as StyleBoxFlat
		boton.add_theme_stylebox_override("panel", sb)
		sb.bg_color = colores[iteradorPartes]
		boton.queue_redraw()
		iteradorPartes += 1
	iteradorPartes = 0

func actualizar_color():
	var color_picker = get_node("Mascara/ColorPicker")
	var nodoPanel = get_node("Botones/"+last_pressed)
	color_picker.hexText.text = color_picker.hexText.text.lpad(6, "0")
	nodoPanel.get("theme_override_styles/panel").bg_color = Color(color_picker.hexText.text)
	nodoPanel.queue_redraw()
	var nodoActual = get_parent().get_node("Selector/ScrollColores").getNodoActual()
	var equipo = nodoActual.get_equipo()
	if int(last_pressed) < 1:
		nodoActual.get_node("1").material.set_shader_parameter("center_color",nodoPanel.get("theme_override_styles/panel").bg_color)
	else:
		nodoActual.get_node("1").material.set_shader_parameter("slice%d_color" % (int(last_pressed) -1), nodoPanel.get("theme_override_styles/panel").bg_color)
	equipo.colores[int(last_pressed)] = nodoPanel.get("theme_override_styles/panel").bg_color
	emit_signal("shader_modificado",nodoActual)

func _on_button_pressed():
	last_action = true
	var iterator = 0
	var color_picker = get_node("Mascara/ColorPicker")
	for child in get_node("Botones").get_children():
		if not color_picker.visible:
			colores_guardados.append(colores[iterator]) 
			iterator += 1
		if child.get_node("Button").is_pressed():
			last_pressed = child.name
			prev_color = child.get("theme_override_styles/panel").bg_color
			color_picker.set_color(child.get("theme_override_styles/panel").bg_color)
	
	if not color_picker.visible:
		get_node("AnimationPlayer").play("SlideInColores")
	last_action = false

func _on_slider_r_value_changed(_value): if not last_action: actualizar_color()

func _on_slider_g_value_changed(_value): if not last_action: actualizar_color()

func _on_slider_b_value_changed(_value): if not last_action: actualizar_color()
		
func _on_hex_text_changed(_new_text): if not last_action: actualizar_color()

func _on_slider_r_drag_ended(_value_changed): actualizar_color()

func _on_slider_g_drag_ended(_value_changed): actualizar_color()

func _on_slider_b_drag_ended(_value_changed): actualizar_color()

func _on_color_boton_2_pressed(): rollback_Color()

func rollback_Color():
	if last_pressed == null: return
	last_action = true
	var color_picker = get_node("Mascara/ColorPicker")
	var iterator = 0
	for child in get_node("Botones").get_children():
		var nodoPanel = get_node("Botones/"+child.name)
		nodoPanel.get("theme_override_styles/panel").bg_color = colores_guardados[iterator]
		nodoPanel.queue_redraw()
		color_picker.set_color(colores_guardados[iterator])
		iterator += 1	
	last_action = false


func _on_scroll_colores_equipo_cambiado(equipo_node: Variant, posicion: Variant) -> void:
		if get_node("Mascara/ColorPicker").visible and posicion == 0:
			await get_tree().process_frame
			_on_button_pressed()
