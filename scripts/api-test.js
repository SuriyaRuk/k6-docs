import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 50,
  duration: '5m',
};

const BASE_URL = 'https://jsonplaceholder.typicode.com';

export default function () {
  // Test GET /posts
  let getResponse = http.get(`${BASE_URL}/posts`);
  check(getResponse, {
    'GET /posts status is 200': (r) => r.status === 200,
    'GET /posts response time < 1000ms': (r) => r.timings.duration < 1000,
  });

  // Test GET /posts/1
  let getSingleResponse = http.get(`${BASE_URL}/posts/1`);
  check(getSingleResponse, {
    'GET /posts/1 status is 200': (r) => r.status === 200,
    'GET /posts/1 has correct id': (r) => JSON.parse(r.body).id === 1,
  });

  // Test POST /posts
  let postData = {
    title: 'foo',
    body: 'bar',
    userId: 1,
  };
  
  let postResponse = http.post(`${BASE_URL}/posts`, JSON.stringify(postData), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(postResponse, {
    'POST /posts status is 201': (r) => r.status === 201,
    'POST /posts response time < 1000ms': (r) => r.timings.duration < 1000,
  });

  // Test PUT /posts/1
  let putData = {
    id: 1,
    title: 'updated title',
    body: 'updated body',
    userId: 1,
  };
  
  let putResponse = http.put(`${BASE_URL}/posts/1`, JSON.stringify(putData), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(putResponse, {
    'PUT /posts/1 status is 200': (r) => r.status === 200,
  });

  // Test DELETE /posts/1
  let deleteResponse = http.del(`${BASE_URL}/posts/1`);
  check(deleteResponse, {
    'DELETE /posts/1 status is 200': (r) => r.status === 200,
  });

  sleep(1);
}