extends ScrollContainer

@onready var servidores_container := $"Servidores"

const LINE_HEIGHT   := 44
const MAX_VISIBLE   := 9

func _on_v_box_container_child_entered_tree(_node):
	call_deferred("_update_size")

func _on_v_box_container_child_exiting_tree(_node):
	call_deferred("_update_size")


func _on_boton_añadir_ip_pressed():
	crearNuevoServidor()

func _on_boton_borrar_menu_buscar_servidores_pressed():
	for servidor in servidores_container.get_children():
		if servidor.has_node("BotonSeleccionServidor"):
			var boton := servidor.get_node("BotonSeleccionServidor")
			if boton.button_pressed:
				servidor.queue_free()

func crearNuevoServidor():
	var indice        := servidores_container.get_child_count()
	var nuevo         := servidores_container.get_node("ServidorBase").duplicate()
	nuevo.name        = "Servidor%s" % indice
	nuevo.visible     = true
	servidores_container.add_child(nuevo)

func _update_size() -> void:
	var cant := servidores_container.get_child_count()
	var filas_visibles = min(cant, MAX_VISIBLE)
	if filas_visibles == 1:
		custom_minimum_size.y = 0
	else:
		custom_minimum_size.y = (filas_visibles - 1)  * LINE_HEIGHT
