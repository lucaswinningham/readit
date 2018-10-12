#! /bin/bash

echo '' > backend_models_instructions.md

cat backend_models_setup.md >> backend_models_instructions.md

for model in users subs posts; do
  cat ${model}.md >> backend_models_instructions.md
done
