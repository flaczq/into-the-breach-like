extends Control

class_name FeedbackSender

@onready var feedback_text_edit = $FeedbackVBoxContainer/FeedbackTextEdit
@onready var send_feedback_button = $FeedbackVBoxContainer/SendFeedbackButton

var http_request: HTTPRequest = HTTPRequest.new()

const GOOGLE_FORMS = 'https://docs.google.com/forms/u/0/d/e/1FAIpQLSfJ-NMgnW5iCmejCiAajD35klKMai92Wd3a9--lF-XhoR6Nnw/formResponse?submit=Submit&usp=pp_url&entry.1958605938='


func _ready() -> void:
	# Required for http requests
	add_child(http_request)
	
	feedback_text_edit.connect('text_changed', _on_feedback_text_edit_text_changed)
	send_feedback_button.connect('pressed', _on_send_feedback_button_pressed)


func _on_feedback_text_edit_text_changed() -> void:
	send_feedback_button.set_disabled(not feedback_text_edit.text)


func _on_send_feedback_button_pressed() -> void:
	var url = GOOGLE_FORMS + feedback_text_edit.text.json_escape().replace('\\n', '_').replace(' ', '_')
	var request_result = http_request.request(url)
	if request_result != OK:
		printerr('An error occurred in the HTTP request: ' + str(request_result))
	
	feedback_text_edit.clear()
	send_feedback_button.set_disabled(true)
