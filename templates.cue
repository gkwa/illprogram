package templates

_cookiecutter_json: [
	{template: "cookiecutter/homebrew-and-scoop/cookiecutter.json.j2", path: "cookiecutter.json"},
]

_post_gen_project: [
	{template: "cookiecutter/hooks/post_gen_project.py", path: "hooks/post_gen_project.py"},
]

_readme: [
	{template: "README/README.md.j2", path: "{{ cookiecutter.project_slug }}/README.md"},
]

_gitignore: [
	{template: "gitignore/gitignore2.j2", path: "{{ cookiecutter.project_slug }}/.gitignore"},
]

_go_mod: [
	{template: "go/go.mod/go.mod.j2", path: "{{ cookiecutter.project_slug }}/go.mod"},
]

_workflows: [
	{template: "github/workflows/ci.yml.j2", path:      "{{ cookiecutter.project_slug }}/.github/workflows/ci.yml"},
	{template: "github/workflows/release.yml.j2", path: "{{ cookiecutter.project_slug }}/.github/workflows/release.yml"},
]

_version: [
	{template: "go/version/version.go.j2", path: "{{ cookiecutter.project_slug }}/version/version.go"},
]

_shared: _cookiecutter_json + _post_gen_project + _readme + _gitignore + _workflows + _go_mod

allshire: templates: _shared + [
	{template: "go/Makefile/Makefile3.j2", path:          "{{ cookiecutter.project_slug }}/Makefile"},
	{template: "go/magefile/magefile3.go.j2", path:       "{{ cookiecutter.project_slug }}/magefile.go"},
	{template: "go/goreleaser/goreleaser3.yaml.j2", path: "{{ cookiecutter.project_slug }}/.goreleaser.yaml"},
	{template: "go/version/version2.go.j2", path:         "{{ cookiecutter.project_slug }}/version.go"},
	{template: "go/go.mod/go.mod2.j2", path:              "{{ cookiecutter.project_slug }}/go.mod"},
]

dailycould: templates: _shared + _version + [
	{template: "go/Makefile/Makefile.j2", path:           "{{ cookiecutter.project_slug }}/Makefile"},
	{template: "go/magefile/magefile4.go.j2", path:       "{{ cookiecutter.project_slug }}/magefile.go"},
	{template: "go/goreleaser/goreleaser4.yaml.j2", path: "{{ cookiecutter.project_slug }}/.goreleaser.yaml"},
]

allnew: templates: _shared + _version + [
	{template: "go/Makefile/Makefile2.j2", path:          "{{ cookiecutter.project_slug }}/Makefile"},
	{template: "go/magefile/magefile2.go.j2", path:       "{{ cookiecutter.project_slug }}/magefile.go"},
	{template: "go/goreleaser/goreleaser2.yaml.j2", path: "{{ cookiecutter.project_slug }}/.goreleaser.yaml"},
]

downmust: templates: dailycould.templates

itsvermont: templates: allnew.templates

bluesorrow: templates: _shared
