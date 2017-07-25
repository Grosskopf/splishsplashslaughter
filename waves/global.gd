extends Node

var Points=0
var Cash=0
var Level=0
var fraction=true
var position=0
var saveamount=0
var playerhealth=20
var maxplayerhealth=20
var won=false
var shipAddons=StringArray()

var musicpos=0


func _ready():
	pass

func addPoints(amount):
	Points+=amount
	if(get_tree().get_root().has_node("Interface")):
		var root = get_tree().get_root()
		root.get_node("Interface/Label2").set_text(str("Score: ",Points))

func addCash(amount):
	Cash+=amount
	if(get_tree().get_root().has_node("Interface")):
		var root = get_tree().get_root()
		get_node("Interface/Label").set_text(str(Cash))

func levelUp():
	Level+=1
	

func addItem(string):
	shipAddons.append(string)

func hasItem(item):
	for i in range(shipAddons.size()):
		if(shipAddons[i]==item):
			return true
	return false