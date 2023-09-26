// environment_test.v

module hamml

// test_get_package_version
fn test_get_package_version() {
	assert get_package_version() == '0.1.0'
}

// test_get_environment
fn test_get_environment() {
	mut env := Environment{}
	env = get_environment()
	// println(env)
	assert env.v_full_version[0..1] == 'V'
}
