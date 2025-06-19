#!/bin/bash

# OS Tuning Script for K6 Load Testing
# ปรับแต่งระบบปฏิบัติการเพื่อรองรับ load testing

echo "🔧 OS Tuning for K6 Load Testing"
echo "================================="

# ตรวจสอบสิทธิ์ root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

echo "📊 Current system limits:"
echo "- File descriptors: $(ulimit -n)"
echo "- Max processes: $(ulimit -u)"

# Backup original configuration
echo "💾 Backing up original configurations..."
cp /etc/security/limits.conf /etc/security/limits.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
cp /etc/sysctl.conf /etc/sysctl.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# 1. เพิ่ม file descriptor limits
echo "🔢 Setting file descriptor limits..."
cat >> /etc/security/limits.conf << EOF

# K6 Load Testing - File Descriptor Limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
root soft nofile 65536
root hard nofile 65536
EOF

# 2. ปรับแต่ง network parameters
echo "🌐 Tuning network parameters..."
cat >> /etc/sysctl.conf << EOF

# K6 Load Testing - Network Tuning
# TCP connection limits
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535

# TCP timeout settings
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_intvl = 75

# TCP connection reuse
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1

# Port range
net.ipv4.ip_local_port_range = 1024 65535

# TCP buffer sizes
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216

# Increase max number of packets in backlog queue
net.core.netdev_budget = 600

# TCP congestion control
net.ipv4.tcp_congestion_control = bbr
EOF

# 3. Apply sysctl settings immediately
echo "⚡ Applying network settings..."
sysctl -p /etc/sysctl.conf

# 4. Set session limits for current user
echo "👤 Setting session limits..."
ulimit -n 65536
ulimit -u 65536

# 5. Display current settings
echo ""
echo "✅ OS Tuning completed!"
echo "📋 New system settings:"
echo "- File descriptors: $(ulimit -n)"
echo "- Max processes: $(ulimit -u)"
echo "- TCP max connections: $(sysctl -n net.core.somaxconn)"
echo "- TCP fin timeout: $(sysctl -n net.ipv4.tcp_fin_timeout)"
echo "- Port range: $(sysctl -n net.ipv4.ip_local_port_range)"

echo ""
echo "🔄 Note: Some changes require system reboot to take full effect"
echo "💡 Run 'sysctl -p' to reload sysctl settings"
echo "🐳 Docker containers will inherit these settings when using --privileged flag"

# Optional: Create verification script
cat > /tmp/verify-tuning.sh << 'EOF'
#!/bin/bash
echo "🔍 Verifying OS tuning settings:"
echo "File descriptors limit: $(ulimit -n)"
echo "Process limit: $(ulimit -u)"
echo "TCP max connections: $(sysctl -n net.core.somaxconn 2>/dev/null || echo 'N/A')"
echo "TCP fin timeout: $(sysctl -n net.ipv4.tcp_fin_timeout 2>/dev/null || echo 'N/A')"
echo "Port range: $(sysctl -n net.ipv4.ip_local_port_range 2>/dev/null || echo 'N/A')"
EOF

chmod +x /tmp/verify-tuning.sh
echo "🧪 Verification script created at /tmp/verify-tuning.sh"