extends AnimationPlayer

@onready var anim2 : AnimationPlayer =   get_parent().get_node("AnimationPlayer2")
@onready var Controles = get_parent().get_node("MenuConfiguracion/Opciones/HBoxContainer/Opciones/Controles")
@onready var equipo = get_parent().get_node("MenuConfiguracion/Opciones/HBoxContainer/Opciones/Equipos")
var transition_state = 0
var option_state = 0

func _on_crear_partida_pressed():
	transicion()
	await animation_finished
	if transition_state == 0:
		anim2.play("fadeIn")
		await get_tree().process_frame
	transition_state = 1
	play("MenuCrearPartida1_Aparecer")
	
func _on_buscar_partida_pressed():
	transicion()
	await animation_finished
	if transition_state == 0:
		anim2.play("fadeIn")
		await get_tree().process_frame
	transition_state = 3
	play("MenuBuscarPartida_Aparecer")

func _on_opciones_pressed():
	transicion()
	await animation_finished
	if transition_state == 0:
		anim2.play("fadeIn")
		await get_tree().process_frame
	transition_state = 4
	play("MenuConfiguracionON")
	
func transicion():
	match(transition_state):
		0: play("Transicion_MenuPrincipal")
		1: play("MenuCrearPartida1_DesaparecerNO")
		2: play("CrearPartida2OUT")
		3: play("MenuBuscarPartida_Desaparecer")
		4: play("MenuConfiguracionOFF")
		5: play("nada")

func _on_controles_toggled(toggled_on):
	if toggled_on:
		if option_state == 2:
			deshabilitacion(true)
			play("EquipoSlideOff")
			await animation_finished
		play("ControlesSlideOn")
		await animation_finished
		deshabilitacion(false)
		option_state = 1
		
	else:
		play("ControlesSlideOff")
		await animation_finished
		option_state = 3

func _on_equipos_toggled(toggled_on):
	if toggled_on:
		if option_state == 1:
			deshabilitacion(true)
			play("ControlesSlideOff")
			await animation_finished
		play("EquipoSlideOn")
		await animation_finished
		deshabilitacion(false)
		option_state = 2
	else:
		play("EquipoSlideOff")
		await animation_finished
		option_state = 3

func volverMenuBuscar():
	play("fadeIn_2")
	await get_tree().create_timer(1.5).timeout
	get_parent().get_node("FondoCuadrille").visible = true
	play("fadeIn")
	await animation_finished
	play("MenuBuscarPartida_Aparecer")

func _on_boton_continuar_menu_crear_partida_pressed():
	play("MenuCrearPartida1_DesaparecerSI")
	await animation_finished
	transition_state = 2
	play("CrearPartida2IN")

func _on_volver_pressed():
	play("CrearPartida2OUT")
	await animation_finished
	play("MenuCrearPartida1_Aparecer")

func deshabilitacion(boolin):
	Controles.disabled = boolin
	equipo.disabled = boolin

func _on_iniciar_pressed() -> void:
	play("CrearPartida2OUT")
	transition_state = 5
	await animation_finished
	play("fadeIn_2")
	await animation_finished
	play("fadeIn")

func _on_boton_conectar_menu_buscar_servidores_pressed() -> void:
	play("MenuBuscarPartida_Desaparecer")
	transition_state = 5
	await animation_finished
	play("fadeIn_2")
	await animation_finished
	play("fadeIn")
