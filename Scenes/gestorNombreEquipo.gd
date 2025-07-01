extends VBoxContainer

func _on_scroll_colores_equipo_cambiado(equipo_node: Variant, posicion: Variant) -> void:
	get_node("Nombre").set_text(equipo_node.nombre)
	get_node("Abreviacion").set_text(equipo_node.abreviacion)
