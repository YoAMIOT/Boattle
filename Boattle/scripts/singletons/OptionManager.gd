extends Node

func setFullscreen(state : bool) -> void:
	OS.set_window_fullscreen(state);
	DataManager.saveFullscreen(state);

func setVsync(state : bool) -> void:
	OS.set_use_vsync(state);
	DataManager.saveVsync(state);

func setWindowSize(size : Vector2) -> void:
	OS.set_window_size(size);
	DataManager.saveWindowSize(size);
