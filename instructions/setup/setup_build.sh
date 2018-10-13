#! /bin/bash

for type in reset installs setup; do
  instructions="${instructions}$(< ${type}.md)\n\n"
done

echo -e "$instructions"
