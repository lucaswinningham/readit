#! /bin/bash

echo '' > backend_instructions.md

cd models/ && ./backend_models_build.sh && cd ..
# cd controllers/ && ./backend_controllers_build.sh && cd ..

cat backend_setup.md >> backend_instructions.md

cat models/backend_models_instructions.md >> backend_instructions.md
# cat controllers/backend_controllers_instructions.md >> backend_instructions.md
