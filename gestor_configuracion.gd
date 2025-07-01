# GestorConfiguracion.gd
extends Node

var resoluciones := [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]


func aplicar_todo():
	aplicar_modo_pantalla()
	aplicar_resolucion()
	aplicar_volumen()
	aplicar_calidad()

func aplicar_modo_pantalla():
	var modo = Save.get_opcion("ModoPantalla")
	match modo:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func aplicar_resolucion():
	var index = Save.get_opcion("Resolucion")
	if index >= 0 and index < resoluciones.size():
		DisplayServer.window_set_size(resoluciones[index])

func aplicar_volumen():
	var vol_musica = linear_to_db(Save.get_opcion("Musica") / 100.0)
	var vol_sfx = linear_to_db(Save.get_opcion("Sonido") / 100.0)
	
	var i_musica = AudioServer.get_bus_index("Musica")
	var i_sfx = AudioServer.get_bus_index("Sonido")
	if i_musica != -1:
		AudioServer.set_bus_volume_db(i_musica, vol_musica)
	if i_sfx != -1:
		AudioServer.set_bus_volume_db(i_sfx, vol_sfx)

func aplicar_calidad():
	var calidad = Save.get_opcion("Calidad")
	var env = get_viewport().environment
	if not env:
		return
	
	match calidad:
		0:  # Bajo
			env.ssao_enabled = false
			env.glow_enabled = false
			env.adjustment_enabled = false
			env.ssr_enabled = false
			env.fog_enabled = false
			env.exposure_enabled = false
		1:  # Medio
			env.ssao_enabled = true
			env.glow_enabled = false
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.0
			env.adjustment_contrast = 1.1
			env.ssr_enabled = false
			env.fog_enabled = true
			env.exposure_enabled = true
			env.exposure_multiplier = 1.0
		2:  # Alto
			env.ssao_enabled = true
			env.glow_enabled = true
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.1
			env.adjustment_contrast = 1.3
			env.ssr_enabled = true
			env.fog_enabled = true
			env.exposure_enabled = true
			env.exposure_multiplier = 1.3
