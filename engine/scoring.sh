#!/usr/bin/env bash

TOTAL_STAGES=30
declare -a STAGE_SCORES
declare -a STAGE_DONE

load_progress() {
  if [ -f "$SAVE_FILE" ]; then
    # shellcheck disable=SC1090
    . "$SAVE_FILE"
  fi
}

save_progress() {
  {
    echo "# generated progress"
    for i in $(seq 1 "$TOTAL_STAGES"); do
      eval "v=\${STAGE_SCORE_$i:-}"
      eval "d=\${STAGE_DONE_$i:-0}"
      [ -n "$v" ] && echo "STAGE_SCORE_$i=$v"
      echo "STAGE_DONE_$i=$d"
    done
  } > "$SAVE_FILE"
}

record_score() {
  n="$1"; score="$2"
  eval "old=\${STAGE_SCORE_$n:-}"
  if [ -z "$old" ] || [ "$score" -gt "$old" ]; then
    eval "STAGE_SCORE_$n=$score"
  fi
  eval "STAGE_DONE_$n=1"
  save_progress
}

grade_for() {
  avg="$1"
  if [ "$avg" -ge 90 ]; then echo "S"
  elif [ "$avg" -ge 80 ]; then echo "A"
  elif [ "$avg" -ge 70 ]; then echo "B"
  elif [ "$avg" -ge 60 ]; then echo "C"
  else echo "F"; fi
}

show_final_score() {
  total=0; done_count=0
  for i in $(seq 1 "$TOTAL_STAGES"); do
    eval "s=\${STAGE_SCORE_$i:-}"
    if [ -n "$s" ]; then
      total=$((total + s)); done_count=$((done_count + 1))
    fi
  done
  [ "$done_count" -eq 0 ] && avg=0 || avg=$((total / done_count))
  echo
  hr
  print_info "총점: $total / $((done_count * 100))"
  print_info "완료 스테이지: $done_count / $TOTAL_STAGES"
  print_info "평균점수: $avg"
  print_info "등급: $(grade_for "$avg")"
  hr
}
