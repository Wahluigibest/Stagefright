extends Node

var sheet_data

func _ready():
	var sheetdata_file = File.new()
	sheetdata_file.open("res://player/Art sheet - Values.json", File.READ)
	var sheetdata_json = JSON.parse(sheetdata_file.get_as_text())
	sheetdata_file.close()
	sheet_data = sheetdata_json.result
	print(sheet_data)
	
