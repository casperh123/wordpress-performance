#!/usr/bin/env bash
set -euo pipefail

RUN_NAME="${1:?Run name required, e.g. baseline}"
SCRIPT="${2:-load-test.js}"
BASE_OUT_DIR="${3:-results}"

OUT_DIR="${BASE_OUT_DIR}/${RUN_NAME}"

VUS_LEVELS=(5 10 25 50 100 200)
RUNS_PER_LEVEL=3

WARMUP="10s"
DURATION="60s"
COOLDOWN="10s"

mkdir -p "$OUT_DIR"

echo "run_name,script,vu,run,req_per_s,p90_ms,p95_ms,p99_ms,ttfb_p95_ms,error_rate" > "$OUT_DIR/summary.csv"

for VUS in "${VUS_LEVELS[@]}"; do
  for RUN in $(seq 1 "$RUNS_PER_LEVEL"); do
    BENCH_NAME="${RUN_NAME}_vu${VUS}_run${RUN}"

    JSON_OUT="$OUT_DIR/${BENCH_NAME}.json"
    LOG_OUT="$OUT_DIR/${BENCH_NAME}.log"

    echo "Running $BENCH_NAME..."
    echo "VUs=$VUS warmup=$WARMUP duration=$DURATION cooldown=$COOLDOWN"

    TEST_VUS="$VUS" \
    TEST_WARMUP="$WARMUP" \
    TEST_DURATION="$DURATION" \
    TEST_COOLDOWN="$COOLDOWN" \
    k6 run \
      --summary-export "$JSON_OUT" \
      "$SCRIPT" | tee "$LOG_OUT"

    REQ_S=$(jq -r '.metrics.http_reqs.rate // 0' "$JSON_OUT")
    P90=$(jq -r '.metrics.http_req_duration["p(90)"] // 0' "$JSON_OUT")
    P95=$(jq -r '.metrics.http_req_duration["p(95)"] // 0' "$JSON_OUT")
    P99=$(jq -r '.metrics.http_req_duration["p(99)"] // 0' "$JSON_OUT")
    TTFB_P95=$(jq -r '.metrics.ttfb_ms["p(95)"] // 0' "$JSON_OUT")
    ERR=$(jq -r '.metrics.http_req_failed.value // 0' "$JSON_OUT")

    echo "$RUN_NAME,$SCRIPT,$VUS,$RUN,$REQ_S,$P90,$P95,$P99,$TTFB_P95,$ERR" \
      >> "$OUT_DIR/summary.csv"

    echo "Saved $BENCH_NAME"
    echo

    sleep 30
  done
done

echo "Done. Results saved to:"
echo "$OUT_DIR/summary.csv"
