extends Node

class_name Cutscenes

@onready var menu: Menu						= $/root/Menu
@onready var character_left_texture_button	= $PanelBottomContainer/BottomHBoxContainer/CharacterLeftTextureButton
@onready var cutscene_label					= $PanelBottomContainer/BottomHBoxContainer/BottomMarginContainer/CutsceneTextureRect/CutsceneMarginContainer/CutsceneLabel
@onready var character_right_texture_button	= $PanelBottomContainer/BottomHBoxContainer/CharacterRightTextureButton

enum CharacterType {PLAYER_1, PLAYER_2, GOODGUY, BADGUY, GOD, DEVIL}

# FIXME
const character_textures: Array[CompressedTexture2D] = [
	preload('res://Assets/aaaps/player_1_normal.png'),
	preload('res://Assets/aaaps/player_2_normal.png'),
	preload('res://Assets/aaaps/player_1_normal.png'),
	preload('res://Assets/aaaps/player_2_normal.png'),
	#preload('res://Assets/aaaps/goodguy_normal.png'),
	#preload('res://Assets/aaaps/badguy_normal.png'),
	#preload('res://Assets/aaaps/god_normal.png'),
	#preload('res://Assets/aaaps/evil_normal.png'),
]
const SWITCH_CHAR: String = '<->'
const END_CHAR: String = '<END>'

var cutscenes_data: Array[Dictionary] = [
	{
		'id': Util.CutsceneType.START,
		'character_left': CharacterType.PLAYER_1,
		'character_right': CharacterType.GOODGUY,
		# left character is starting
		# SWITCH_CHAR switch to the next character
		# END_CHAR end cutscene
		'text': [
			'Hello!\nThis is left character talking',
			'This is still left character talking.......' + SWITCH_CHAR,
			'Hi, this is right character talking now!' + SWITCH_CHAR,
			'And left\n\nagain',
			'Still left',
			'And still going....' + SWITCH_CHAR,
			'Now right',
			'END\nIT\nNOW' + END_CHAR
		]
	}
]

var current_cutscene: Dictionary
var is_active: bool
var text_is_showing: bool
var text_index: int


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip()


func init(cutscene_id: Util.CutsceneType) -> void:
	# TODO how to know which cutscene to play?
	current_cutscene = cutscenes_data.filter(func(cutscene_data): return cutscene_data.id == cutscene_id).front()
	is_active = true
	text_index = 0
	
	# !!! check if this works !!!
	var character_left_texture = character_textures[current_cutscene.character_left]
	character_left_texture_button.texture_normal = character_left_texture
	var character_right_texture = character_textures[current_cutscene.character_right]
	character_right_texture_button.texture_normal = character_right_texture
	
	next_text()


func next_text() -> void:
	text_is_showing = true
	var current_text = current_cutscene.text[text_index]
	cutscene_label.text = current_text.replace(SWITCH_CHAR, '').replace(END_CHAR, '')
	text_is_showing = false
	text_index += 1
	
	if SWITCH_CHAR in current_text:
		switch_characters()
	
	if END_CHAR in current_text:
		is_active = false


func switch_characters() -> void:
	if character_left_texture_button.is_visible():
		character_right_texture_button.show()
		character_left_texture_button.hide()
	elif character_right_texture_button.is_visible():
		character_left_texture_button.show()
		character_right_texture_button.hide()


func skip() -> void:
	if text_is_showing:
		#TODO show all text
		pass
	elif is_active:
		next_text()
	else:
		menu.show_players_selection()
		menu.toggle_visibility(true)
		
		queue_free()
