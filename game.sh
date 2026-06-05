#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$ROOT_DIR/engine"
STAGES_DIR="$ROOT_DIR/stages"
SANDBOX_DIR="$ROOT_DIR/sandbox"
SAVE_FILE="$ROOT_DIR/.progress"
REPORT_DIR="$ROOT_DIR/incident_reports"

. "$ENGINE_DIR/ui.sh"
. "$ENGINE_DIR/safety.sh"
. "$ENGINE_DIR/scoring.sh"
. "$ENGINE_DIR/command_parser.sh"
. "$ENGINE_DIR/stage_runner.sh"

init_game() {
  mkdir -p "$SANDBOX_DIR"/{logs,app,config,backup,remote,docker,k8s,aws} "$REPORT_DIR"
  seed_sandbox
  load_progress
}

show_menu() {
  while true; do
    clear_screen
    logo
    print_info "DevOps Linux Command Training CLI"
    echo
    echo "1) 게임 시작"
    echo "2) 스테이지 선택"
    echo "3) 카테고리별 문제 풀기"
    echo "4) 도움말"
    echo "5) 전체 명령어 예시 보기"
    echo "6) 전체 Incident Report 보기"
    echo "0) 종료"
    echo
    printf "%s" "$(color "$CYAN" "선택> ")"
    read -r choice
    case "$choice" in
      1) run_all_stages ;;
      2) select_stage_menu ;;
      3) select_category_menu ;;
      4) show_help; pause ;;
      5) show_command_examples; pause ;;
      6) show_all_reports; pause ;;
      0|q|quit|exit) print_info "훈련을 종료합니다."; exit 0 ;;
      *) print_warn "메뉴 번호를 입력하세요."; sleep 1 ;;
    esac
  done
}

init_game
show_menu
