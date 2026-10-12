#!/usr/bin/env bash
# Zatrzymuje i usuwa kontener Redisa (dane znikają, Redis nie zapisuje niczego na dysk).
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" && docker compose down
