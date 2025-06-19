import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '10s', target: 100 }, // เพิ่มขึ้นเร็วเป็น 100 users
    { duration: '1m', target: 100 },  // คงที่ 100 users
    { duration: '10s', target: 1400 }, // spike ไปที่ 1400 users
    { duration: '3m', target: 1400 }, // คงที่ 1400 users
    { duration: '10s', target: 100 }, // ลดลงเร็วเป็น 100 users
    { duration: '3m', target: 100 },  // คงที่ 100 users
    { duration: '10s', target: 0 },   // ลดลงเป็น 0 users
  ],
};

export default function () {
  let response = http.get('https://test.k6.io');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 5000ms': (r) => r.timings.duration < 5000,
  });
  
  sleep(1);
}