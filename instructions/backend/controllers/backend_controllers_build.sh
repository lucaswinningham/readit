#! /bin/bash

echo '' > instructions.md

cat setup.md >> instructions.md

cat users/instructions.md > instructions.md
cat subs/instructions.md >> instructions.md
cat posts/instructions.md >> instructions.md
