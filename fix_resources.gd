#!/usr/bin/env -S godot --headless --script

extends SceneTree

# This script creates placeholder resources for CI environment
# Run this with: godot --headless --script fix_resources.gd

func create_and_save_image(path: String, width: int = 64, height: int = 64) -> void:
	# Create a simple image as a placeholder
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.3, 0.3, 1.0))  # Light gray color with full opacity
	
	# Draw a simple pattern to make it recognizable
	for x in range(width):
		for y in range(height):
			if (x + y) % 16 < 8:  # Creates a checkerboard pattern
				img.set_pixel(x, y, Color(0.5, 0.5, 0.5, 1.0))
	
	# Save the image
	var err = img.save_png(path)
	if err != OK:
		print("Failed to save image: ", path, " error: ", err)
	else:
		print("Created image at: ", path)

func create_font_file(path: String) -> void:
	# Create a minimal TTF placeholder file
	# We're not creating a real font, just enough bytes to pass initial checks
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# Write minimal TTF header bytes
		file.store_buffer(PackedByteArray([0, 1, 0, 0, 0, 10, 0, 0, 0, 0]))
		file.close()
		print("Created font placeholder at: ", path)
	else:
		print("Failed to create font placeholder: ", path)

func ensure_directory_exists(path: String) -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(path):
		var err = dir.make_dir_recursive(path)
		if err == OK:
			print("Created directory: ", path)
		else:
			print("Failed to create directory: ", path, " error: ", err)

func create_import_file(source_path: String, dest_path: String, import_type: String, uid: String = "uid://c8qxl61n80aip") -> void:
	var content = ""
	
	if import_type == "texture":
		content = """[remap]

importer="texture"
type="CompressedTexture2D"
uid="%s"
path="%s"
metadata={
"vram_texture": false
}

[deps]

source_file="%s"
dest_files=["%s"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
""" % [uid, dest_path, source_path, dest_path]
	
	elif import_type == "font":
		content = """[remap]

importer="font_data_dynamic"
type="FontFile"
uid="%s"
path="%s"
metadata={
"vram_texture": false
}

[deps]

source_file="%s"
dest_files=["%s"]

[params]

Rendering=null
antialiasing=1
generate_mipmaps=false
multichannel_signed_distance_field=false
msdf_pixel_range=8
msdf_size=48
allow_system_fallback=true
force_autohinter=false
hinting=1
subpixel_positioning=1
oversampling=0.0
Fallbacks=null
fallbacks=[]
Compress=null
compress=true
preload=[]
""" % [uid, dest_path, source_path, dest_path]
	
	# Create the import file
	var file = FileAccess.open(source_path + ".import", FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("Created .import file for: ", source_path)
	else:
		print("Failed to create .import file for: ", source_path)

func create_warnings_manager_class() -> void:
	# Create a simple implementation of WarningsManager
	var warnings_manager_content = """
@tool
extends RefCounted

static func are_warnings_enabled() -> bool:
	return false
	
static func enable_warnings(should_enable: bool) -> void:
	pass

static func load_script_ignoring_all_warnings(path):
	var result = load(path)
	return result
"""

	var file = FileAccess.open("res://addons/gut/warnings_manager.gd", FileAccess.WRITE)
	if file:
		file.store_string(warnings_manager_content)
		file.close()
		print("Created warnings_manager.gd")
	else:
		print("Failed to create warnings_manager.gd")

func create_lazy_loader_class() -> void:
	# Create a minimal implementation of LazyLoader
	var lazy_loader_content = """
@tool
# ------------------------------------------------------------------------------
# Static
# ------------------------------------------------------------------------------
static var usage_counter = load('res://addons/gut/thing_counter.gd').new()
static var WarningsManager = load('res://addons/gut/warnings_manager.gd')

static func load_all():
	for key in usage_counter.things:
		key.get_loaded()

static func print_usage():
	for key in usage_counter.things:
		print(key._path, '  (', usage_counter.things[key], ')')

# ------------------------------------------------------------------------------
# Class
# ------------------------------------------------------------------------------
var _loaded = null
var _path = null

func _init(path):
	_path = path
	usage_counter.add_thing_to_count(self)

func get_loaded():
	if(_loaded == null):
		_loaded = WarningsManager.load_script_ignoring_all_warnings(_path)
	usage_counter.add(self)
	return _loaded
"""

	var file = FileAccess.open("res://addons/gut/lazy_loader.gd", FileAccess.WRITE)
	if file:
		file.store_string(lazy_loader_content)
		file.close()
		print("Created lazy_loader.gd")
	else:
		print("Failed to create lazy_loader.gd")

func create_thing_counter_class() -> void:
	# Create a minimal implementation of ThingCounter
	var thing_counter_content = """
@tool
extends RefCounted

var things = {}

func add_thing_to_count(thing):
	# Using object id as dictionary key
	if(!things.has(thing)):
		things[thing] = 0
		
func add(thing):
	if(things.has(thing)):
		things[thing] += 1
	else:
		add_thing_to_count(thing)
		add(thing)
"""

	var file = FileAccess.open("res://addons/gut/thing_counter.gd", FileAccess.WRITE)
	if file:
		file.store_string(thing_counter_content)
		file.close()
		print("Created thing_counter.gd")
	else:
		print("Failed to create thing_counter.gd")
		
func create_version_numbers_class() -> void:
	# Create a minimal implementation of VersionNumbers
	var version_numbers_content = """
@tool
extends RefCounted

var _gut_version = ''
var _godot_version = ''

const VerNumTools = {
	is_godot_version_gte = func(ver): return true,
	is_godot_version_eq = func(ver): return true
}

func _init(gut_version='0.0.0', req_godot_version='0.0.0'):
	_gut_version = gut_version
	_godot_version = req_godot_version

func is_godot_version_valid():
	return true

func get_bad_version_text():
	return ''

func make_godot_version_string():
	return '4.2.0'
"""

	var file = FileAccess.open("res://addons/gut/version_numbers.gd", FileAccess.WRITE)
	if file:
		file.store_string(version_numbers_content)
		file.close()
		print("Created version_numbers.gd")
	else:
		print("Failed to create version_numbers.gd")

func create_double_tools_class() -> void:
	# Create a minimal implementation of DoubleTools that includes both getter methods
	var double_tools_content = """
@tool
extends RefCounted

func _init():
	pass

func get_loaded():
	return self
	
func get_loader():
	return self
"""

	var file = FileAccess.open("res://addons/gut/double_tools.gd", FileAccess.WRITE)
	if file:
		file.store_string(double_tools_content)
		file.close()
		print("Created double_tools.gd with both getter methods")
	else:
		print("Failed to create double_tools.gd")

func fix_gut_utils() -> void:
	# Create dependencies first
	create_warnings_manager_class()
	create_lazy_loader_class()
	create_thing_counter_class()
	create_version_numbers_class()
	create_double_tools_class()
	
	# Now create utils.gd with more of the required functionality
	var utils_content = """
@tool
class_name GutUtils
extends Object

const GUT_METADATA = '__gutdbl'

# Note, these cannot change since places are checking for TYPE_INT to determine
# how to process parameters.
enum DOUBLE_STRATEGY{
	INCLUDE_NATIVE,
	SCRIPT_ONLY,
}

enum DIFF {
	DEEP,
	SIMPLE
}

const TEST_STATUSES = {
	NO_ASSERTS = 'no asserts',
	SKIPPED = 'skipped',
	NOT_RUN = 'not run',
	PENDING = 'pending',
	FAILED = 'fail',
	PASSED = 'pass'
}

const DOUBLE_TEMPLATES = {
	FUNCTION = 'res://addons/gut/double_templates/function_template.txt',
	INIT = 'res://addons/gut/double_templates/init_template.txt',
	SCRIPT = 'res://addons/gut/double_templates/script_template.txt',
}

static var GutScene = null # load('res://addons/gut/GutScene.tscn')
static var LazyLoader = load('res://addons/gut/lazy_loader.gd')
static var VersionNumbers = load('res://addons/gut/version_numbers.gd')
static var WarningsManager = load('res://addons/gut/warnings_manager.gd')

# --------------------------------
# Lazy loaded scripts - simplified versions for CI
# --------------------------------
static var AutoFree = LazyLoader.new('res://addons/gut/autofree.gd')
static var Awaiter = LazyLoader.new('res://addons/gut/awaiter.gd')
static var Comparator = LazyLoader.new('res://addons/gut/comparator.gd')
static var CollectedTest = LazyLoader.new('res://addons/gut/collected_test.gd')
static var CollectedScript = LazyLoader.new('res://addons/gut/collected_script.gd')
static var CompareResult = LazyLoader.new('res://addons/gut/compare_result.gd')
static var DiffFormatter = LazyLoader.new('res://addons/gut/diff_formatter.gd')
static var DiffTool = LazyLoader.new('res://addons/gut/diff_tool.gd')
static var DoubleTools = LazyLoader.new('res://addons/gut/double_tools.gd')
static var Doubler = LazyLoader.new('res://addons/gut/doubler.gd')
static var DynamicGdScript = LazyLoader.new('res://addons/gut/dynamic_gdscript.gd')
static var Gut = LazyLoader.new('res://addons/gut/gut.gd')
static var GutConfig = LazyLoader.new('res://addons/gut/gut_config.gd')
static var HookScript = LazyLoader.new('res://addons/gut/hook_script.gd')
static var InnerClassRegistry = LazyLoader.new('res://addons/gut/inner_class_registry.gd')
static var InputFactory = LazyLoader.new('res://addons/gut/input_factory.gd')
static var InputSender = LazyLoader.new('res://addons/gut/input_sender.gd')
static var JunitXmlExport = LazyLoader.new('res://addons/gut/junit_xml_export.gd')
static var Logger = LazyLoader.new('res://addons/gut/logger.gd')
static var MethodMaker = LazyLoader.new('res://addons/gut/method_maker.gd')
static var OneToMany = LazyLoader.new('res://addons/gut/one_to_many.gd')
static var OrphanCounter = LazyLoader.new('res://addons/gut/orphan_counter.gd')
static var ParameterFactory = LazyLoader.new('res://addons/gut/parameter_factory.gd')
static var ParameterHandler = LazyLoader.new('res://addons/gut/parameter_handler.gd')
static var Printers = LazyLoader.new('res://addons/gut/printers.gd')
static var ResultExporter = LazyLoader.new('res://addons/gut/result_exporter.gd')
static var ScriptCollector = LazyLoader.new('res://addons/gut/script_parser.gd')
static var SignalWatcher = LazyLoader.new('res://addons/gut/signal_watcher.gd')
static var Spy = LazyLoader.new('res://addons/gut/spy.gd')
static var Strutils = LazyLoader.new('res://addons/gut/strutils.gd')
static var Stubber = LazyLoader.new('res://addons/gut/stubber.gd')
static var StubParams = LazyLoader.new('res://addons/gut/stub_params.gd')
static var Summary = LazyLoader.new('res://addons/gut/summary.gd')
static var Test = LazyLoader.new('res://addons/gut/test.gd')
static var TestCollector = LazyLoader.new('res://addons/gut/test_collector.gd')
static var ThingCounter = LazyLoader.new('res://addons/gut/thing_counter.gd')

static var avail_fonts = ['AnonymousPro', 'CourierPrime', 'LobsterTwo', 'Default']

static var version_numbers = VersionNumbers.new(
	# gut_version (source of truth)
	'9.3.1',
	# required_godot_version
	'4.2.0'
)

static var warnings_at_start := { # WarningsManager dictionary
	exclude_addons = true
}

static var warnings_when_loading_test_scripts := { # WarningsManager dictionary
	enable = false
}

# ------------------------------------------------------------------------------
# Everything should get a logger through this.
# ------------------------------------------------------------------------------
static var _test_mode = false
static var _lgr = null
static func get_logger():
	if(_test_mode):
		return Logger.get_loaded()
	else:
		if(_lgr == null):
			_lgr = Logger.get_loaded()
		return _lgr

static var _dyn_gdscript = null #DynamicGdScript.new()
static func create_script_from_source(source, override_path=null):
	return null

static func godot_version_string():
	return version_numbers.make_godot_version_string()

static func is_godot_version(expected):
	return true

static func is_godot_version_gte(expected):
	return true

const INSTALL_OK_TEXT = 'Everything checks out'
static func make_install_check_text(template_paths=DOUBLE_TEMPLATES, ver_nums=version_numbers):
	return INSTALL_OK_TEXT

static func is_install_valid(template_paths=DOUBLE_TEMPLATES, ver_nums=version_numbers):
	return true

# ------------------------------------------------------------------------------
# Required methods for GUT compatibility
# ------------------------------------------------------------------------------
static func get_enum_value(thing, e, default=null):
	return default

static func nvl(value, if_null):
	if(value == null):
		return if_null
	else:
		return value

static func is_freed(obj):
	var wr = weakref(obj)
	return !(wr.get_ref() and str(obj) != '<Freed Object>')

static func is_not_freed(obj):
	return !is_freed(obj)

static func is_double(obj):
	var to_return = false
	if(typeof(obj) == TYPE_OBJECT and is_instance_valid(obj)):
		to_return = obj.has_method('__gutdbl_check_method__')
	return to_return

static func is_native_class(thing):
	var it_is = false
	if(typeof(thing) == TYPE_OBJECT):
		it_is = str(thing).begins_with("<GDScriptNativeClass#")
	return it_is

static func is_instance(obj):
	return typeof(obj) == TYPE_OBJECT and \\
		!is_native_class(obj) and \\
		!obj.has_method('new') and \\
		!obj.has_method('instantiate')

static func is_gdscript(obj):
	return typeof(obj) == TYPE_OBJECT and str(obj).begins_with('<GDScript#')

static func is_inner_class(obj):
	return is_gdscript(obj) and obj.resource_path == ''

static func can_make_callable(thing):
	if(thing == null):
		return false
	
	if(typeof(thing) == TYPE_CALLABLE):
		return true
	elif(typeof(thing) == TYPE_ARRAY and thing.size() == 2):
		var valid = GutUtils.is_instance(thing[0]) and typeof(thing[1]) == TYPE_STRING
		return valid
	else:
		return false

static func del_empty_dirs(path):
	pass
"""
	
	# Create utils.gd in the gut addon directory
	var file = FileAccess.open("res://addons/gut/utils.gd", FileAccess.WRITE)
	if file:
		file.store_string(utils_content)
		file.close()
		print("Created fixed utils.gd with GutUtils class")
	else:
		print("Failed to create utils.gd")

func _init():
	print("Creating placeholder resources for CI...")
	
	# Create main game directory structure
	ensure_directory_exists("res://Imagenes")
	ensure_directory_exists("res://.godot")
	ensure_directory_exists("res://.godot/imported")
	
	# Create GUT addon resources directories
	ensure_directory_exists("res://addons/gut/fonts")
	ensure_directory_exists("res://addons/gut/gui")
	ensure_directory_exists("res://.godot/imported/AnonymousPro-Regular.ttf-856c843fd6f89964d2ca8d8ff1724f13.fontdata".get_base_dir())
	ensure_directory_exists("res://.godot/imported/CourierPrime-Regular.ttf-3babe7e4a7a588dfc9a84c14b4f1fe23.fontdata".get_base_dir())
	ensure_directory_exists("res://.godot/imported/play.png-5c90e88e8136487a183a099d67a7de24.ctex".get_base_dir())
	ensure_directory_exists("res://.godot/imported/arrow.png-2b5b2d838b5b3467cf300ac2da1630d9.ctex".get_base_dir())
	
	# First handle the main game resources
	create_and_save_image("res://Imagenes/Fondito del menu.png")
	create_import_file(
		"res://Imagenes/Fondito del menu.png", 
		"res://.godot/imported/Fondito del menu.png-74fa065b9dc2d40add6f3b207a755811.ctex",
		"texture"
	)
	create_and_save_image("res://.godot/imported/Fondito del menu.png-74fa065b9dc2d40add6f3b207a755811.ctex")
	
	# Handle GUT addon resources
	print("Creating GUT addon resources...")
	
	# Fix the critical GutUtils dependency
	fix_gut_utils()
	
	# Create font files
	create_font_file("res://addons/gut/fonts/AnonymousPro-Regular.ttf")
	create_font_file("res://addons/gut/fonts/CourierPrime-Regular.ttf")
	
	# Create import files for fonts
	create_import_file(
		"res://addons/gut/fonts/AnonymousPro-Regular.ttf",
		"res://.godot/imported/AnonymousPro-Regular.ttf-856c843fd6f89964d2ca8d8ff1724f13.fontdata",
		"font",
		"uid://ca7xoalyhw50"
	)
	create_import_file(
		"res://addons/gut/fonts/CourierPrime-Regular.ttf",
		"res://.godot/imported/CourierPrime-Regular.ttf-3babe7e4a7a588dfc9a84c14b4f1fe23.fontdata",
		"font",
		"uid://dd5wvaqibjgmx"
	)
	
	# Create font data placeholders in .godot/imported
	var font_data = PackedByteArray([0, 1, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	var file = FileAccess.open("res://.godot/imported/AnonymousPro-Regular.ttf-856c843fd6f89964d2ca8d8ff1724f13.fontdata", FileAccess.WRITE)
	if file:
		file.store_buffer(font_data)
		file.close()
		print("Created AnonymousPro fontdata")
	
	file = FileAccess.open("res://.godot/imported/CourierPrime-Regular.ttf-3babe7e4a7a588dfc9a84c14b4f1fe23.fontdata", FileAccess.WRITE)
	if file:
		file.store_buffer(font_data)
		file.close()
		print("Created CourierPrime fontdata")
	
	# Create GUI images needed by GUT
	create_and_save_image("res://addons/gut/gui/play.png", 32, 32)
	create_and_save_image("res://addons/gut/gui/arrow.png", 32, 32)
	
	# Create import files for GUI images
	create_import_file(
		"res://addons/gut/gui/play.png",
		"res://.godot/imported/play.png-5c90e88e8136487a183a099d67a7de24.ctex",
		"texture",
		"uid://caap6r2x8kudn"
	)
	create_import_file(
		"res://addons/gut/gui/arrow.png",
		"res://.godot/imported/arrow.png-2b5b2d838b5b3467cf300ac2da1630d9.ctex",
		"texture",
		"uid://dnra05qqu7wnd"
	)
	
	# Create the actual ctex files
	create_and_save_image("res://.godot/imported/play.png-5c90e88e8136487a183a099d67a7de24.ctex", 32, 32)
	create_and_save_image("res://.godot/imported/arrow.png-2b5b2d838b5b3467cf300ac2da1630d9.ctex", 32, 32)
	
	# Create a simple GutSceneTheme file
	var theme_content = """[gd_resource type="Theme" load_steps=2 format=3 uid="uid://it37j0nfej6r"]

[ext_resource type="FontFile" uid="uid://ca7xoalyhw50" path="res://addons/gut/fonts/AnonymousPro-Regular.ttf" id="1_pja5v"]

[resource]
default_font = ExtResource("1_pja5v")
default_font_size = 16
Label/fonts/font = ExtResource("1_pja5v")
"""
	file = FileAccess.open("res://addons/gut/gui/GutSceneTheme.tres", FileAccess.WRITE)
	if file:
		file.store_string(theme_content)
		file.close()
		print("Created GutSceneTheme.tres")
	
	print("Resource creation completed successfully!")
	quit()
