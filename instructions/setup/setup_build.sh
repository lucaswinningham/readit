#! /bin/bash

for type in reset installs setup; do
  instructions=${instructions}$(< ${type}.md)
done

echo "$instructions"
