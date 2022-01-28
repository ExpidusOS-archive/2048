project('expidus-2048', 'vala', 'c', license: 'GNU-3.0-only', version: '0.1.0-prealpha')

gnome = import('gnome')

prefix = get_option('prefix')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')

gtk3 = dependency('gtk+-3.0')
hdy = dependency('libhandy-1')
pango_cairo = dependency('pangocairo')

version = '"@0@"'.format(meson.project_version())
git = find_program('git', native: true, required: false)
if git.found()
	git_commit = run_command([git, 'rev-parse', '--short', 'HEAD'])
	git_branch = run_command([git, 'rev-parse', '--abbrev-ref', 'HEAD'])
	if git_commit.returncode() == 0 and git_branch.returncode() == 0
		version = '"@0@-@1@ (branch \'@2@\')"'.format(meson.project_version(), git_commit.stdout().strip(), git_branch.stdout().strip())
	endif
endif

conf_data = configuration_data()
conf_data.set('BINDIR', bindir)
conf_data.set('DATADIR', datadir)
conf_data.set('VERSION', version)

subdir('po')

build_conf_h = configure_file(input: 'src/build.h.in', output: 'build.h',
	configuration: conf_data)
build_conf = configure_file(input: 'src/build.vala.in', output: 'build.vala',
	configuration: conf_data)

configure_file(input: 'data/expidus-2048.desktop.in', output: 'expidus-2048.desktop',
	configuration: conf_data,
	install: true,
	install_dir: datadir / 'applications')

game_res = gnome.compile_resources('expidus-2048-res', 'data/res/res.gresource.xml',
  source_dir: 'data/res',
  c_name: 'Expidus2048')

executable('expidus-2048', 'src/application.vala', 'src/colorscheme.vala', 'src/main.vala', 'src/window.vala', game_res, build_conf, build_conf_h,
  dependencies: [gtk3, hdy, pango_cairo],
  install: true)

install_data('data/com.expidus.twentyfortyeight.gschema.xml', install_dir: datadir / 'glib-2.0/schemas')
gnome.post_install(glib_compile_schemas: true)