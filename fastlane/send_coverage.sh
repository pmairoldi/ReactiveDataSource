#!/bin/bash

cd ..
bash <(curl -s https://codecov.io/bash) -t ${CODE_COV_TOKEN}
