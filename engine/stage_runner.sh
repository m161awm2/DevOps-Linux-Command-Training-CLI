#!/usr/bin/env bash

stage_reset_vars() {
  STAGE_ID=""; STAGE_TITLE=""; STAGE_SITUATION=""; STAGE_GOAL=""
  STAGE_HINT=""; STAGE_EXAMPLE=""; STAGE_EXPLAIN=""; STAGE_WHY=""
  STAGE_REPORT=""; STAGE_WRONG_HINT=""; STAGE_ANSWER_DETAIL=""; ANSWERS=()
}

set_stage() {
  STAGE_ID="$1"; STAGE_TITLE="$2"; STAGE_SITUATION="$3"; STAGE_GOAL="$4"
  STAGE_HINT="$5"; STAGE_EXAMPLE="$6"; STAGE_EXPLAIN="$7"; STAGE_WHY="$8"
  STAGE_REPORT="$9"; shift 9
  STAGE_WRONG_HINT="$1"; STAGE_ANSWER_DETAIL="$2"; shift 2
  ANSWERS=("$@")
}

category_count() {
  echo 7
}

category_name() {
  case "$1" in
    1) echo "Linux 기본/파일" ;;
    2) echo "로그 검색/추적" ;;
    3) echo "운영 점검/서비스" ;;
    4) echo "원격 접속/Git 배포" ;;
    5) echo "Docker" ;;
    6) echo "Kubernetes" ;;
    7) echo "네트워크/AWS" ;;
    *) echo "" ;;
  esac
}

category_stages() {
  case "$1" in
    1) echo "1 2 3 4" ;;
    2) echo "5 6 7" ;;
    3) echo "8 9 10 11 12 13 14 15 16 17 18" ;;
    4) echo "19 20 21" ;;
    5) echo "22 23 24 25" ;;
    6) echo "26 27 28" ;;
    7) echo "29 30" ;;
    *) echo "" ;;
  esac
}

load_stage_file() {
  n="$1"; padded="$(printf "%02d" "$n")"
  file="$(ls "$STAGES_DIR/stage${padded}_"*.sh 2>/dev/null | head -1)"
  [ -f "$file" ] || return 1
  stage_reset_vars
  # shellcheck disable=SC1090
  . "$file"
  "load_stage_${padded}"
}

show_stage() {
  clear_screen
  logo
  printf "%s\n\n" "$(color "$BOLD$MAGENTA" "[Stage $STAGE_ID] $STAGE_TITLE")"
  printf "%s\n%s\n\n" "$(color "$YELLOW" "상황:")" "$STAGE_SITUATION"
  printf "%s\n%s\n\n" "$(color "$YELLOW" "목표:")" "$STAGE_GOAL"
  printf "%s\n%s\n\n" "$(color "$YELLOW" "사용할 수 있는 명령어 힌트:")" "$STAGE_HINT"
  printf "%s\n%s\n\n" "$(color "$YELLOW" "명령어 예시:")" "$STAGE_EXAMPLE"
  printf "%s\n" "$(color "$DIM" "특수 명령어: help, hint, answer, reset, quit")"
  hr
}

show_stage_help() {
  show_stage
  cat <<'EOF'
특수 명령어
- help   : 현재 스테이지 내용을 다시 표시
- hint   : 추가 힌트 보기, -5점
- answer : 오답 3회 이후 명령 구조 보기
- reset  : 현재 스테이지 점수와 상태 초기화
- quit   : 메인 메뉴로 돌아가기
EOF
}

normalize_input() {
  input="$1"
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  printf "%s" "$input"
}

is_stage_correct() {
  input="$1"
  for pattern in "${ANSWERS[@]}"; do
    if [[ "$input" =~ $pattern ]]; then return 0; fi
  done
  return 1
}

show_answer_candidates() {
  echo "정답으로 인정할 명령 구조:"
  for pattern in "${ANSWERS[@]}"; do
    case "$pattern" in
      *pwd*) echo "- pwd" ;;
      *"ls"*) echo "- ls [옵션] [경로]" ;;
      *"cat"*) echo "- cat 파일명" ;;
      *"less"*) echo "- less 파일명" ;;
      *"head"*) echo "- head [옵션] 파일명" ;;
      *"tail"*) echo "- tail [옵션] 파일명" ;;
      *"grep"*) echo "- grep [옵션] 검색어 파일명" ;;
      *"find"*) echo "- find 시작경로 조건 패턴" ;;
      *"chmod"*) echo "- chmod 권한 파일명" ;;
      *"ps"*) echo "- ps [옵션] | grep 프로세스명" ;;
      *"ss"*|*"lsof"*|*"netstat"*) echo "- 포트 확인 명령 [옵션] 포트번호" ;;
      *"export"*) echo "- export 변수명=값" ;;
      *"env"*) echo "- env | grep 변수명" ;;
      *"pm2"*) echo "- pm2 status 또는 pm2 restart 앱이름" ;;
      *"systemctl"*) echo "- systemctl status 서비스명" ;;
      *"journalctl"*) echo "- journalctl -u 서비스명 [옵션]" ;;
      *"nginx"*) echo "- nginx -t" ;;
      *"df"*) echo "- df -h" ;;
      *"du"*) echo "- du -sh 경로" ;;
      *"tar"*) echo "- tar -czvf 압축파일 대상경로" ;;
      *"crontab"*) echo "- crontab -l" ;;
      *"ssh"*) echo "- ssh [-i 키파일] 사용자@호스트" ;;
      *"scp"*) echo "- scp [-i 키파일] 원본 사용자@호스트:대상경로" ;;
      *"docker"*"ps"*) echo "- docker ps [옵션]" ;;
      *"docker"*"logs"*) echo "- docker logs 컨테이너명" ;;
      *"docker"*"exec"*) echo "- docker exec 컨테이너명 명령" ;;
      *"docker"*"inspect"*) echo "- docker inspect 컨테이너명" ;;
      *"kubectl"*"get"*) echo "- kubectl get 리소스 [옵션]" ;;
      *"kubectl"*"describe"*) echo "- kubectl describe 리소스 이름 [옵션]" ;;
      *"kubectl"*"logs"*) echo "- kubectl logs 파드명 [옵션]" ;;
      *"dig"*|*"nslookup"*|*"traceroute"*) echo "- DNS/네트워크 명령 호스트명" ;;
      *"ip"*) echo "- ip route 또는 ip a" ;;
      *"aws"*) echo "- aws 서비스 작업 [옵션]" ;;
      *) echo "- ${pattern//\\/}" ;;
    esac
  done | awk '!seen[$0]++'
}

show_option_help() {
  context="$STAGE_HINT $STAGE_EXAMPLE $STAGE_WRONG_HINT $STAGE_ANSWER_DETAIL ${ANSWERS[*]}"
  printed=0
  print_option_meaning() {
    [ "$printed" -eq 0 ] && echo "옵션 뜻:"
    printed=1
    echo "- $1: $2"
  }

  case "$context" in
    *tail*"-f"*|*tail*"\\-f"*) print_option_meaning "-f" "파일 끝을 따라가며 새로 추가되는 로그를 계속 출력합니다." ;;
  esac
  case "$context" in
    *tail*"-n"*|*tail*"\\-n"*|*journalctl*"-n"*|*journalctl*"\\-n"*) print_option_meaning "-n" "출력할 줄 수를 지정합니다." ;;
  esac
  case "$context" in
    *grep*"-i"*|*grep*"\\-i"*) print_option_meaning "-i" "대소문자를 구분하지 않고 검색합니다." ;;
  esac
  case "$context" in
    *find*"-name"*|*find*"\\-name"*) print_option_meaning "-name" "파일 이름 패턴으로 검색합니다." ;;
  esac
  case "$context" in
    *"ls -l"*|*"ls[[:space:]]+-l"*|*"chmod"*"ls -l"*) print_option_meaning "-l" "파일 권한, 소유자, 크기 같은 자세한 목록 정보를 보여줍니다." ;;
  esac
  case "$context" in
    *chmod*"+x"*|*chmod*"\\+x"*) print_option_meaning "+x" "파일에 실행 권한을 추가합니다." ;;
  esac
  case "$context" in
    *ss*"-ltnp"*|*ss*"\\-ltnp"*) print_option_meaning "-ltnp" "LISTEN TCP 포트와 관련 프로세스 정보를 숫자 형식으로 보여줍니다." ;;
  esac
  case "$context" in
    *lsof*"-i"*|*lsof*"\\-i"*) print_option_meaning "-i" "네트워크 소켓 또는 특정 포트 사용 정보를 조회합니다." ;;
  esac
  case "$context" in
    *curl*"-I"*|*curl*"\\-I"*) print_option_meaning "-I" "본문 없이 HTTP 응답 헤더만 요청합니다." ;;
  esac
  case "$context" in
    *journalctl*"-u"*|*journalctl*"\\-u"*) print_option_meaning "-u" "특정 systemd 서비스 유닛의 로그만 조회합니다." ;;
  esac
  case "$context" in
    *nginx*"-t"*|*nginx*"\\-t"*) print_option_meaning "-t" "Nginx 설정 파일 문법을 테스트합니다." ;;
  esac
  case "$context" in
    *df*"-h"*|*df*"\\-h"*) print_option_meaning "-h" "용량을 KB/MB/GB처럼 사람이 읽기 쉬운 단위로 보여줍니다." ;;
  esac
  case "$context" in
    *du*"-sh"*|*du*"\\-sh"*) print_option_meaning "-sh" "대상별 총 사용량을 사람이 읽기 쉬운 단위로 요약합니다." ;;
  esac
  case "$context" in
    *tar*"-czvf"*|*tar*"\\-czvf"*) print_option_meaning "-czvf" "새 tar 아카이브를 만들고 gzip으로 압축하며 처리 파일을 표시하고 파일명을 지정합니다." ;;
  esac
  case "$context" in
    *tar*"-zcvf"*|*tar*"\\-zcvf"*) print_option_meaning "-zcvf" "gzip 압축 tar 아카이브를 새로 만들고 처리 파일을 표시하며 파일명을 지정합니다." ;;
  esac
  case "$context" in
    *crontab*"-l"*|*crontab*"\\-l"*) print_option_meaning "-l" "현재 사용자의 crontab 목록을 출력합니다." ;;
  esac
  case "$context" in
    *crontab*"-e"*|*crontab*"\\-e"*) print_option_meaning "-e" "현재 사용자의 crontab을 편집합니다." ;;
  esac
  case "$context" in
    *ssh*"-i"*|*ssh*"\\-i"|*scp*"-i"*|*scp*"\\-i"*) print_option_meaning "-i" "접속에 사용할 개인키 파일 경로를 지정합니다." ;;
  esac
  case "$context" in
    *docker*"ps"*"-a"*|*docker*"ps"*"\\-a"*) print_option_meaning "-a" "실행 중인 컨테이너뿐 아니라 중지된 컨테이너도 함께 보여줍니다." ;;
  esac
  case "$context" in
    *docker*"exec"*"-it"*|*docker*"exec"*"\\-it"*) print_option_meaning "-it" "대화형 입력을 열고 터미널을 붙여 컨테이너 안에서 명령을 실행합니다." ;;
  esac
  case "$context" in
    *docker*"compose"*"-d"*|*docker*"compose"*"\\-d"*) print_option_meaning "-d" "서비스를 백그라운드에서 실행합니다." ;;
  esac
}

write_incident_report() {
  n="$1"; score="$2"; file="$REPORT_DIR/stage$(printf "%02d" "$n")_incident_report.md"
  {
    echo "# Stage $STAGE_ID Incident Report"
    echo
    echo "- Title: $STAGE_TITLE"
    echo "- Score: $score"
    echo "- Situation: $STAGE_SITUATION"
    echo "- Resolution: $STAGE_REPORT"
  } > "$file"
}

finish_stage() {
  score="$1"; revealed="$2"
  [ "$revealed" -eq 1 ] && [ "$score" -gt 60 ] && score=60
  stage_clear_animation
  echo
  printf "%s\n%s\n\n" "$(color "$YELLOW" "상세 설명:")" "$STAGE_EXPLAIN"
  printf "%s\n%s\n\n" "$(color "$YELLOW" "실무에서 왜 쓰는가:")" "$STAGE_WHY"
  printf "%s\n%s\n\n" "$(color "$YELLOW" "짧은 Incident Report:")" "$STAGE_REPORT"
  print_info "획득 점수: $score / 100"
  record_score "$STAGE_ID" "$score"
  write_incident_report "$STAGE_ID" "$score"
  pause
}

run_stage() {
  n="$1"
  if ! load_stage_file "$n"; then print_error "스테이지 $n 파일을 찾을 수 없습니다."; sleep 1; return; fi
  score=100; wrong=0; revealed=0
  show_stage
  while true; do
    printf "%s" "$(color "$CYAN" "devops-game:${CURRENT_DIR#$ROOT_DIR/}$ ")"
    read -r input
    input="$(normalize_input "$input")"
    special="${input%%[[:space:]]*}"
    case "$input" in
      "") continue ;;
    esac
    case "$special" in
      quit|exit) return 2 ;;
      help) show_stage_help; continue ;;
      reset) score=100; wrong=0; revealed=0; seed_sandbox; show_stage; continue ;;
      hint) score=$((score - 5)); [ "$score" -lt 0 ] && score=0; print_warn "$STAGE_WRONG_HINT"; show_option_help; continue ;;
      answer)
        if [ "$wrong" -ge 3 ]; then revealed=1; print_info "$STAGE_ANSWER_DETAIL"; show_answer_candidates; show_option_help
        else print_warn "정답 공개는 오답 3회 이후 가능합니다. 현재 오답: $wrong"; fi
        continue ;;
    esac
    process_command "$input"; penalty=$?
    if [ "$penalty" = "30" ]; then score=$((score - 30)); [ "$score" -lt 0 ] && score=0; continue; fi
    if is_stage_correct "$input"; then finish_stage "$score" "$revealed"; return; fi
    wrong=$((wrong + 1)); score=$((score - 10)); [ "$score" -lt 0 ] && score=0
    print_warn "아직 해결 명령으로 보기 어렵습니다. $STAGE_WRONG_HINT"
    [ "$wrong" -ge 3 ] && print_info "answer를 입력하면 정답 예시와 명령 구조를 볼 수 있습니다."
  done
}

run_all_stages() {
  for i in $(seq 1 "$TOTAL_STAGES"); do
    run_stage "$i"
    status=$?
    [ "$status" -eq 2 ] && return
  done
  show_final_score
  show_all_reports
  pause
}

show_stage_group_score() {
  label="$1"; shift
  total=0; done_count=0; stage_count=0
  for i in "$@"; do
    stage_count=$((stage_count + 1))
    eval "s=\${STAGE_SCORE_$i:-}"
    if [ -n "$s" ]; then
      total=$((total + s)); done_count=$((done_count + 1))
    fi
  done
  [ "$done_count" -eq 0 ] && avg=0 || avg=$((total / done_count))
  echo
  hr
  print_info "$label 결과"
  print_info "총점: $total / $((done_count * 100))"
  print_info "완료 스테이지: $done_count / $stage_count"
  print_info "평균점수: $avg"
  print_info "등급: $(grade_for "$avg")"
  hr
}

run_stage_group() {
  label="$1"; shift
  for i in "$@"; do
    run_stage "$i"
    status=$?
    [ "$status" -eq 2 ] && return
  done
  show_stage_group_score "$label" "$@"
  pause
}

select_stage_menu() {
  clear_screen; logo
  for i in $(seq 1 "$TOTAL_STAGES"); do
    if load_stage_file "$i"; then
      eval "s=\${STAGE_SCORE_$i:-}"
      [ -n "$s" ] && suffix=" - best $s" || suffix=""
      printf "%2d) %s%s\n" "$i" "$STAGE_TITLE" "$suffix"
    fi
  done
  echo; printf "%s" "$(color "$CYAN" "스테이지 번호> ")"; read -r n
  case "$n" in ''|*[!0-9]*) print_warn "숫자를 입력하세요."; sleep 1 ;; *) [ "$n" -ge 1 ] && [ "$n" -le "$TOTAL_STAGES" ] && run_stage "$n" || sleep 1 ;; esac
}

show_category_menu() {
  clear_screen
  logo
  print_info "카테고리별 문제 풀기"
  echo
  for i in $(seq 1 "$(category_count)"); do
    name="$(category_name "$i")"
    stages="$(category_stages "$i")"
    count="$(set -- $stages; echo "$#")"
    printf "%d) %s (%s문제)\n" "$i" "$name" "$count"
  done
  echo "0) 메인 메뉴"
}

select_category_menu() {
  while true; do
    show_category_menu
    echo
    printf "%s" "$(color "$CYAN" "카테고리 번호> ")"
    read -r n
    case "$n" in
      0|q|quit|exit) return ;;
      ''|*[!0-9]*) print_warn "숫자를 입력하세요."; sleep 1 ;;
      *)
        if [ "$n" -ge 1 ] && [ "$n" -le "$(category_count)" ]; then
          name="$(category_name "$n")"
          stages="$(category_stages "$n")"
          # shellcheck disable=SC2086
          run_stage_group "$name" $stages
        else
          print_warn "카테고리 번호를 확인하세요."
          sleep 1
        fi
        ;;
    esac
  done
}

show_all_reports() {
  clear_screen; logo
  print_info "전체 Incident Report"
  if ls "$REPORT_DIR"/*.md >/dev/null 2>&1; then
    for f in "$REPORT_DIR"/*.md; do hr; sed -n '1,12p' "$f"; done
  else
    print_warn "아직 저장된 리포트가 없습니다."
  fi
}
