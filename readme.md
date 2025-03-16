sudo docker-compose up -d

sudo docker-compose down



------------------------


///// write reconnect function:
sudo nano /etc/systemd/system/network-reconnect.service


[Unit]
Description=Network Reconnect Script
After=network.target

[Service]
ExecStart=/home/recoder/RECODER-COMPOSE/reconnect.sh
Restart=always
User=recoder

[Install]
WantedBy=multi-user.target


chmod +x /home/recoder/RECODER-COMPOSE/reconnect.sh
chown -R recoder:recoder /home/recoder/RECODER-COMPOSE/
/////


sudo systemctl daemon-reload

sudo systemctl enable network-reconnect.service

sudo systemctl start network-reconnect.service
sudo systemctl status network-reconnect.service

sudo journalctl -u network-reconnect.service
