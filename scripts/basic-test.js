import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 10, // 10 virtual users
  duration: '30s', // ทดสอบเป็นเวลา 30 วินาที
};

export default function () {
  // ทดสอบ GET request
  let response = http.get('https://test.k6.io');
  
  // ตรวจสอบผลลัพธ์
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1); // หยุดพัก 1 วินาที
}