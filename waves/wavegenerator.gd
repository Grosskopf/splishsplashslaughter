extends Polygon2D

var water = Vector2Array([Vector2(960,540),Vector2(-960,540)])
var waterUV = Vector2Array([Vector2(1920,0),Vector2(0,0)])
var waveleft = FloatArray()
var waveright = FloatArray()
var timer = 0
var canonballpos = Vector2(0,0)
var canonballvelocity = Vector2(0,0)
var dmgtimer=0
var dmgfactor=0

var hasBigGunPlayer=false

var enemyhealth=20
var maxenemyhealth=20
var right=false

var enemyhit=false
var playerhit=false

var power=0
var firing=false

var mousepos=Vector2(0,0)

func _ready():
	get_parent().get_node("Interface/Label").set_text(str(get_node("/root/global").Cash))
	get_parent().get_node("Interface/Label2").set_text(str("Score: ",get_node("/root/global").Points))
	for i in range (241):
		waveleft.append(0*10*sin(i/5))
	for i in range (241):
		waveright.append(0*11*sin(i/5.0))
	for i in range (241):
		water.append(Vector2((i-120)*8,0))
		waterUV.append(Vector2(i*8,540))
	self.set_polygon(water)
	self.set_fixed_process(true)
	self.set_process_input(true)
	if(!get_node("/root/global").fraction):
		var texture = get_parent().get_node("Enemy").get_texture()
		get_parent().get_node("Enemy").set_texture(get_parent().get_node("Character").get_texture())
		get_parent().get_node("Character").set_texture(texture)
	canonset(0)
#	global.maxplayerhealth=40
#	global.addItem("Big Gun")
	if(global.maxplayerhealth==40):
		get_parent().get_node("Character/Shield").show()
	if(global.hasItem("Big Gun")):
		hasBigGunPlayer=true
		get_parent().get_node("Character/Node2D").set_modulate(Color(1,0,0))
	if((!global.fraction and global.Level>7) or (global.Level>2 and global.fraction)):
		get_parent().get_node("Enemy/Node2D1").set_modulate(Color(1,0,0))
	if((global.fraction and global.Level>7) or (global.Level>2 and !global.fraction)):
		get_parent().get_node("Enemy/Shield").show()
		maxenemyhealth+=20
		enemyhealth+=20
	get_parent().get_node("StreamPlayer").play(global.musicpos)
	pass

func _fixed_process(delta):
	timer+=delta
	for i in range (241):
		if(i!=0): # right defines, if the wave is moving right (or left)
			waveright[i]=(waveright[i-1]+waveright[i])*0.5
			waveleft[240-i]=(waveleft[240-i+1]+waveleft[240-i])*0.5
		water[i+2]=Vector2(Vector2((i-120)*8,waveleft[i]*2+waveright[i]*2))
		if(i==0 or i==240):
			waveleft[i]/=2
			waveright[i]/=2
			water[i+2]=Vector2((i-120)*8,water[i+2].y/2)
	self.set_polygon(water)
	get_parent().get_node("Waterforeground").set_polygon(water)
	self.set_uv(waterUV)
	get_parent().get_node("Waterforeground").set_uv(waterUV)
	var posy1=water[21].y
	var posy2=water[219].y
	var rot1=atan((water[22].y-posy1)/8)
	var rot2=atan((water[220].y-posy2)/8)
	get_parent().get_node("Enemy").set_pos(Vector2(1770,((posy2+540)+get_parent().get_node("Enemy").get_pos().y)/2))
	get_parent().get_node("Enemy").set_rot((-rot2+get_parent().get_node("Enemy").get_rot())/2)
	get_parent().get_node("Character").set_pos(Vector2(150,((posy1+540)+get_parent().get_node("Character").get_pos().y)/2))
	get_parent().get_node("Character").set_rot((-rot1+get_parent().get_node("Character").get_rot())/2)
	if(get_parent().get_node("Canonball").is_visible()):
		var canonballposnew=canonballpos+delta*canonballvelocity
		var waterx = int(1+canonballpos.x/8)
		var waterheight=540
		if(waterx<water.size()):
			waterheight=540+water[waterx].y
		if(canonballposnew.y>waterheight and canonballpos.y<=waterheight):
			_splash(canonballposnew)
			canonballvelocity=Vector2(canonballvelocity.x*0.5,canonballvelocity.y*0.75)
			print(canonballvelocity)
		canonballpos=canonballposnew
		get_parent().get_node("Canonball").set_pos(canonballpos)
		canonballvelocity.y+=delta*200
		if(get_parent().get_node("Canonball").get_pos().y>1080 and canonballvelocity.x<0):
			get_parent().get_node("Canonball").set_hidden(true)
			get_parent().get_node("Loadcanon/Canonball").show()
		elif(get_parent().get_node("Canonball").get_pos().y>1080):
			var length = randf()*300+400
			var globalrot = randf()*3*PI/8
			canonballvelocity = length*Vector2(-1,-tan(globalrot))/Vector2(1,tan(globalrot)).length()
			canonballpos=get_parent().get_node("Enemy/Node2D1").get_global_pos()
			if(!global.fraction):
				get_parent().get_node("StreamPlayer2").play()
			else:
				get_parent().get_node("StreamPlayer1").play()
	
	else:
		if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
			firing=true
			if(power<100):
				power+=1
				canonset(power/100.0)
		elif(firing==true):
			var rotcanon=atan((-mousepos.y+get_parent().get_node("Character/Node2D").get_global_pos().y)/(mousepos.x-get_parent().get_node("Character/Node2D").get_global_pos().x))-get_parent().get_node("Character").get_rot()
			if(rotcanon>PI/8 and rotcanon<PI/2):
				fire(mousepos-get_parent().get_node("Character/Node2D").get_global_pos(),power)
				
			elif(rotcanon<PI/2 and get_parent().get_node("Character/Node2D").get_global_pos().x<mousepos.x):
				var globalrot=-PI/8+get_parent().get_node("Character").get_rot()
				fire(Vector2(1,tan(globalrot))/Vector2(1,tan(globalrot)).length(),power)
	if dmgfactor!=0:
		if(dmgtimer<0 and enemyhit):
			enemyhealth-=4*dmgfactor
			if(enemyhealth<0):
				get_parent().get_node("PopupDialog").popup()
				get_node("/root/global").addPoints(100)
				get_node("/root/global").addCash(100)
				get_node("/root/global").levelUp()
				get_parent().get_node("Interface/Label").set_text(str(get_node("/root/global").Cash))
				get_parent().get_node("Interface/Label2").set_text(str("Score: ",get_node("/root/global").Points))
				global.musicpos=get_parent().get_node("StreamPlayer").get_pos()
				get_tree().change_scene("Worldmap.tscn")
			else:
				get_parent().get_node("Enemy/ProgressBar").set_value(100*enemyhealth/maxenemyhealth)
				get_parent().get_node("Enemy").set_offset(Vector2(0,-40*enemyhealth/maxenemyhealth))
				get_parent().get_node("Enemy/Shield").set_offset(Vector2(0,30-40*enemyhealth/maxenemyhealth))
			enemyhit=false
			dmgfactor=0
		elif(dmgtimer<0 and playerhit):
			global.playerhealth-=4*dmgfactor
			if(global.playerhealth<0):
				get_parent().get_node("PopupDialog1").popup()
				get_parent().set_pause_mode(get_parent().PAUSE_MODE_STOP)
			else:
				get_parent().get_node("Character/ProgressBar1").set_value(100*global.playerhealth/global.maxplayerhealth)
				get_parent().get_node("Character").set_offset(Vector2(0,-40*global.playerhealth/global.maxplayerhealth))
				get_parent().get_node("Character/Shield").set_offset(Vector2(0,30-40*global.playerhealth/global.maxplayerhealth))
			playerhit=false
			dmgfactor=0
		dmgtimer-=delta
	

func _input(event):
	var rotcanon=atan((-mousepos.y+get_parent().get_node("Character/Node2D").get_global_pos().y)/(mousepos.x-get_parent().get_node("Character/Node2D").get_global_pos().x))-get_parent().get_node("Character").get_rot()
	if(event.type==InputEvent.MOUSE_MOTION):
		mousepos=event.pos
		if(rotcanon>PI/8 and rotcanon<PI/2):
			get_parent().get_node("Character/Node2D").set_rot(rotcanon-PI/2)
	if(event.type==InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and get_parent().get_node("Canonball").is_hidden()):
		mousepos=event.pos

func fire(dir, power):
	if(global.fraction):
		get_parent().get_node("StreamPlayer2").play()
	else:
		get_parent().get_node("StreamPlayer1").play()
	canonballpos = get_parent().get_node("Character/Node2D").get_global_pos()
	canonballvelocity=power*8*dir/dir.length()
	get_parent().get_node("Canonball").set_hidden(false)
	firing=false
	self.power=0
	canonset(0)
	get_parent().get_node("Loadcanon/Canonball").hide()

func canonset(fac):
	
	get_parent().get_node("Loadcanon/fillament").set_pos(Vector2(-155,46)+Vector2(108,-31)*fac)
	get_parent().get_node("Loadcanon/fillament").set_scale(Vector2(1,0.1+0.9*fac))
	get_parent().get_node("Loadcanon/Canonball").set_pos(Vector2(-135,36)+Vector2(212,-62)*fac)

func _splash(pos):
	var particlesystem = get_parent().get_node("splash")
	particlesystem.set_pos(pos)
	particlesystem.set_emitting(true)
	var waterx = int(1+canonballpos.x/8)
	var factor=1
	if(hasBigGunPlayer):
		particlesystem.set_emit_timeout(1)
		factor=2
	else:
		particlesystem.set_emit_timeout(0.5)
	if(waterx>5 and waterx<water.size()-3 and canonballvelocity.x<0):
		waveleft[waterx-5]=waveleft[waterx-5]+80*factor
		waveleft[waterx-4]=waveleft[waterx-4]+120*factor
		waveleft[waterx-3]=waveleft[waterx-3]-80*factor
		waveleft[waterx-2]=waveleft[waterx-2]-120*factor
		waveleft[waterx-1]=waveleft[waterx-1]-100*factor
		waveleft[waterx]=waveleft[waterx]*factor
		waveleft[waterx+1]=waveleft[waterx+1]+100*factor
	elif(waterx>5 and waterx<water.size()-3):
		waveright[waterx-5]=waveright[waterx-5]+100*factor
		waveright[waterx-4]=waveright[waterx-4]*factor
		waveright[waterx-3]=waveright[waterx-3]-100*factor
		waveright[waterx-2]=waveright[waterx-2]-120*factor
		waveright[waterx-1]=waveright[waterx-1]-80*factor
		waveright[waterx]=waveright[waterx]+120*factor
		waveright[waterx+1]=waveright[waterx+1]+80*factor
	if(canonballvelocity.x>0):
		right=true
		particlesystem.set_param(particlesystem.PARAM_DIRECTION, 160)
	else:
		right=false
		particlesystem.set_param(particlesystem.PARAM_DIRECTION, 200)
	var dmgfactortmp=0
	if(pos.x<1706 and pos.x>1610 and canonballvelocity.x > 0):
		dmgfactortmp=1-(pos.x-1610)/96
		enemyhit=true
	elif(pos.x<1706 and pos.x>1535 and canonballvelocity.x > 0):
		dmgfactortmp=1
		enemyhit=true
	elif(pos.x<1706 and pos.x>1439 and canonballvelocity.x > 0):
		dmgfactortmp=(pos.x-1439)/96
		enemyhit=true
	if(pos.x>214 and pos.x<310 and canonballvelocity.x < 0):
		dmgfactortmp=(pos.x-214)/96
		playerhit=true
	elif(pos.x>214 and pos.x<385 and canonballvelocity.x < 0):
		dmgfactortmp=1
		playerhit=true
	elif(pos.x>214 and pos.x<481 and canonballvelocity.x < 0):
		dmgfactortmp=1-((pos.x-385)/96)
		playerhit=true
	if(dmgfactortmp!=0):
		dmgfactor=dmgfactortmp
		if((enemyhit and hasBigGunPlayer) or (playerhit and global.Level>2 and global.fraction) or (playerhit and global.Level>7 and !global.fraction)):
			dmgfactor*=2
		dmgtimer=1.3
	pass
