extends Node

const cert_name = "X509.crt"
const key_name = "X509.key"
const base_path = "user://cert/"

const CN = "NE"
const O = "ieshlanz"
const C = "ES"

const not_before = "20240101000000"
const not_after = "20250101000000"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir : DirAccess = DirAccess.open("user://")
	
	if not dir.dir_exists(base_path):
		dir.make_dir(base_path)
	create_x509_cert()
	print("Certificado creado!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func create_x509_cert() -> void:
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto : Crypto = Crypto.new()
	var crypto_key :CryptoKey = crypto.generate_rsa(4096)
	var x509 : X509Certificate = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	x509.save(base_path+cert_name)
	crypto_key.save(base_path+key_name)
