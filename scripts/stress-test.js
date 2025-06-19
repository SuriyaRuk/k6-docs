import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },  // เพิ่มขึ้นเป็น 100 users
    { duration: '5m', target: 100 },  // คงที่ 100 users
    { duration: '2m', target: 200 },  // เพิ่มขึ้นเป็น 200 users
    { duration: '5m', target: 200 },  // คงที่ 200 users
    { duration: '2m', target: 300 },  // เพิ่มขึ้นเป็น 300 users
    { duration: '5m', target: 300 },  // คงที่ 300 users
    { duration: '2m', target: 400 },  // เพิ่มขึ้นเป็น 400 users
    { duration: '5m', target: 400 },  // คงที่ 400 users
    { duration: '10m', target: 0 },   // ลดลงเป็น 0 users
  ],
};

export default function () {
  let response = http.get('https://test.k6.io');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 2000ms': (r) => r.timings.duration < 2000,
  });
  
  sleep(1);
}