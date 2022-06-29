extends Node

func setFullscreen(state : bool):
	OS.set_window_fullscreen(state);
	DataManager.saveFullscreen(state);
