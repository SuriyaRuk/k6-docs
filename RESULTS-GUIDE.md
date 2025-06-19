# การอ่านและวิเคราะห์ผลลัพธ์ K6

## ตัวชี้วัดสำคัญ (Key Metrics)

### 1. Response Time (เวลาตอบสนอง)
- **http_req_duration**: เวลาที่ใช้ในการรับ response
- **http_req_connecting**: เวลาที่ใช้ในการเชื่อมต่อ
- **http_req_waiting**: เวลาที่รอ response แรก

### 2. Throughput (ปริมาณงาน)
- **http_reqs**: จำนวน HTTP requests ทั้งหมด
- **http_req_rate**: จำนวน requests ต่อวินาที

### 3. Error Rate (อัตราข้อผิดพลาด)
- **http_req_failed**: จำนวน requests ที่ล้มเหลว
- **checks**: ผลการตรวจสอบ pass/fail

### 4. Virtual Users
- **vus**: จำนวน virtual users ที่ active
- **vus_max**: จำนวน virtual users สูงสุด

## การอ่านไฟล์ JSON

### โครงสร้างข้อมูล JSON
```json
{
  "type": "Point",
  "metric": "http_req_duration",
  "data": {
    "time": "2024-01-15T10:30:45.123Z",
    "value": 145.67,
    "tags": {
      "method": "GET",
      "status": "200",
      "url": "https://test.k6.io"
    }
  }
}
```

### การใช้ jq สำหรับวิเคราะห์
```bash
# เวลาตอบสนองเฉลี่ย
cat result.json | jq -r 'select(.metric=="http_req_duration") | .data.value' | awk '{sum+=$1; count++} END {print sum/count}'

# จำนวน requests ทั้งหมด
cat result.json | jq -r 'select(.metric=="http_reqs") | .data.value' | awk '{sum+=$1} END {print sum}'

# อัตราความสำเร็จ
cat result.json | jq -r 'select(.metric=="checks") | .data.value' | awk '{sum+=$1} END {print sum}'
```

## การอ่านไฟล์ CSV

### โครงสร้างข้อมูล CSV
```
metric_name,timestamp,metric_value,check,error,error_code,expected_response,group,method,name,proto,scenario,service,status,subproto,tls_version,url
http_req_duration,1642248645.123,145.67,,,,,GET,https://test.k6.io,HTTP/1.1,default,,200,,TLS 1.3,https://test.k6.io
```

### การใช้ Excel/Google Sheets
1. เปิดไฟล์ CSV
2. สร้าง Pivot Table
3. วิเคราะห์ข้อมูลตาม metric_name
4. สร้างกราฟแสดงแนวโน้ม

## การวิเคราะห์ผลลัพธ์

### 1. Load Testing Results
**เป้าหมาย**: ทดสอบประสิทธิภาพภายใต้ load ปกติ

**ตัวชี้วัดที่สำคัญ**:
- Response time ต้องอยู่ในเกณฑ์ที่ยอมรับได้
- Error rate ต้องต่ำกว่า 1%
- Throughput ต้องตอบสนองความต้องการ

**สัญญาณเตือน**:
- Response time เพิ่มขึ้นเรื่อย ๆ
- Error rate เพิ่มขึ้น
- Memory หรือ CPU ใช้งานสูง

### 2. Stress Testing Results
**เป้าหมาย**: หาจุดที่ระบบเริ่มมีปัญหา

**ตัวชี้วัดที่สำคัญ**:
- จุดที่ response time เพิ่มขึ้นอย่างรวดเร็ว
- จุดที่ error rate เริ่มสูงขึ้น
- Breaking point ของระบบ

### 3. Spike Testing Results
**เป้าหมาย**: ทดสอบการจัดการ traffic ที่เพิ่มขึ้นอย่างฉับพลัน

**ตัวชี้วัดที่สำคัญ**:
- เวลาที่ใช้ในการ scale up
- ความเสถียรระหว่าง spike
- การ recovery หลัง spike

## เครื่องมือสำหรับวิเคราะห์

### 1. Command Line Tools
```bash
# ใช้ jq สำหรับ JSON
sudo apt install jq  # Ubuntu/Debian
brew install jq      # macOS

# ใช้ csvkit สำหรับ CSV
pip install csvkit
```

### 2. Python Analysis
```python
import pandas as pd
import json

# อ่าน JSON results
with open('result.json', 'r') as f:
    data = [json.loads(line) for line in f]

# อ่าน CSV results
df = pd.read_csv('result.csv')

# วิเคราะห์เวลาตอบสนอง
response_times = df[df['metric_name'] == 'http_req_duration']['metric_value']
print(f"Average: {response_times.mean():.2f}ms")
print(f"95th percentile: {response_times.quantile(0.95):.2f}ms")
```

### 3. Visualization Tools
- **Grafana**: สำหรับ real-time monitoring
- **Excel/Google Sheets**: สำหรับการวิเคราะห์เบื้องต้น
- **Python (matplotlib/seaborn)**: สำหรับกราฟขั้นสูง

## การแปลผลลัพธ์

### ✅ ผลลัพธ์ที่ดี
- Response time สม่ำเสมอและต่ำ
- Error rate ต่ำกว่า 1%
- Throughput ตอบสนองความต้องการ
- ระบบ stable ตลอดการทดสอบ

### ⚠️ ผลลัพธ์ที่ต้องปรับปรุง
- Response time เพิ่มขึ้นเรื่อย ๆ
- Error rate สูงกว่า 1-5%
- Throughput ไม่เป็นไปตามเป้าหมาย
- มี timeout บางครั้ง

### ❌ ผลลัพธ์ที่มีปัญหา
- Response time สูงมาก (>5 วินาที)
- Error rate สูงกว่า 5%
- ระบบล่ม (crash) ระหว่างทดสอบ
- Connection timeout เยอะ

## การใช้ Script Analyzer

### 1. Quick Analysis
```bash
./analyze-results.sh
# เลือก option 1 สำหรับ summary
```

### 2. Detailed Analysis
```bash
python3 analyze-results.py
# หรือ
./analyze-results.sh
# เลือก option 2
```

### 3. Specific File Analysis
```bash
python3 analyze-results.py results/load-test_20240115_103045.json
```

## Best Practices

1. **เก็บ baseline**: บันทึกผลลัพธ์เมื่อระบบทำงานปกติ
2. **ทดสอบสม่ำเสมอ**: รันทดสอบหลังการ deploy ใหม่
3. **เฝ้าดู trends**: สังเกตการเปลี่ยนแปลงของ metrics ตลอดเวลา
4. **กำหนด thresholds**: ตั้งค่าเกณฑ์ที่ยอมรับได้สำหรับแต่ละ metric
5. **Document findings**: บันทึกผลการวิเคราะห์และข้อเสนอแนะ