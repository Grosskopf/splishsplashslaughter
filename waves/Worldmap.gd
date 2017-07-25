extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var position=0
var loadedtexture=0
var moving = false

var goals=FloatArray()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	position=get_node("/root/global").position
	if(get_node("/root/global").fraction):
		get_node("Path2D/PathFollow2D10").set_offset(0)
		goals=[3040,2600,2320,1950,1700,1200,900,350,0]
	else:
		get_node("Path2D/PathFollow2D10").set_offset(3450)
		goals=[350,900,1200,1700,1950,2320,2600,3040,3450]
		
	var actualpos
	if(get_node("/root/global").fraction):
		get_node("Path2D/PathFollow2D2").set_offset(3450-position)
	else:
		get_node("Path2D/PathFollow2D2").set_offset(10+position)
	var nextpos=get_node("Path2D/PathFollow2D2").get_pos()
	var thispos=get_node("Path2D/PathFollow2D").get_pos()
	var dir=nextpos-thispos
	if(dir.x>abs(dir.y) ):
		if(get_node("/root/global").fraction):
			setTexture(0)
		else:
			setTexture(4)
	elif(-dir.y>abs(dir.x)):
		if(get_node("/root/global").fraction):
			setTexture(1)
		else:
			setTexture(5)
	elif(-dir.x>abs(dir.y)):
		if(get_node("/root/global").fraction):
			setTexture(2)
		else:
			setTexture(6)
	else:
		if(get_node("/root/global").fraction):
			setTexture(3)
		if(get_node("/root/global").fraction):
			setTexture(7)
	position+=10
	if(get_node("/root/global").fraction):
		actualpos=3460-position
	else:
		actualpos=position
	
	get_node("Path2D/PathFollow2D").set_offset(actualpos)
	updateinterface()
	get_node("StreamPlayer").play(global.musicpos)
	pass
	
func updateinterface():
	
	if(global.Level<=1):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D 2/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D9/Sprite").hide()
	elif(global.Level<=2):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D3/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D8/Sprite").hide()
	elif(global.Level<=3):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D4/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D7/Sprite").hide()
	elif(global.Level<=4):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D5/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D6/Sprite").hide()
	elif(global.Level<=5):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D6/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D5/Sprite").hide()
	elif(global.Level<=6):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D7/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D4/Sprite").hide()
	elif(global.Level<=7):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D8/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D3/Sprite").hide()
	elif(global.Level<=8):
		if(!global.fraction):
			get_node("Path2D/PathFollow2D9/Sprite").hide()
		else:
			get_node("Path2D/PathFollow2D 2/Sprite").hide()
	elif(global.Level<=9):
		get_node("Path2D/PathFollow2D10/Sprite").hide()
		if(global.won!=true):
			get_node("Wonscreen").popup()
			global.won=true
	
	get_node("Interface/Label").set_text(str(get_node("/root/global").Cash))
	get_node("Interface/Label2").set_text(str("Score: ",get_node("/root/global").Points))

func setTexture(number):
	if(loadedtexture!=number):
		var texture=ImageTexture.new()
		if(number==0):
			texture.load(str("res://Schiff_horizontal_r.png"))
		elif(number==1):
			texture.load(str("res://Schiff_vertical_down.png"))
		elif(number==2):
			texture.load(str("res://Schiff_horizontal.png"))
		elif(number==3):
			texture.load(str("res://Schiff_vertical_up.png"))
		elif(number==4):
			texture.load(str("res://Schiff_2_horizontal_r.png"))
		elif(number==5):
			texture.load(str("res://Schiff_2_vertical_down.png"))
		elif(number==6):
			texture.load(str("res://Schiff_2_horizontal.png"))
		else:
			texture.load(str("res://Schiff_2_vertical_up.png"))
		get_node("Path2D/PathFollow2D/Sprite").set_texture(texture)
		loadedtexture=number
	pass

func _process(delta):
	if(position<3460 and moving):
		var actualpos
		if(get_node("/root/global").fraction):
			get_node("Path2D/PathFollow2D2").set_offset(3450-position)
		else:
			get_node("Path2D/PathFollow2D2").set_offset(10+position)
		var nextpos=get_node("Path2D/PathFollow2D2").get_pos()
		var thispos=get_node("Path2D/PathFollow2D").get_pos()
		var dir=nextpos-thispos
		if(dir.x>abs(dir.y) ):
			if(get_node("/root/global").fraction):
				setTexture(0)
			else:
				setTexture(4)
		elif(-dir.y>abs(dir.x)):
			if(get_node("/root/global").fraction):
				setTexture(1)
			else:
				setTexture(5)
		elif(-dir.x>abs(dir.y)):
			if(get_node("/root/global").fraction):
				setTexture(2)
			else:
				setTexture(6)
		else:
			if(get_node("/root/global").fraction):
				setTexture(3)
			if(get_node("/root/global").fraction):
				setTexture(7)
				
		position+=10
		if(get_node("/root/global").fraction):
			actualpos=3460-position
		else:
			actualpos=position
		
		get_node("Path2D/PathFollow2D").set_offset(actualpos)
		var contains = false
		for i in range(9):
			if(goals[i]==actualpos):
				contains=true
		if(contains):
			global.position=self.position
			moving=false
			global.musicpos=get_node("StreamPlayer").get_pos()
			get_tree().change_scene("world.tscn")

func _on_Button1_pressed():
	moving=true
	pass # replace with function body


func _on_ShopButton_pressed():
	get_node("Popup").popup()
	get_node("Popup").update_interface()
	pass # replace with function body


func _on_MenuButton_pressed():
	get_node("Menu").popup()
	pass # replace with function body
