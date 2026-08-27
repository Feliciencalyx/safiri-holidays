const http = require('http');

const data = JSON.stringify({
  email: 'felicien.calylx@safiriholidays.com',
  password: 'SafiriPass2026!',
  name: 'Felicien Calylx',
  phone: '+250788000123',
  passportNumber: 'PC9920148X',
});

const req = http.request(
  {
    hostname: 'localhost',
    port: 5000,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length,
    },
  },
  (res) => {
    let body = '';
    res.on('data', (chunk) => (body += chunk));
    res.on('end', () => {
      console.log('STATUS:', res.statusCode);
      console.log('RESPONSE:', body);
    });
  }
);

req.on('error', (e) => console.error(e));
req.write(data);
req.end();
