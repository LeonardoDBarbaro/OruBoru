extends Control

signal iniciarPartida
signal entrarPartida(ip)

func _on_iniciar_pressed() -> void:
	emit_signal("iniciarPartida")

func _on_boton_conectar_menu_buscar_servidores_pressed() -> void:
	var grupo = get_node("MenuSelectorPartida/VBoxContainer2/ScrollContainer/Servidores/ServidorBase/BotonSeleccionServidor").button_group
	var seleccionado = grupo.get_pressed_button()
	if not seleccionado: return
	emit_signal("entrarPartida",seleccionado.get_parent().get_node("nodata/servidor").text)
