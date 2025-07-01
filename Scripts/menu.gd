extends VBoxContainer

@onready var anim: AnimationPlayer = get_parent().get_parent().get_node("AnimationPlayer")

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and not event.echo and event.keycode == KEY_ESCAPE:
		if not anim.is_playing():
			get_parent().get_parent().visible = not visible
			visible = not visible

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
