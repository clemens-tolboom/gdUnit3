# This is a helper class to compare two objects by equals
class_name GdObjects
extends Object

const TYPE_VOID = TYPE_MAX + 1000
const TYPE_VARARG = TYPE_MAX + 1001

# used as default value for varargs
const TYPE_VARARG_PLACEHOLDER_VALUE = "__null__"

const TYPE_AS_STRING_MAPPINGS := {
	TYPE_NIL: "null",
	TYPE_BOOL: "bool",
	TYPE_INT: "int",
	TYPE_REAL: "float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_RECT2: "Rect2",
	TYPE_VECTOR3: "Vector3",
	TYPE_TRANSFORM2D: "Transform2D",
	TYPE_PLANE: "Plane",
	TYPE_QUAT: "Quat",
	TYPE_AABB: "AABB",
	TYPE_BASIS: "Basis",
	TYPE_TRANSFORM: "Transform",
	TYPE_COLOR: "Color",
	TYPE_NODE_PATH: "NodePath",
	TYPE_RID: "RID",
	TYPE_OBJECT: "Object",
	TYPE_DICTIONARY: "Dictionary",
	TYPE_ARRAY: "Array",
	TYPE_RAW_ARRAY: "PoolByteArray",
	TYPE_INT_ARRAY: "PoolIntArray",
	TYPE_REAL_ARRAY: "PoolRealArray",
	TYPE_STRING_ARRAY: "PoolStringArray",
	TYPE_VECTOR2_ARRAY: "PoolVector2Array",
	TYPE_VECTOR3_ARRAY: "PoolVector3Array",
	TYPE_COLOR_ARRAY: "PoolColorArray",
	TYPE_VOID: "void",
	TYPE_VARARG: "VarArg",
}

# holds flipped copy of TYPE_AS_STRING_MAPPINGS initalisized by func 'string_as_typeof'
const STRING_AS_TYPE_MAPPINGS := {
}

const DEFAULT_VALUES_BY_TYPE := {
	TYPE_NIL: null,
	TYPE_BOOL: false,
	TYPE_INT: 0,
	TYPE_REAL: 0.0,
	TYPE_STRING: "",
	TYPE_VECTOR2: Vector2.ZERO,
	TYPE_RECT2: Rect2(),
	TYPE_VECTOR3: Vector3.ZERO,
	TYPE_TRANSFORM2D: Transform2D(),
	TYPE_PLANE: Plane(),
	TYPE_QUAT: Quat(),
	TYPE_AABB: AABB(),
	TYPE_BASIS: Basis(),
	TYPE_TRANSFORM: Transform(),
	TYPE_COLOR: Color(),
	TYPE_NODE_PATH: NodePath(),
	TYPE_RID: RID(),
	TYPE_OBJECT: null,
	TYPE_DICTIONARY: Dictionary(),
	TYPE_ARRAY: Array(),
	TYPE_RAW_ARRAY: PoolByteArray(),
	TYPE_INT_ARRAY: PoolIntArray(),
	TYPE_REAL_ARRAY: PoolRealArray(),
	TYPE_STRING_ARRAY: PoolStringArray(),
	TYPE_VECTOR2_ARRAY: PoolVector2Array(),
	TYPE_VECTOR3_ARRAY: PoolVector3Array(),
	TYPE_COLOR_ARRAY: PoolColorArray(),
}

const NOTIFICATION_AS_STRING_MAPPINGS := {
	Object.NOTIFICATION_POSTINITIALIZE : "POSTINITIALIZE",
	Object.NOTIFICATION_PREDELETE: "PREDELETE",
	Node.NOTIFICATION_ENTER_TREE : "ENTER_TREE",
	Node.NOTIFICATION_EXIT_TREE: "EXIT_TREE",
	Node.NOTIFICATION_MOVED_IN_PARENT: "MOVED_IN_PARENT",
	Node.NOTIFICATION_READY: "READY",
	Node.NOTIFICATION_PAUSED: "PAUSED",
	Node.NOTIFICATION_UNPAUSED: "UNPAUSED",
	Node.NOTIFICATION_PHYSICS_PROCESS: "PHYSICS_PROCESS",
	Node.NOTIFICATION_PROCESS: "PROCESS",
	Node.NOTIFICATION_PARENTED: "PARENTED",
	Node.NOTIFICATION_UNPARENTED: "UNPARENTED",
	Node.NOTIFICATION_INSTANCED: "INSTANCED",
	Node.NOTIFICATION_DRAG_BEGIN: "DRAG_BEGIN",
	Node.NOTIFICATION_DRAG_END: "DRAG_END",
	Node.NOTIFICATION_PATH_CHANGED: "PATH_CHANGED",
	Node.NOTIFICATION_INTERNAL_PROCESS: "INTERNAL_PROCESS",
	Node.NOTIFICATION_INTERNAL_PHYSICS_PROCESS: "INTERNAL_PHYSICS_PROCESS",
	Node.NOTIFICATION_POST_ENTER_TREE: "POST_ENTER_TREE",
	Node.NOTIFICATION_WM_MOUSE_ENTER: "WM_MOUSE_ENTER",
	Node.NOTIFICATION_WM_MOUSE_EXIT: "NOTIFICATION_WM_MOUSE_EXIT",
	Node.NOTIFICATION_WM_FOCUS_IN: "WM_FOCUS_IN",
	Node.NOTIFICATION_WM_FOCUS_OUT: "WM_FOCUS_OUT",
	Node.NOTIFICATION_WM_QUIT_REQUEST: "WM_QUIT_REQUEST",
	Node.NOTIFICATION_WM_GO_BACK_REQUEST: "WM_GO_BACK_REQUEST",
	Node.NOTIFICATION_WM_UNFOCUS_REQUEST: "WM_UNFOCUS_REQUEST",
	Node.NOTIFICATION_OS_MEMORY_WARNING: "OS_MEMORY_WARNING",
	Node.NOTIFICATION_TRANSLATION_CHANGED: "TRANSLATION_CHANGED",
	Node.NOTIFICATION_WM_ABOUT: "WM_ABOUT",
	Node.NOTIFICATION_CRASH: "CRASH",
	Node.NOTIFICATION_OS_IME_UPDATE: "OS_IME_UPDATE",
	Node.NOTIFICATION_APP_RESUMED: "APP_RESUMED",
	Node.NOTIFICATION_APP_PAUSED: "APP_PAUSED",
}

static func equals_sorted(obj_a :Array, obj_b :Array, case_sensitive :bool = false ) -> bool:
	var a := obj_a.duplicate()
	var b := obj_b.duplicate()
	a.sort()
	b.sort()
	return equals(a, b, case_sensitive)

static func equals(obj_a, obj_b, case_sensitive :bool = false, deep_check :bool = true ) -> bool:
	var type_a = typeof(obj_a)
	var type_b = typeof(obj_b)
	# is different types
	if type_a != type_b:
		return false
	# is same instance
	if obj_a == obj_b:
		return true
	# handle null values
	if obj_a == null and obj_b != null:
		return false
	if obj_b == null and obj_a != null:
		return false

	match type_a:
		TYPE_OBJECT:
			if deep_check:
				var a := var2str(obj_a)
				var b := var2str(obj_b)
				return a == b
			return obj_a == obj_b
		TYPE_ARRAY:
			var arr_a:= obj_a as Array
			var arr_b:= obj_b as Array
			if arr_a.size() != arr_b.size():
				return false
			for index in arr_a.size():
				if not equals(arr_a[index], arr_b[index], case_sensitive):
					return false
			return true
		TYPE_DICTIONARY:
			var dic_a:= obj_a as Dictionary
			var dic_b:= obj_b as Dictionary
			if dic_a.size() != dic_b.size():
				return false
			for key in dic_a.keys():
				var value_a = dic_a[key] if dic_a.has(key) else null
				var value_b = dic_b[key] if dic_b.has(key) else null
				if not equals(value_a, value_b, case_sensitive):
					return false
			return true
		TYPE_STRING:
			if case_sensitive:
				return obj_a.to_lower() == obj_b.to_lower()
			else:
				return obj_a == obj_b

	return obj_a == obj_b

static func notification_as_string(notification :int) -> String:
	return NOTIFICATION_AS_STRING_MAPPINGS.get(notification, "Unknown Notification %d" % notification)

static func string_to_type(value :String) -> int:
	for type in TYPE_AS_STRING_MAPPINGS.keys():
		if TYPE_AS_STRING_MAPPINGS.get(type) == value:
			return type
	return TYPE_NIL

static func type_as_string(type :int) -> String:
	return TYPE_AS_STRING_MAPPINGS.get(type, "Unknown type")

static func typeof_as_string(value) -> String:
	return TYPE_AS_STRING_MAPPINGS.get(typeof(value), "Unknown type")

static func string_as_typeof(type :String) -> int:
	# init STRING_AS_TYPE_MAPPINGS if empty by build a flipped copy
	if STRING_AS_TYPE_MAPPINGS.empty():
		for key in TYPE_AS_STRING_MAPPINGS.keys():
			var value = TYPE_AS_STRING_MAPPINGS[key]
			STRING_AS_TYPE_MAPPINGS[value] = key
	return STRING_AS_TYPE_MAPPINGS.get(type, -1)

static func is_primitive_type(value) -> bool:
	match typeof(value):
		TYPE_BOOL:
			return true
		TYPE_STRING:
			return true
		TYPE_INT:
			return true
		TYPE_REAL:
			return true
	return false

static func is_array_type(value) -> bool:
	return is_type_array(typeof(value))

static func is_type_array(type :int) -> bool:
	match type:
		TYPE_ARRAY:
			return true
		TYPE_COLOR_ARRAY:
			return true
		TYPE_INT_ARRAY:
			return true
		TYPE_RAW_ARRAY:
			return true
		TYPE_REAL_ARRAY:
			return true
		TYPE_STRING_ARRAY:
			return true
		TYPE_VECTOR2_ARRAY:
			return true
		TYPE_VECTOR3_ARRAY:
			return true
	return false

static func is_engine_type(value) -> bool:
	if value is GDScript:
		return false
	return value.to_string().find("GDScriptNativeClass") != -1

static func is_type(value) -> bool:
	var isObject := typeof(value) == TYPE_OBJECT
	# is an build-in type
	if not isObject:
		return false
	# is a engine class type
	if is_engine_type(value):
		return true
	# is a custom class type
	if value is GDScript and value.can_instance():
		return true
	return false


static func is_same(left, right) -> bool:
	var left_type := typeof(left)
	var right_type := typeof(right)

	# if typ different can't be the same
	if left_type != right_type:
		return false
	if left_type == TYPE_OBJECT and right_type == TYPE_OBJECT:
		return left.get_instance_id() == right.get_instance_id()
	return equals(left, right)

static func is_object(value) -> bool:
	return value != null and typeof(value) == TYPE_OBJECT

static func is_script(value) -> bool:
	return is_object(value) and value is Script

static func is_native_class(value) -> bool:
	return is_object(value) and value.to_string().find("GDScriptNativeClass") != -1

static func is_scene(value) -> bool:
	return is_object(value) and value is PackedScene

static func is_instance(value) -> bool:
	if not is_object(value) or is_native_class(value):
		return false
	var is_script = is_script(value)
	#if is_script and value.script != null:
	#	prints("script",value)
	#	return true
	# is engine script instances?
	if is_script(value) and not value.get_instance_base_type():
		return true
	if is_scene(value):
		return true
	return not value.has_method('new') and not value.has_method('instance')

static func is_instanceof(obj :Object, type) -> bool:
	return is_type(type) and obj is type

static func can_instance(obj :Object) -> bool:
	if not obj:
		return false
	for method in obj.get_method_list():
		var funcName:String = method["name"]
		if funcName == "new":
			return true
	return false

static func create_instance(clazz) -> Result:
	match typeof(clazz):
		TYPE_OBJECT:
			# test is given clazz already an instance
			if is_instance(clazz):
				return Result.success(clazz)
			return Result.success(clazz.new())
		TYPE_STRING:
			if ClassDB.class_exists(clazz):
				if Engine.has_singleton(clazz):
					return Result.error("Not allowed to create a instance for singelton '%s'." % clazz)
				if not ClassDB.can_instance(clazz):
					return  Result.error("Can't instance Engine class '%s'." % clazz)
				return Result.success(ClassDB.instance(clazz))
			else:
				var clazz_path = extract_class_path(clazz)
				if not File.new().file_exists(clazz_path):
					return Result.error("Class '%s' not found." % clazz)
				var script = load(clazz_path)
				if script != null:
					return Result.success(script.new())
				else:
					return Result.error("Can't create instance for '%s'." % clazz)
	return Result.error("Can't create instance for class '%s'." % clazz)

static func extract_class_path(clazz) -> PoolStringArray:
	var clazz_path := PoolStringArray()
	if clazz is String:
		clazz_path.append(clazz)
		return clazz_path
		
	if is_instance(clazz):
		# is instance a script instance?
		var script := clazz.script as GDScript
		if script != null:
			return extract_class_path(script)
		return clazz_path
	
	if clazz is GDScript:
		# if not found we go the expensive way and extract the path form the script by creating an instance
		var arg_list := build_function_default_arguments(clazz, "_init")
		var instance = clazz.callv("new", arg_list)
		var clazz_info := inst2dict(instance)
		GdUnitTools.free_instance(instance)
		clazz_path.append(clazz_info["@path"])
		if clazz_info.has("@subpath"):
			var sub_path :String = clazz_info["@subpath"]
			if not sub_path.empty():
				var sub_paths := sub_path.split("/")
				clazz_path += sub_paths
		return clazz_path
	return clazz_path

static func extract_class_name_from_class_path(clazz_path :PoolStringArray) -> String:
	var clazz_name := clazz_path[0].get_file().replace(".gd", "")
	for path_index in range(1, clazz_path.size()):
		clazz_name += "." + clazz_path[path_index]
	return  clazz_name

static func extract_class_name(clazz) -> Result:
	if clazz == null:
		return Result.error("Can't extract class name form a null value.")
	
	if is_instance(clazz):
		# is instance a script instance?
		var script := clazz.script as GDScript
		if script != null:
			var clazz_path := extract_class_path(script)
			return Result.success(extract_class_name_from_class_path(clazz_path))
		return Result.success(clazz.get_class())
	
	# extract name form full qualified class path
	if clazz is String:
		return Result.success(clazz.get_file().replace(".gd", ""))
	
	if is_primitive_type(clazz):
		return Result.error("Can't extract class name for an primitive '%s'" % type_as_string(typeof(clazz)))
	
	if is_script(clazz):
		var clazz_path := extract_class_path(clazz)
		return Result.success(extract_class_name_from_class_path(clazz_path))
		
	# need to create an instance for a class typ the extract the class name
	var instance = clazz.new()
	if instance == null:
		return Result.error("Can't create a instance for class '%s'" % clazz)
	var result := extract_class_name(instance)
	GdUnitTools.free_instance(instance)
	return result

static func extract_inner_clazz_names(clazz_name :String, script_path :PoolStringArray) -> PoolStringArray:
	var inner_classes := PoolStringArray()
	
	if ClassDB.class_exists(clazz_name):
		return inner_classes
	var script :GDScript = load(script_path[0])
	var map := script.get_script_constant_map()
	for key in map.keys():
		var value = map.get(key)
		if value is GDScript:
			var class_path := extract_class_path(value)
			inner_classes.append(class_path[1])
	return inner_classes

# scans all registert script classes for given <clazz_name>
# if the class is public in the global space than return true otherwise false
# public class means the script class is defined by 'class_name <name>'
static func is_public_script_class(clazz_name) -> bool:
	if ProjectSettings.has_setting("_global_script_classes"):
		var script_classes:Array = ProjectSettings.get_setting("_global_script_classes") as Array
		for element in script_classes:
			var class_info :Dictionary = element
			if class_info.has("class"):
				if element["class"] == clazz_name:
					return true
	return false

static func build_function_default_arguments(script :GDScript, func_name :String) -> Array:
	assert(DEFAULT_VALUES_BY_TYPE.size() == TYPE_MAX)
	
	var arg_list := Array()
	for func_sig in script.get_script_method_list():
		if func_sig["name"] == func_name:
			var args :Array = func_sig["args"]
			for arg in args:
				var default_value = DEFAULT_VALUES_BY_TYPE[arg["type"]]
				arg_list.append(default_value)
			return arg_list
	return arg_list

static func default_value_by_type(type :int):
	assert(type < TYPE_MAX)
	assert(type >= 0)
	return DEFAULT_VALUES_BY_TYPE[type]

static func array_to_string(elements, delimiter := "\n") -> String:
	if elements == null:
		return "Null"
	if elements.empty():
		return "empty"
	var formatted := ""
	for element in elements:
		if formatted.length() > 0 :
			formatted += delimiter
		formatted += str(element)
	return formatted

# lookup[i][j] stores the length of LCS of substring X[0..i-1], Y[0..j-1]
static func _createLookUp(lb: PoolByteArray, rb: PoolByteArray) -> Array:
	var lookup:Array = Array()
	lookup.resize(lb.size() + 1)
	for i in lookup.size():
		var x = []
		x.resize(rb.size() + 1)
		lookup[i] = x
	return lookup

static func _buildLookup(lb: PoolByteArray, rb: PoolByteArray) -> Array:
	var lookup := _createLookUp(lb, rb)
	# first column of the lookup table will be all 0
	for i in lookup.size():
		lookup[i][0] = 0
	# first row of the lookup table will be all 0
	for j in lookup[0].size():
		lookup[0][j] = 0

	# fill the lookup table in bottom-up manner
	for i in range(1, lookup.size()):
		for j in range(1, lookup[0].size()):
			# if current character of left and right matches
			if lb[i - 1] == rb[j - 1]:
				lookup[i][j] = lookup[i - 1][j - 1] + 1;
			# else if current character of left and right don't match
			else:
				lookup[i][j] = max(lookup[i - 1][j], lookup[i][j - 1]);
	return lookup

const DIV_ADD = 243
const DIV_SUB = 245

static func _diff(lb: PoolByteArray, rb: PoolByteArray, m: int, n: int, lookup: Array, ldiff: Array, rdiff: Array):
	#if last character of X and Y matches
	if m > 0 && n > 0 && lb[m - 1] == rb[n - 1]:
		ldiff.push_front(lb[m - 1])
		rdiff.push_front(rb[n - 1])
		_diff(lb, rb, m - 1, n - 1, lookup, ldiff, rdiff)
	#current character of Y is not present in X
	else: if (n > 0 && (m == 0 || lookup[m][n - 1] >= lookup[m - 1][n])):
		ldiff.push_front(rb[n - 1])
		ldiff.push_front(DIV_ADD)
		rdiff.push_front(rb[n - 1])
		rdiff.push_front(DIV_SUB)
		_diff(lb, rb, m, n - 1, lookup, ldiff, rdiff)
	#current character of X is not present in Y
	else: if (m > 0 && (n == 0 || lookup[m][n - 1] < lookup[m - 1][n])):
		ldiff.push_front(lb[m - 1])
		ldiff.push_front(DIV_SUB)
		rdiff.push_front(lb[m - 1])
		rdiff.push_front(DIV_ADD)
		_diff(lb, rb, m - 1, n, lookup, ldiff, rdiff)

static func string_diff(left, right) -> Array:
	var lb := PoolByteArray() if left == null else left.to_ascii()
	var rb := PoolByteArray() if right == null else right.to_ascii()
	var ldiff := Array()
	var rdiff := Array()
	var lookup =  _buildLookup(lb, rb);
	_diff(lb, rb, lb.size(), rb.size(), lookup, ldiff, rdiff)
	return [PoolByteArray(ldiff).get_string_from_ascii(), PoolByteArray(rdiff).get_string_from_ascii()]

static func find_nodes_by_class(root: Node, cls: String, recursive: bool = false) -> Array:
	if not recursive:
		return _find_nodes_by_class_no_rec(root, cls)
	return _find_nodes_by_class(root, cls)

static func _find_nodes_by_class_no_rec(parent: Node, cls: String) -> Array:
	var result = []
	for ch in parent.get_children():
		if ch.get_class() == cls:
			result.append(ch)
	return result

static func _find_nodes_by_class(root: Node, cls: String) -> Array:
	var result = []
	var stack = [root]
	while stack:
		var node = stack.pop_back()
		if node.get_class() == cls:
			result.append(node)

		for ch in node.get_children():
			stack.push_back(ch)
	return result


static func longestCommonSubsequence(text1 :String, text2 :String) -> PoolStringArray:
	var text1Words := text1.split(" ")
	var text2Words := text2.split(" ")
	var text1WordCount := text1Words.size()
	var text2WordCount := text2Words.size()
	var solutionMatrix := Array()
	for i in text1WordCount+1:
		var ar := Array()
		for n in text2WordCount+1:
			ar.append(0)
		solutionMatrix.append(ar)

	for i in range(text1WordCount-1, 0, -1):
		for j in range(text2WordCount-1, 0, -1):
			if text1Words[i] == text2Words[j]:
				solutionMatrix[i][j] = solutionMatrix[i + 1][j + 1] + 1;
			else:
				solutionMatrix[i][j] = max(solutionMatrix[i + 1][j], solutionMatrix[i][j + 1]);

	var i = 0
	var j = 0
	var lcsResultList := PoolStringArray();
	while (i < text1WordCount && j < text2WordCount):
		if text1Words[i] == text2Words[j]:
			lcsResultList.append(text2Words[j])
			i += 1
			j += 1
		else: if (solutionMatrix[i + 1][j] >= solutionMatrix[i][j + 1]):
			i += 1
		else:
			j += 1
	return lcsResultList

static func markTextDifferences(text1 :String, text2 :String, lcsList :PoolStringArray, insertColor :Color, deleteColor:Color) -> String:
	var stringBuffer = ""
	if text1 == null and lcsList == null:
		return stringBuffer

	var text1Words := text1.split(" ")
	var text2Words := text2.split(" ")
	var i = 0
	var j = 0
	var word1LastIndex = 0
	var word2LastIndex = 0
	for k in lcsList.size():
		while i < text1Words.size() and j < text2Words.size():
			if text1Words[i] == lcsList[k] and text2Words[j] == lcsList[k]:
				stringBuffer += "<SPAN>" + lcsList[k] + " </SPAN>"
				word1LastIndex = i + 1
				word2LastIndex = j + 1
				i = text1Words.size()
				j = text2Words.size()

			else: if text1Words[i] != lcsList[k]:
				while i < text1Words.size() and text1Words[i] != lcsList[k]:
					stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + deleteColor.to_html() + "'>" + text1Words[i] + " </SPAN>"
					i += 1
			else: if text2Words[j] != lcsList[k]:
				while j < text2Words.size() and text2Words[j] != lcsList[k]:
					stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + insertColor.to_html() + "'>" + text2Words[j] + " </SPAN>"
					j += 1
			i = word1LastIndex
			j = word2LastIndex


			while word1LastIndex < text1Words.size():
				stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + deleteColor.to_html() + "'>" + text1Words[word1LastIndex] + " </SPAN>"
				word1LastIndex += 1
			while word2LastIndex < text2Words.size():
				stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + insertColor.to_html() + "'>" + text2Words[word2LastIndex] + " </SPAN>"
				word2LastIndex += 1

	return stringBuffer


# Normalizes given string by deleting \n, \t and extra spaces.
static func normalizeText(text :String) -> String:
	#text = text.trim();
	text = text.replace("\n", " ");
	text = text.replace("\t", " ");
	return text.replace("  ", " ");


