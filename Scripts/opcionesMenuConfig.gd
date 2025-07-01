extends VBoxContainer

func _ready():
	get_node("ModoPantalla").selected = Save.current["ModoPantalla"]
	get_node("Calidad").selected = Save.current["Calidad"]
	get_node("Resolucion").selected = Save.current["Resolucion"]
	get_node("Musica").value = Save.current["Musica"]
	get_node("Sonido").value = Save.current["Sonido"]
	get_node("Sensibilidad").value = Save.current["Sensibilidad"]
	get_node("Nombre").text = Save.current["Nombre"]	

func _on_modo_pantalla_item_selected(index: int) -> void:
	Save.current["ModoPantalla"] = index
	GestorConfiguracion.aplicar_modo_pantalla()
	if index == 1:
		get_node("Resolucion").disabled = true
	else:
		get_node("Resolucion").disabled = false

func _on_calidad_item_selected(index: int) -> void:
	Save.current["Calidad"] = index

func _on_resolucion_item_selected(index: int) -> void:
	Save.current["Resolucion"] = index
	GestorConfiguracion.aplicar_resolucion()

func _on_musica_drag_ended(value_changed: bool) -> void:
	Save.current["Musica"] = get_node("Musica").value
	GestorConfiguracion.aplicar_volumen()

func _on_sonido_drag_ended(value_changed: bool) -> void:
	Save.current["Sonido"] = get_node("Sonido").value
	GestorConfiguracion.aplicar_volumen()

func _on_sensibilidad_drag_ended(value_changed: bool) -> void:
	Save.current["Sensibilidad"] = get_node("Sensibilidad").value

func _on_nombre_text_changed(new_text: String) -> void:
	Save.current["Nombre"] = new_text
	
