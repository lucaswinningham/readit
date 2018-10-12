#! /bin/bash

echo '' > backend_controllers_instructions.md

cat backend_controllers_setup.md >> backend_controllers_instructions.md

for controller in users subs posts; do
  cat ${controller}.md >> backend_controllers_instructions.md
done
