#!/bin/bash

sudo -u webui bash << 'EOF'

cd ~
git clone https://github.com/adjarar/webui-init.git
cd webui-init
chmod +x init.sh

bash init.sh

EOF
