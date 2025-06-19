# K6 Load Testing Training

## 1. การติดตั้ง K6 ด้วย Docker

### ความต้องการ
- Docker และ Docker Compose ที่ติดตั้งแล้ว

### วิธีการติดตั้ง

#### วิธีที่ 1: ใช้ Docker Compose (แนะนำ)
```bash
# รันโดยตรง
docker-compose up

# หรือรันเฉพาะ service
docker-compose run k6 run /scripts/basic-test.js
```

#### วิธีที่ 2: ใช้ Docker Command
```bash
# รัน K6 script
docker run --net=host --rm -v $(pwd)/scripts:/scripts -v $(pwd)/results:/results grafana/k6 run /scripts/basic-test.js

# รันพร้อมเก็บผลลัพธ์
docker run --net=host --rm -v $(pwd)/scripts:/scripts -v $(pwd)/results:/results -e K6_OUT=json=/results/result.json grafana/k6 run /scripts/basic-test.js
```

## 2. การรัน Script

### การรันแบบพื้นฐาน
```bash
# รัน script ผ่าน docker-compose
docker-compose run k6 run /scripts/basic-test.js

# รัน script แบบกำหนด virtual users และ duration
docker-compose run k6 run --vus 10 --duration 30s /scripts/basic-test.js
```

### การรันแบบขั้นสูง
```bash
# รันแบบ stages
docker-compose run k6 run /scripts/stress-test.js

# รันแบบ spike test
docker-compose run k6 run /scripts/spike-test.js
```

## 3. ตัวอย่าง Scripts

### Basic Test
- `scripts/basic-test.js` - การทดสอบพื้นฐาน

### Advanced Tests
- `scripts/load-test.js` - Load testing
- `scripts/stress-test.js` - Stress testing
- `scripts/spike-test.js` - Spike testing
- `scripts/api-test.js` - API testing

## 4. การเก็บผลลัพธ์

### รูปแบบ JSON
```bash
docker-compose run -e K6_OUT=json=/results/result.json k6 run /scripts/basic-test.js
```

### รูปแบบ CSV
```bash
docker-compose run -e K6_OUT=csv=/results/result.csv k6 run /scripts/basic-test.js
```

### หลายรูปแบบพร้อมกัน
```bash
docker-compose run -e K6_OUT=json=/results/result.json,csv=/results/result.csv k6 run /scripts/basic-test.js
```

## 5. การอ่านผลลัพธ์

### การอ่านไฟล์ JSON
- ใช้ `jq` command หรือเครื่องมือ JSON viewer
- Import เข้า monitoring tools เช่น Grafana

### การอ่านไฟล์ CSV
- เปิดด้วย Excel หรือ Google Sheets
- ใช้ Python pandas สำหรับการวิเคราะห์

### ตัวชี้วัดสำคัญ
- **Response Time**: เวลาตอบสนอง
- **Throughput**: จำนวน requests per second
- **Error Rate**: อัตราข้อผิดพลาด
- **Virtual Users**: จำนวน concurrent users

## 6. การปรับแต่งระบบปฏิบัติการ (OS Tuning)

สำหรับการทดสอบ load ที่มี concurrent users สูง ควรปรับแต่งระบบปฏิบัติการเพื่อรองรับการเชื่อมต่อจำนวนมาก

### การปรับแต่งแบบอัตโนมัติ
```bash
# รัน OS tuning script (ต้องใช้ sudo)
sudo ./scripts/tune-os.sh
```

### การปรับแต่งแบบ Manual

#### 1. เพิ่ม File Descriptor Limits
แก้ไขไฟล์ `/etc/security/limits.conf`:
```
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
```

#### 2. ปรับแต่ง Network Parameters
แก้ไขไฟล์ `/etc/sysctl.conf`:
```
# TCP connection limits
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535

# TCP timeout settings
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_tw_reuse = 1

# Port range
net.ipv4.ip_local_port_range = 1024 65535
```

#### 3. Apply Settings
```bash
# Apply sysctl settings
sudo sysctl -p

# Set current session limits
ulimit -n 65536
ulimit -u 65536
```

### Docker Configuration
Docker Compose ได้รับการปรับแต่งแล้วใน `docker-compose.yml`:
- `ulimits`: เพิ่ม file descriptor limits
- `sysctls`: ปรับแต่ง network parameters
- `privileged: true`: อนุญาตให้ container ใช้ system resources

### การตรวจสอบการปรับแต่ง
```bash
# ตรวจสอบ file descriptor limit
ulimit -n

# ตรวจสอบ network settings
sysctl net.core.somaxconn
sysctl net.ipv4.tcp_fin_timeout
```

## การใช้งาน

1. Clone repository นี้
2. ปรับแต่งระบบปฏิบัติการ (แนะนำ): `sudo ./scripts/tune-os.sh`
3. สร้าง scripts ใน folder `scripts/`
4. รัน `docker-compose up` หรือ command ตามต้องการ
5. ดูผลลัพธ์ใน folder `results/`
