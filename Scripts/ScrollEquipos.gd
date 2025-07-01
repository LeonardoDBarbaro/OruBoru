extends ScrollContainer

var tween
@onready var nodoActual
signal scroll_completado(nodo_centrado) 

func scroll_to(target_position: int, duration: float = 0.2):
	tween = create_tween()
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scroll_horizontal", target_position, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	nodoActual = get_nodo_centrado()
	emit_signal("scroll_completado", nodoActual)

func _on_izq_pressed() -> void:
	var gap = get_child_size()
	if scroll_horizontal < gap*get_node("HBoxContainer").get_child_count():
		scroll_to(scroll_horizontal+gap)

func _on_der_pressed() -> void:
	var gap = get_child_size()
	if scroll_horizontal > 0:
		scroll_to(scroll_horizontal-gap)
	
func get_child_size():
	var botonTam = get_node("HBoxContainer/Template").size.x
	var scrollTam = size.x
	var gapTam = (scrollTam-botonTam*3 ) / 2
	return gapTam + botonTam
	
func get_nodo_centrado() -> Control:
	var viewport_center := scroll_horizontal + size.x * 0.5
	
	var hbox      := get_node("HBoxContainer")
	var mejor     : Control = null
	var menor_dist := INF
	
	for child in hbox.get_children():
		if not child is Control:
			continue
		
		var child_center = child.position.x + child.size.x * 0.5
		
		var dist = abs(child_center - viewport_center)
		if dist < menor_dist:
			menor_dist = dist
			mejor = child
	
	return mejor
