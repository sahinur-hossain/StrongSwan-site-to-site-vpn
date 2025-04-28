# === Install StrongSwan ===
apt install strongswan -y

# === Configuration File Path ===
read -rp "Enter the name of the configuration file for StrongSwan:" CONF_FILE

# === Validate the configuration file ===
if [ ! -f "$CONF_FILE" ]; then
    echo "ERROR: Configuration file $CONF_FILE not found."
    exit 1
fi

# === Extract values from the AWS configuration file ===
LEFT_ID=$(grep -m1 "leftid=" "$CONF_FILE" | awk -F= '{print $2}' | xargs)
TUNNEL1_RIGHT=$(grep -A15 "conn Tunnel1" "$CONF_FILE" | grep -m1 "right=" | awk -F= '{print $2}' | xargs)
TUNNEL2_RIGHT=$(grep -A15 "conn Tunnel2" "$CONF_FILE" | grep -m1 "right=" | awk -F= '{print $2}' | xargs)

PSK1=$(grep "$LEFT_ID $TUNNEL1_RIGHT" "$CONF_FILE" | awk -F'PSK' '{print $2}' | tr -d '" ')
PSK2=$(grep "$LEFT_ID $TUNNEL2_RIGHT" "$CONF_FILE" | awk -F'PSK' '{print $2}' | tr -d '" ')

# === Prompt user for missing information ===
echo "Please provide the missing network details:"
read -rp "On-premises CIDR Range (e.g. 192.168.1.0/24): " ON_PREM_CIDR
read -rp "AWS VPC CIDR Range (e.g. 10.0.0.0/16): " VPC_CIDR

# === Backup existing configuration ===
TIMESTAMP=$(date +%F-%T)
sudo cp /etc/ipsec.conf /etc/ipsec.conf.backup-$TIMESTAMP 2>/dev/null
sudo cp /etc/ipsec.secrets /etc/ipsec.secrets.backup-$TIMESTAMP 2>/dev/null

# === Write /etc/ipsec.conf ===
echo "Generating /etc/ipsec.conf..."
sudo tee /etc/ipsec.conf > /dev/null <<EOF
config setup
    charondebug="all"
    uniqueids=yes
    strictcrlpolicy=no

conn Tunnel1
    type=tunnel
    auto=start
    keyexchange=ikev2
    authby=psk
    leftid=$LEFT_ID
    leftsubnet=$ON_PREM_CIDR
    right=$TUNNEL1_RIGHT
    rightsubnet=$VPC_CIDR
    ike=aes128-sha1-modp1024
    esp=aes128-sha1-modp1024
    ikelifetime=28800s
    lifetime=3600s
    dpddelay=30s
    dpdtimeout=120s
    dpdaction=restart
    mark=100

conn Tunnel2
    type=tunnel
    auto=start
    keyexchange=ikev2
    authby=psk
    leftid=$LEFT_ID
    leftsubnet=$ON_PREM_CIDR
    right=$TUNNEL2_RIGHT
    rightsubnet=$VPC_CIDR
    ike=aes128-sha1-modp1024
    esp=aes128-sha1-modp1024
    ikelifetime=28800s
    lifetime=3600s
    dpddelay=30s
    dpdtimeout=120s
    dpdaction=restart
    mark=200
EOF

# === Write /etc/ipsec.secrets ===
echo "Generating /etc/ipsec.secrets..."
sudo tee /etc/ipsec.secrets > /dev/null <<EOF
$LEFT_ID $TUNNEL1_RIGHT : PSK "$PSK1"
$LEFT_ID $TUNNEL2_RIGHT : PSK "$PSK2"
EOF

# === Enable IP forwarding ===
echo "Enabling IP forwarding..."
sudo sed -i 's/^#*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# === Completed! Starting IPSec VPN StrongSwan ===
ipsec start
echo "VPN Configuration completed successfully."
