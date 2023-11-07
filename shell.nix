with (import <nixpkgs> {});

mkShell {
  buildInputs = [ glslls ];
}
