#! /bin/bash

instructions=$(< backend_controllers_setup.md)

for controller in users subs posts; do
  instructions=${instructions}$(< ${controller}.md)
done

echo "$instructions"
