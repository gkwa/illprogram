package core

import (
	"fmt"
	"log"
	"os"

	"gopkg.in/yaml.v2"
)

type Template struct {
	Template string `yaml:"template"`
	Path     string `yaml:"path"`
}

type Config struct {
	Templates []Template `yaml:"templates"`
}

type Data map[string]Config

func LoadData(filename string) Data {
	data, err := os.ReadFile(filename)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	var yamlData Data
	err = yaml.Unmarshal(data, &yamlData)
	if err != nil {
		log.Fatalf("Error unmarshaling YAML: %v", err)
	}
	return yamlData
}

func IterateData(data Data) {
	for key, config := range data {
		fmt.Printf("Key: %s\n", key)
		for _, template := range config.Templates {
			fmt.Printf("  Template: %s\n", template.Template)
			fmt.Printf("  Path: %s\n", template.Path)
		}
		fmt.Println()
	}
}

func Run() {
	data := LoadData("templates.yaml")
	IterateData(data)
}
