project('vala-eip-patterns', 'vala', 'c')

pkg = import('pkgconfig')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

vala = meson.get_compiler('vala')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gee-0.8')
]

sources_result = run_command('sources.sh')
library_sources = sources_result.stdout().strip().split('\n')

lib = shared_library('libvalaeippatterns', library_sources, 
    dependencies: dependencies,
    install: true,
    install_dir: [true, true, true]
)
pkg.generate(lib)
