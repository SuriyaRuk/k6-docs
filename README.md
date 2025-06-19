# K6 Load Testing Training

## 1. การติดตั้ง K6 ด้วย Docker

### ความต้องการ
- Docker และ Docker Compose ติดตั้งแล้ว

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
docker run --rm -v $(pwd)/scripts:/scripts -v $(pwd)/results:/results grafana/k6 run /scripts/basic-test.js

# รันพร้อมเก็บผลลัพธ์
docker run --rm -v $(pwd)/scripts:/scripts -v $(pwd)/results:/results -e K6_OUT=json=/results/result.json grafana/k6 run /scripts/basic-test.js
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

## การใช้งาน

1. Clone repository นี้
2. สร้าง scripts ใน folder `scripts/`
3. รัน `docker-compose up` หรือ command ตามต้องการ
4. ดูผลลัพธ์ใน folder `results/`# k6-docs
# k6-docs
# k6-docs
