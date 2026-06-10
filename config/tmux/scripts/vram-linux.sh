#!/usr/bin/env bash
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | awk -F', *' '{printf "%.1f/%.1fG", $1/1024, $2/1024}'
