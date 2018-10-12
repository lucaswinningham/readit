#! /bin/bash

instructions=$(< backend_models_setup.md)

for model in users subs posts; do
  instructions=${instructions}$(< ${model}.md)
done

echo "$instructions"
