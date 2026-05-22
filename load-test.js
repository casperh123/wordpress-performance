import http from 'k6/http';
import { check } from 'k6';
import { Trend, Rate, Counter } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'https://thementainance.com/shop/';

const VUS = Number(__ENV.TEST_VUS || 10);
const WARMUP = __ENV.TEST_WARMUP || '1m';
const DURATION = __ENV.TEST_DURATION || '1m';
const COOLDOWN = __ENV.TEST_COOLDOWN || '30s';

const ttfb = new Trend('ttfb_ms', true);
const errorRate = new Rate('error_rate');
const totalRequests = new Counter('total_requests');

export const options = {
  stages: [
    { duration: WARMUP, target: VUS },
    { duration: DURATION, target: VUS },
    { duration: COOLDOWN, target: 0 },
  ],

  thresholds: {
    http_req_duration: ['p(95)<3000'],
    error_rate: ['rate<0.01'],
  },

  noConnectionReuse: false,
  userAgent: 'k6-wordpress-benchmark',
};

const headers = {
  Accept: 'text/html,application/xhtml+xml',
  'Accept-Encoding': 'gzip, deflate, br',
  'Cache-Control': 'no-cache',
  Pragma: 'no-cache',
};

export default function () {
  const res = http.get(BASE_URL, { headers });

  ttfb.add(res.timings.waiting);
  totalRequests.add(1);

  const ok = check(res, {
    'status 200': (r) => r.status === 200,
    'body not empty': (r) => r.body && r.body.length > 0,
    'no PHP fatal': (r) => !r.body.includes('Fatal error'),
  });

  errorRate.add(!ok);
}
