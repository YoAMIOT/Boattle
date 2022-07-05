extends Control

func _ready() -> void:
	get_node("WindowSizeOption").disabled = DataManager.datas["fullscreen"];
	get_node("FullscreenSwitch").pressed = DataManager.datas["fullscreen"];
	get_node("VSyncSwitch").pressed = DataManager.datas["vSync"];
	manageWindowSizeSelection();

func manageWindowSizeSelection() -> void:
	var size : Vector2 = DataManager.datas["windowSize"];
	var sizeStr : String = String(size.x) + " x " + String(size.y);
	for o in get_node("WindowSizeOption").get_item_count():
		if sizeStr == get_node("WindowSizeOption").get_item_text(o):
			get_node("WindowSizeOption").selected = o;



func _on_FullscreenSwitch_toggled(state : bool) -> void:
	OptionManager.setFullscreen(state);
	get_node("WindowSizeOption").disabled = state;

func _on_VSyncSwitch_toggled(state : bool) -> void:
	OptionManager.setVsync(state);

func _on_WindowSizeOption_item_selected(index : int) -> void:
	var selectedSize : String = get_node("WindowSizeOption").get_item_text(index);
	var firstInt : String = "";
	var secondInt : String = "";
	var size : Vector2;
	var i : int = 0;
	for c in selectedSize:
		i += 1;
		if i < 5:
			firstInt += c;
		elif i > 7:
			secondInt += c;
	size = Vector2(float(firstInt), float(secondInt));
	OptionManager.setWindowSize(size)



func refresh():
	get_node("WindowSizeOption").disabled = DataManager.datas["fullscreen"];
	get_node("FullscreenSwitch").pressed = DataManager.datas["fullscreen"];
	get_node("VSyncSwitch").pressed = DataManager.datas["vSync"];
	manageWindowSizeSelection();



func _on_BackOptionsButton_pressed() -> void:
	if get_parent().get_parent().has_node("Menus"):
		get_parent().get_parent().backOptions();
	elif get_parent().has_node("MainPauseMenu"):
		get_parent().backOptions();
