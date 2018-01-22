## Compilation

### Requirements (OCaml packages)

* ocamlfind

* menhir

* core

```
ocamlbuild -use-menhir -tag thread -use-ocamlfind -quiet -pkg core main.native
```

## Testing

```
./main.native input_file output_file [option]
```

### Options

* bind - allows to use in further proofs facts proven earlier in the file and axioms

#### Example usage

```
./main.native input_file output_file bind
```