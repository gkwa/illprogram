package core

import (
	"fmt"
	"log"
	"os"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cue/load"
)

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

	genFile, err := os.ReadFile("core/core_go_gen.cue")
	if err != nil {
		return cue.Value{}, fmt.Errorf("failed to read gen file: %w", err)
	}

	gen := ctx.CompileString(string(genFile))
	val = val.Unify(gen)

	iter, err := val.Fields()
	if err != nil {
		return cue.Value{}, fmt.Errorf("failed to iterate over CUE fields: %w", err)
	}

	for iter.Next() {
		key := iter.Label()
		value := iter.Value()
		fmt.Printf("Key: %s\n", key)

		templatesIter, err := value.LookupPath(cue.ParsePath("templates")).List()
		if err != nil {
			return cue.Value{}, fmt.Errorf("failed to get templates list: %w", err)
		}

		for templatesIter.Next() {
			template := templatesIter.Value()
			templateStr, err := template.LookupPath(cue.ParsePath("template")).String()
			if err != nil {
				return cue.Value{}, fmt.Errorf("failed to get template string: %w", err)
			}
			fmt.Printf(" Template: %s\n", templateStr)

			pathStr, err := template.LookupPath(cue.ParsePath("path")).String()
			if err != nil {
				return cue.Value{}, fmt.Errorf("failed to get path string: %w", err)
			}
			fmt.Printf(" Path: %s\n", pathStr)
		}
		fmt.Println()
	}

	fmt.Println("Encoded value:")
	fmt.Println(ctx.Encode(val))

	fmt.Println("Encoded type:")
	fmt.Println(ctx.EncodeType(val))

	return val, nil
}

func Run() {
	ctx := cuecontext.New()
	_, err := LoadTemplates(ctx, "templates.cue")
	if err != nil {
		log.Fatal(err)
	}
}
