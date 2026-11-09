#!/usr/bin/env bash
# Stops and removes the Redis container (data is lost, Redis does not write anything to disk).
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" && docker compose down
