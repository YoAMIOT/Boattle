extends RichTextLabel

onready var Log = get_node(".");

###Print Function###
func logPrint(newLine) -> void:
	Log.set_bbcode(Log.bbcode_text + "\n" + newLine);
