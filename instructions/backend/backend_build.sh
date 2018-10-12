#! /bin/bash

instructions=$(< backend_setup.md)

for category in model controller; do
  cd ${category}s/
  instructions=${instructions}$(./backend_${category}s_build.sh)
  cd ..
done

echo "$instructions"
