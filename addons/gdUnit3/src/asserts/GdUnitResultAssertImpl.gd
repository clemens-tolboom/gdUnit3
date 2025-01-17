class_name GdUnitResultAssertImpl
extends GdUnitResultAssert


var _base :GdUnitAssert
var _memory_pool :int

func _init(current, memory_pool :int, expect_result :int):
	_memory_pool = memory_pool
	_base = GdUnitAssertImpl.new(current, expect_result)
	if current != null and not (current is Result):
		report_error("GdUnitObjectAssert inital error, unexpected type <%s>" % GdObjects.typeof_as_string(current))

func __current() -> Result:
	return _base._current as Result

func report_success() -> GdUnitResultAssert:
	_base.report_success()
	return self

func report_error(error :String) -> GdUnitResultAssert:
	_base.report_error(error)
	return self

# -------- Base Assert wrapping ------------------------------------------------
func has_error_message(expected: String) -> GdUnitResultAssert:
	_base.has_error_message(expected)
	return self
	
func starts_with_error_message(expected: String) -> GdUnitResultAssert:
	_base.starts_with_error_message(expected)
	return self

func as_error_message(message :String) -> GdUnitResultAssert:
	_base.as_error_message(message)
	return self

func _notification(event):
	if event == NOTIFICATION_PREDELETE:
		if _base != null:
			_base.notification(event)
			_base = null
#-------------------------------------------------------------------------------

# Verifies that the current value is null.
func is_null() -> GdUnitResultAssert:
	_base.is_null()
	return self

# Verifies that the current value is not null.
func is_not_null() -> GdUnitResultAssert:
	_base.is_not_null()
	return self

# Verifies that the result is ends up with success
func is_success() -> GdUnitResultAssert:
	if not __current().is_success():
		report_error(GdAssertMessages.error_result_is_success(__current()))
	else:
		report_success()
	return self

# Verifies that the result is ends up with warning
func is_warning() -> GdUnitResultAssert:
	if not __current().is_warn():
		report_error(GdAssertMessages.error_result_is_warning(__current()))
	else:
		report_success()
	return self

# Verifies that the result is ends up with error
func is_error() -> GdUnitResultAssert:
	if not __current().is_error():
		report_error(GdAssertMessages.error_result_is_error(__current()))
	else:
		report_success()
	return self

# Verifies that the result contains the expected message
func contains_message(expected :String) -> GdUnitResultAssert:
	var result := __current()
	if result.is_success():
		report_error(GdAssertMessages.error_result_has_message_on_success(expected))
	elif result.is_error() and result.error_message() != expected:
		report_error(GdAssertMessages.error_result_has_message(result.error_message(), expected))
	elif result.is_warn() and result.warn_message() != expected:
		report_error(GdAssertMessages.error_result_has_message(result.warn_message(), expected))
	else:
		report_success()
	return self

# Verifies that the result contains the expected value
func is_value(expected) -> GdUnitResultAssert:
	var result := __current()
	if not GdObjects.equals(result.value(), expected):
		report_error(GdAssertMessages.error_result_is_value(result.value(), expected))
	else:
		report_success()
	return self

# Verifies that the result contains the expected value. same as #is_value
func is_equal(expected) -> GdUnitResultAssert:
	return is_value(expected)
