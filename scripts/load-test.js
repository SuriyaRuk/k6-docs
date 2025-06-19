import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // เพิ่มขึ้นเป็น 100 users ใน 2 นาที
    { duration: '5m', target: 100 }, // คงที่ 100 users เป็นเวลา 5 นาที
    { duration: '2m', target: 200 }, // เพิ่มขึ้นเป็น 200 users ใน 2 นาที
    { duration: '5m', target: 200 }, // คงที่ 200 users เป็นเวลา 5 นาที
    { duration: '2m', target: 0 },   // ลดลงเป็น 0 users ใน 2 นาที
  ],
};

export default function () {
  let response = http.get('https://test.k6.io');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  
  sleep(1);
}