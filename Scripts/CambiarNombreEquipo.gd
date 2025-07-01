extends HBoxContainer

@onready var sc = get_parent().get_parent().get_node("Selector/ScrollColores")
@onready var nom = get_node("Nombre")
@onready var abr = get_node("Abreviacion")

func _on_scroll_colores_equipo_cambiado(equipo_node: Variant,valor) -> void:
	if valor == 0:
		nom.text = equipo_node.nombre
		abr.text = equipo_node.abreviacion

func _on_nombre_text_changed(new_text: String) -> void:
	var equipo = sc.getNodoActual().get_equipo()
	equipo.nombre = nom.text

func _on_abreviacion_text_changed(new_text: String) -> void:
	var equipo = sc.getNodoActual().get_equipo()
	equipo.abreviacion = abr.text
