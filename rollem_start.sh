#!/bin/bash
rm die_rollem
while ! -f die_rollem
do 
  ruby rollem.rb
done

