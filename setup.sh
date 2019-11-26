#!/bin/bash
# echo -e "APP_PATH=$(pwd)\n$(cat ./config.rb)" > ./config.rg
echo -e "APP_PATH='$(pwd)'" >> ./config.rb
export PATH=~/code/brier:$PATH
