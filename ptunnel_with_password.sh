#!/bin/bash 
sh -c " echo 'Description=Ptunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/ptunnel -x $0
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=2s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/ptunnel.service"