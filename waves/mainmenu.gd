extends TextureFrame

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var file=File.new()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_TextureButton_pressed():
	get_node("/root/global").fraction=true
	get_tree().change_scene("Worldmap.tscn")
	pass # replace with function body


func _on_TextureButton1_pressed():
	get_node("/root/global").fraction=false
	get_tree().change_scene("Worldmap.tscn")
	pass # replace with function body


func _savesCheck():
	var index=0
	while(file.file_exists(str("Saves/save",index+1,".save"))):
		index+=1
	global.saveamount=index
	pass

func _on_Button_pressed():
	_savesCheck()
	for i in range(global.saveamount):
		if(i>=get_node("Popup/Panel/ScrollContainer/VBoxContainer").get_button_count()):
			get_node("Popup/Panel/ScrollContainer/VBoxContainer").add_button(str("save ",i+1))
	get_node("Popup").popup()
	pass # replace with function body


func _loadGame(number):
	var filename=str("Saves/save",number,".save")
	file.open(filename,file.READ)
	global.Points=int(file.get_line())
	global.Cash=int(file.get_line())
	global.Level=int(file.get_line())
	global.fraction=bool(file.get_line())
	global.position=int(file.get_line())
	global.playerhealth=int(file.get_line())
	global.maxplayerhealth=int(file.get_line())
	global.won=int(file.get_line())
	var shipAddonssize=int(file.get_line())
	for i in range(shipAddonssize):
		global.shipAddons.push_back(file.get_line())
	file.close()
	_savesCheck()
	pass

func _on_Load_pressed():
	if(get_node("Popup/Panel/ScrollContainer/VBoxContainer").get_button_count()>0):
		_loadGame(get_node("Popup/Panel/ScrollContainer/VBoxContainer").get_selected()+1)
		get_tree().change_scene("Worldmap.tscn")
	pass # replace with function body


func _on_Credits_pressed():
	get_node("Label 2").show()
	get_node("RichTextLabel").show()
	pass # replace with function body
