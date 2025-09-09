extends Control

class_name FeedbackSender

@onready var feedback_text_edit		= $FeedbackVBoxContainer/FeedbackTextEdit
@onready var send_feedback_button	= $FeedbackVBoxContainer/SendFeedbackButton

var http_request: HTTPRequest = HTTPRequest.new()

const FEEDBACK_FORM = 'aHR0cHM6Ly9kb2NzLmdvb2dsZS5jb20vZm9ybXMvdS8wL2QvZS8xRkFJcFFMU2ZKLU5NZ25XNWlDbWVqQ2lBYWpEMzVrbEtNYWk5MldkM2E5LS1sRi1YaG9SNk5udy9mb3JtUmVzcG9uc2U/c3VibWl0PVN1Ym1pdCZ1c3A9cHBfdXJsJmVudHJ5LjE5NTg2MDU5Mzg9'


func _ready() -> void:
	# Required for http requests
	add_child(http_request)
	
	feedback_text_edit.connect('text_changed', _on_feedback_text_edit_text_changed)
	send_feedback_button.connect('pressed', _on_send_feedback_button_pressed)


func _on_feedback_text_edit_text_changed() -> void:
	send_feedback_button.set_disabled(not feedback_text_edit.text)


func _on_send_feedback_button_pressed() -> void:
	var real_form = Marshalls.base64_to_utf8(FEEDBACK_FORM)
	var url = real_form + feedback_text_edit.text.json_escape().replace('\\n', '_').replace(' ', '_')
	var request_result = http_request.request(url)
	if request_result != OK:
		printerr('An error occurred in the HTTP request: ' + str(request_result))
	
	feedback_text_edit.clear()
	send_feedback_button.set_disabled(true)
