import http from 'k6/http';
import { check } from 'k6';

export let options = {
  hosts: {
    'httpbin.org': '8.8.8.8',
  },
  discardResponseBodies: true,
};

export default function() {
  const url = 'https://httpbin.org/post';
  
  const payload = JSON.stringify({
    id: Math.floor(Math.random() * 1000),
    name: `user_${Math.random().toString(36).substring(7)}`,
    email: `${Math.random().toString(36).substring(7)}@example.com`,
    timestamp: new Date().toISOString(),
    data: {
      value: Math.random() * 100,
      active: Math.random() > 0.5
    }
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  const response = http.post(url, payload, params);
  
  check(response, {
    'status is 200': (r) => r.status === 200,
  });

  //make err
  console.log(response.body);
}
