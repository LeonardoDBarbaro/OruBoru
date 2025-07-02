extends VBoxContainer

func _on_salir_pressed():
	get_tree().quit()

func _on_crear_partida_pressed():
	visible = false

func _on_buscar_partida_pressed():
	visible = false

func _on_opciones_pressed():
	visible = false

func _on_menu_tree_exited() -> void:
	Save.guardar_configuracion()
