package core

import (
	_ "embed"
	"fmt"
	"io"
	"log"
	"os"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cue/load"
	"cuelang.org/go/encoding/yaml"
)

//go:embed core_go_gen.cue
var genFile string

func LoadTemplates(ctx *cue.Context, filename string) (cue.Value, error) {
	instances := load.Instances([]string{filename}, nil)
	if len(instances) == 0 {
		return cue.Value{}, fmt.Errorf("no CUE instance found in %s", filename)
	}

	instance := ctx.BuildInstance(instances[0])
	if err := instance.Value().Err(); err != nil {
		return cue.Value{}, fmt.Errorf("failed to build CUE instance: %v", err)
	}

	val := instance.Value()

	gen := ctx.CompileString(genFile)
	val = val.Unify(gen)

	return val, nil
}

func TraverseFields(val cue.Value, out io.Writer) error {
	iter, err := val.Fields()
	if err != nil {
		return fmt.Errorf("failed to iterate over CUE fields: %w", err)
	}

	for iter.Next() {
		key := iter.Label()
		value := iter.Value()
		fmt.Fprintf(out, "Key: %s\n", key)

		templatesIter, err := value.LookupPath(cue.ParsePath("templates")).List()
		if err != nil {
			return fmt.Errorf("failed to get templates list: %w", err)
		}

		for templatesIter.Next() {
			template := templatesIter.Value()
			templateStr, err := template.LookupPath(cue.ParsePath("template")).String()
			if err != nil {
				return fmt.Errorf("failed to get template string: %w", err)
			}
			fmt.Fprintf(out, " Template: %s\n", templateStr)

			pathStr, err := template.LookupPath(cue.ParsePath("path")).String()
			if err != nil {
				return fmt.Errorf("failed to get path string: %w", err)
			}
			fmt.Fprintf(out, " Path: %s\n", pathStr)
		}
		fmt.Fprintln(out)
	}

	return nil
}

func WriteYAML(val cue.Value, filename string) error {
	yamlBytes, err := yaml.Encode(val)
	if err != nil {
		return fmt.Errorf("failed to encode to YAML: %w", err)
	}

	err = os.WriteFile(filename, yamlBytes, 0o644)
	if err != nil {
		return fmt.Errorf("failed to write YAML file: %w", err)
	}

	return nil
}

func Run() {
	ctx := cuecontext.New()
	val, err := LoadTemplates(ctx, "templates.cue")
	if err != nil {
		log.Fatal(err)
	}

	err = TraverseFields(val, os.Stdout)
	if err != nil {
		log.Fatal(err)
	}

	err = WriteYAML(val, "templates.yaml")
	if err != nil {
		log.Fatal(err)
	}
}
