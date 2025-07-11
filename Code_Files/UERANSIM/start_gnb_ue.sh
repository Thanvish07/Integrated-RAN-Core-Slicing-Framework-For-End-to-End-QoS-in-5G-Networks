#!/bin/bash

# Open first terminal and run the first command
gnome-terminal -- bash -c "sudo ./build/nr-gnb -c config/open5gs-gnb.yaml; exec bash"

# Open second terminal and run the second command
gnome-terminal -- bash -c "sudo ./build/nr-ue -c config/open5gs-ue.yaml; exec bash"

# Open third terminal and run the third command
gnome-terminal -- bash -c "sudo ./build/nr-ue -c config/open5gs-ue1.yaml; exec bash"

# Open fourth terminal and run the fourth command
gnome-terminal -- bash -c "sudo ./build/nr-ue -c config/open5gs-ue2.yaml; exec bash"
