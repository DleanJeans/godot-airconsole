extends Node

signal received_texture(device_id)

var _busy_requests = []
var _textures = {}

func request(url:String, device_id:int):
#	while _busy_requests.size() > 0:
#		yield(self, 'received_texture')
	
	var http_request = _get_free_http_request()
	_reconnect_request_signal(http_request, device_id)
	http_request.request(url)
	_busy_requests.append(http_request)

func get_texture(device_id):
	return _textures[device_id]

func _reconnect_request_signal(request:HTTPRequest, device_id:int):
	if request.is_connected('request_completed', self, '_on_request_completed'):
		request.disconnect('request_completed', self, '_on_request_completed')
	request.connect('request_completed', self, '_on_request_completed', [request, device_id])

func _get_free_http_request():
	for request in get_children():
		if not request in _busy_requests:
			return request
	
	var new_request = HTTPRequest.new()
	add_child(new_request, true)
	return new_request

func _on_request_completed(result, response_code, headers, body, http_request, device_id):
	_busy_requests.erase(http_request)
	
	var type = headers[0]
	var buffer:PoolByteArray = body
	var image = Image.new()
	if 'png' in type:
		image.load_png_from_buffer(buffer)
	else:
		image.load_jpg_from_buffer(buffer)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	_textures[device_id] = texture
	emit_signal('received_texture', device_id)