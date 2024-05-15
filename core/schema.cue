package core

#Template: {
	template: string @go(Template)
	path:     string @go(Path)
}

#Config: {
	templates: [...#Template] @go(Templates,[]Template)
}

#Data: [string]: #Config
