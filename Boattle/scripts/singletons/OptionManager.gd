extends Node

func setFullscreen(state : bool):
	OS.set_window_fullscreen(state);
	DataManager.saveFullscreen(state);

func setVsync(state : bool):
	OS.set_use_vsync(state);
	DataManager.saveVsync(state);
