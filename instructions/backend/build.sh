#! /bin/bash

echo '' > instructions.md

cd models/ && ./build.sh && cd ..
cd controllers/ && ./build.sh && cd ..

cat setup.md >> instructions.md

cat models/instructions.md >> instructions.md
cat controllers/instructions.md >> instructions.md
