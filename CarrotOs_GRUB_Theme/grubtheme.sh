#!/bin/bash

sudo add-apt-repository ppa:danielrichter2007/grub-customizer &&
sudo apt update &&
sudo apt-get install grub-customizer &&
sudo grub-customizer
