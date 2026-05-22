## Experiment methodology

### Benchmark

The experiment is designed to stress-test a WordPress installation with varying degrees of simulated concurrent users.
A [K6 script](https://github.com/casperh123/wordpress-performance/blob/main/load-test.js) is run multiple times, varying the amount of VUs (Virtual Users). The benchmark is run 3 times for each degree of VUs, and the median results of this is used as the result.

The benchmark tests with 5, 10, 25, 50, 100, and 200 VUs.

### WordPress setup

The experiment uses [WordPress](https://wordpress.org/download/releases/) 6.9.4 and [WooCommerce](https://developer.woocommerce.com/releases/) 10.7, with NginX + PHPFPM  with 4 workers running PHP 8.3.
All pages are served uncached. Only a default installation of WooCommerce with the 6 default placeholder products is running alongside the plugin under test.

### Server

All benchmarks were conducted on a self-hosted Linux server running Ubuntu Server 26.04 LTS with an AMD Ryzen 3 PRO 4350G (4 cores / 8 threads) with 16 GB DDR4 memory and NVMe SSD storage.
