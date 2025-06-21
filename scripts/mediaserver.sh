#!/bin/bash

set -e

echo "=== Updating system ==="
sudo apt update

echo "=== Installing Samba ==="
sudo apt install samba -y

echo "=== Creating media folder ==="
sudo mkdir -p /srv/media
sudo chmod -R 777 /srv/media

echo "=== Creating Samba user ==="
# Replace this with echoing a password file if needed
sudo smbpasswd -a recoder

echo "=== Adding Samba share ==="
sudo bash -c 'cat >> /etc/samba/smb.conf <<EOF

[MediaShare]
   path = /srv/media
   available = yes
   valid users = recoder
   read only = no
   browsable = yes
   public = no
   writable = yes
EOF'

echo "=== Restarting Samba ==="
sudo systemctl restart smbd

echo "=== Installing MiniDLNA ==="
sudo apt install minidlna -y

echo "=== Configuring MiniDLNA ==="
sudo sed -i 's|^#\?media_dir=.*|media_dir=V,/srv/media|' /etc/minidlna.conf
sudo sed -i 's|^#\?friendly_name=.*|friendly_name=UbuntuDLNA|' /etc/minidlna.conf
sudo sed -i 's|^#\?inotify=.*|inotify=yes|' /etc/minidlna.conf

echo "=== Restarting and enabling MiniDLNA ==="
sudo systemctl restart minidlna
sudo systemctl enable minidlna
sudo systemctl status minidlna
sudo minidlnad -R

echo "=== Allowing DLNA ports through firewall ==="
sudo ufw allow 8200/tcp
sudo ufw allow 1900/udp

echo "=== Installing qBittorrent-nox ==="
sudo apt install qbittorrent-nox -y

echo "=== Creating qBittorrent systemd service ==="
sudo bash -c 'cat > /etc/systemd/system/qbittorrent.service <<EOF
[Unit]
Description=qBittorrent Daemon Service
After=network.target

[Service]
User=recoder
ExecStart=/usr/bin/qbittorrent-nox
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

echo "=== Enabling and starting qBittorrent service ==="
sudo systemctl daemon-reexec
sudo systemctl enable qbittorrent
sudo systemctl start qbittorrent

echo "=== Done! ==="
echo "➡️  Samba Share: \\\\<your-ip>\\MediaShare"
echo "➡️  DLNA Name: UbuntuDLNA"
echo "➡️  qBittorrent Web UI: http://<your-ip>:8080 (default login: admin / adminadmin)"
