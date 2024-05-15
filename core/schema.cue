package core

#Template: {
   template: string @go(Template)
   path1:    string @go(Path)
}

#Config: {
   templates: [...#Template] @go(Templates,[]Template)
}

#Data: [string]: #Config
