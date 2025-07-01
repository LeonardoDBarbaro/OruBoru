extends OptionButton

func _ready() -> void:
	var screen_id := DisplayServer.window_get_current_screen()
	var max_size := DisplayServer.screen_get_size(screen_id)

	for i in range(item_count - 1, -1, -1):
		var res_text = get_item_text(i)
		var parts = res_text.split("×")
		if parts.size() != 2:
			continue

		var res = Vector2i(parts[0].to_int(), parts[1].to_int())

		if res.x > max_size.x or res.y > max_size.y:
			remove_item(i)
