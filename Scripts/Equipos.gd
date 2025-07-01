class_name Equipo
extends Resource

@export var colores     : Array[Color] = []

@export var nombre: String:
	get: return nombre
	set(value):
		nombre = value.strip_edges() 
		
@export var abreviacion: String:
	get: return abreviacion
	set(value):
		abreviacion = value.substr(0, 4).to_upper()   # máx. 3 letras en mayúsculas

func _init(n: String = "", a: String = "", c: Array[Color] = []):
	nombre      = n
	abreviacion = a
	colores     = c
