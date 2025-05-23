// environment.v
module vhammll

import os
import time
import v.util.version
import runtime
import v.vmod

// get_environment collects and returns information about the
// computer, the operating system and its version,
// the version and build of V, the version of HamNN,
// and the date and time. It returns an Environment struct.
fn get_environment() Environment {
	mut env := Environment{}
	env.collect_info()
	env.vhammll_version = get_package_version()
	return env
}

// get_package_version
fn get_package_version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err.msg()) }
	return vm.version
}

fn (mut a Environment) collect_info() {
	mut os_kind := os.user_os()
	mut arch_details := []string{}
	arch_details << '${runtime.nr_cpus()} cpus'
	if runtime.is_32bit() {
		arch_details << '32bit'
	}
	if runtime.is_64bit() {
		arch_details << '64bit'
	}
	if runtime.is_big_endian() {
		arch_details << 'big endian'
	}
	if runtime.is_little_endian() {
		arch_details << 'little endian'
	}
	if os_kind == 'macos' {
		arch_details << a.cmd(command: 'sysctl -n machdep.cpu.brand_string')
	}
	if os_kind == 'linux' {
		mut cpu_details := ''
		if cpu_details == '' {
			// cpu_details = a.cpu_info('model name')
		}
		if cpu_details == '' {
			// cpu_details = a.cpu_info('hardware')
		}
		if cpu_details == '' {
			cpu_details = os.uname().machine
		}
		arch_details << cpu_details
	}
	if os_kind == 'windows' {
		arch_details << a.cmd(
			command: 'wmic cpu get name /format:table'
			line:    1
		)
	}
	//
	mut os_details := ''
	wsl_check := a.cmd(command: 'cat /proc/sys/kernel/osrelease')
	if os_kind == 'linux' {
		os_details = a.get_linux_os_name()
		// if a.cpu_info('flags').contains('hypervisor') {
		// 	if wsl_check.contains('microsoft') {
		// 		// WSL 2 is a Managed VM and Full Linux Kernel
		// 		// See https://docs.microsoft.com/en-us/windows/wsl/compare-versions
		// 		os_details += ' (WSL 2)'
		// 	} else {
		// 		os_details += ' (VM)'
		// 	}
		// }
		// WSL 1 is NOT a Managed VM and Full Linux Kernel
		// See https://docs.microsoft.com/en-us/windows/wsl/compare-versions
		if wsl_check.contains('Microsoft') {
			os_details += ' (WSL)'
		}
		// From https://unix.stackexchange.com/a/14346
		// awk_cmd := '[ "$(awk \'\$5=="/" {print \$1}\' </proc/1/mountinfo)" != "$(awk \'\$5=="/" {print \$1}\' </proc/$$/mountinfo)" ] ; echo \$?'
		awk_cmd := '[ "$(awk \'\$5=="/" { print \$1 }\' </proc/1/mountinfo)" != "$(awk \'\$5=="/" { print \$1 }\' </proc/$$/mountinfo)" ] ; echo \$?'
		if a.cmd(command: awk_cmd) == '0' {
			os_details += ' (chroot)'
		}
	} else if os_kind == 'macos' {
		mut details := []string{}
		details << a.cmd(command: 'sw_vers -productName')
		details << a.cmd(command: 'sw_vers -productVersion')
		details << a.cmd(command: 'sw_vers -buildVersion')
		os_details = details.join(', ')
	} else if os_kind == 'windows' {
		wmic_info := a.cmd(
			command: 'wmic os get * /format:value'
			line:    -1
		)
		p := a.parse(wmic_info, '=')
		caption, build_number, os_arch := p['caption'], p['buildnumber'], p['osarchitecture']
		os_details = '${caption} v${build_number} ${os_arch}'
	} else {
		ouname := os.uname()
		os_details = '${ouname.release}, ${ouname.version}'
	}
	a.os_kind = os_kind
	a.os_details = os_details
	a.arch_details = arch_details
	vexe := os.getenv('VEXE')
	a.vexe_mtime = time.unix(os.file_last_mod_unix(vexe)).str()
	a.v_full_version = version.full_v_version(true)
	a.vflags = os.getenv('VFLAGS')
}

struct CmdConfig {
	line    int
	command string
}

fn (mut a Environment) cmd(c CmdConfig) string {
	x := os.execute(c.command)
	if x.exit_code < 0 {
		return 'N/A'
	}
	if x.exit_code == 0 {
		if c.line < 0 {
			return x.output
		}
		output := x.output.split_into_lines()
		if output.len > 0 && output.len > c.line {
			return output[c.line]
		}
	}
	return 'Error: ${x.output}'
}

fn (app &Environment) parse(config string, sep string) map[string]string {
	mut m := map[string]string{}
	lines := config.split_into_lines()
	for line in lines {
		sline := line.trim_space()
		if sline.len == 0 || sline[0] == `#` {
			continue
		}
		x := sline.split(sep)
		if x.len < 2 {
			continue
		}
		m[x[0].trim_space().to_lower()] = x[1].trim_space().trim('"')
	}
	return m
}

fn (mut a Environment) get_linux_os_name() string {
	mut os_details := ''
	linux_os_methods := ['os-release', 'lsb_release', 'kernel', 'uname']
	for m in linux_os_methods {
		match m {
			'os-release' {
				if !os.is_file('/etc/os-release') {
					continue
				}
				lines := os.read_file('/etc/os-release') or { continue }
				vals := a.parse(lines, '=')
				if vals['PRETTY_NAME'] == '' {
					continue
				}
				os_details = vals['PRETTY_NAME']
				break
			}
			'lsb_release' {
				exists := a.cmd(command: 'type lsb_release')
				if exists.starts_with('Error') {
					continue
				}
				os_details = a.cmd(command: 'lsb_release -d -s')
				break
			}
			'kernel' {
				if !os.is_file('/proc/version') {
					continue
				}
				os_details = a.cmd(command: 'cat /proc/version')
				break
			}
			'uname' {
				ouname := os.uname()
				os_details = '${ouname.release}, ${ouname.version}'
				break
			}
			else {}
		}
	}
	return os_details
}

// fn (mut a Environment) cpu_info(key string) string {
// 	if a.cached_cpuinfo.len > 0 {
// 		return a.cached_cpuinfo[key]
// 	}
// 	info := os.execute('cat /proc/cpuinfo')
// 	if info.exit_code != 0 {
// 		return '`cat /proc/cpuinfo` could not run'
// 	}
// 	a.cached_cpuinfo = a.parse(info.output, ':')
// 	return a.cached_cpuinfo[key]
// }
