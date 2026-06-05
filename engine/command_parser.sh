#!/usr/bin/env bash

CURRENT_DIR=""

seed_sandbox() {
  CURRENT_DIR="$SANDBOX_DIR"
  mkdir -p "$SANDBOX_DIR"/{logs,app,config,backup,remote,docker,k8s,aws}
  printf "INFO boot ok\nWARN cache slow\nERROR database timeout\nINFO retry success\n" > "$SANDBOX_DIR/logs/app.log"
  printf "2026-06-05 09:01:00 ERROR upstream connect failed\n2026-06-05 09:02:00 INFO health ok\n" > "$SANDBOX_DIR/logs/nginx_error.log"
  printf "DATABASE_URL=\nPORT=3000\n" > "$SANDBOX_DIR/config/app.env"
  printf "#!/usr/bin/env bash\necho deploy\n" > "$SANDBOX_DIR/app/deploy.sh"
  printf "server_name example.local;\nproxy_pass http://127.0.0.1:3000;\n" > "$SANDBOX_DIR/config/nginx.conf"
  printf "artifact version 2\n" > "$SANDBOX_DIR/remote/deploy.tar.gz"
}

simulated_command() {
  line="$1"
  case "$line" in
    ssh*)
      echo "[SIMULATION] Connected to ec2-user@10.0.1.10"; echo "remote>"; return 0 ;;
    scp*)
      echo "[SIMULATION] deploy.tar.gz copied to ec2-user@10.0.1.10:/home/ec2-user/"; return 0 ;;
    aws\ s3\ ls*)
      echo "2026-06-05  devops-game-bucket"; echo "2026-06-05  log-backup-bucket"; return 0 ;;
    aws\ ec2\ describe-instances*)
      echo "InstanceId: i-0devops123  State: running  IAM: ReadOnlyRole  Region: ap-northeast-2"; return 0 ;;
    kubectl\ get\ pods*)
      echo "NAME        READY   STATUS             RESTARTS"; echo "api-7f9d    0/1     CrashLoopBackOff   5"; echo "web-6aa1    1/1     Running            0"; return 0 ;;
    kubectl\ describe\ pod*)
      echo "Events:"; echo "  Back-off restarting failed container api"; echo "  Error: missing DATABASE_URL"; return 0 ;;
    kubectl\ logs*)
      echo "ERROR failed to start: DATABASE_URL is empty"; return 0 ;;
    kubectl\ get\ svc*)
      echo "NAME   TYPE        CLUSTER-IP    PORT(S)"; echo "api    ClusterIP   10.96.1.20   80/TCP"; return 0 ;;
    kubectl\ get\ ingress*)
      echo "NAME   CLASS   HOSTS              ADDRESS"; echo "api    nginx   api.example.local  10.0.1.50"; return 0 ;;
    kubectl\ rollout\ status*)
      echo "deployment \"api\" successfully rolled out"; return 0 ;;
    kubectl\ rollout\ undo*)
      echo "deployment.apps/api rolled back"; return 0 ;;
    docker\ ps*)
      echo "CONTAINER ID   IMAGE      STATUS                    NAMES"; echo "a1b2c3d4       api:v2     Restarting (1) 10s ago    app-container"; return 0 ;;
    docker\ logs*)
      echo "ERROR: DATABASE_URL missing"; echo "container exited with code 1"; return 0 ;;
    docker\ exec*)
      echo "[SIMULATION] opened shell in app-container"; echo "DATABASE_URL="; return 0 ;;
    docker\ inspect*)
      echo '"HostConfig": {"PortBindings": {"3000/tcp": [{"HostPort": "8080"}]}}'; return 0 ;;
    docker\ compose\ logs*)
      echo "api  | ERROR cannot connect to redis:6379"; return 0 ;;
    docker\ compose\ up*)
      echo "[SIMULATION] compose services started in detached mode"; return 0 ;;
    systemctl*)
      echo "nginx.service - failed (Result: exit-code)"; echo "Hint: run journalctl -u nginx -n 50"; return 0 ;;
    journalctl*)
      echo "nginx[123]: invalid number of arguments in proxy_pass"; return 0 ;;
    pm2*)
      echo "App name: api  id:0  status: stopped"; return 0 ;;
    nginx\ -t*)
      echo "nginx: [emerg] invalid number of arguments in \"proxy_pass\""; echo "nginx: configuration file test failed"; return 0 ;;
    iptables*)
      echo "[SIMULATION] firewall rule list is empty"; return 0 ;;
    git\ status*)
      echo "On branch release/v2"; echo "Your branch is behind 'origin/release/v2' by 2 commits."; return 0 ;;
    git\ branch*)
      echo "  main"; echo "* release/v2"; return 0 ;;
    git\ log*)
      echo "abc1234 hotfix: recover api"; echo "def5678 deploy: v2"; return 0 ;;
    docker-compose\ logs*)
      echo "api  | ERROR cannot connect to redis:6379"; return 0 ;;
  esac
  return 1
}

is_path_like_arg() {
  case "$1" in
    ""|-*) return 1 ;;
    *) return 0 ;;
  esac
}

require_file_operand() {
  cmd="$1"; shift || true
  case "$cmd" in
    cat|less)
      for a in "$@"; do
        if is_path_like_arg "$a"; then return 0; fi
      done
      print_error "$cmd 명령에는 파일명이 필요합니다."
      return 1
      ;;
    head|tail)
      need_option_arg=0
      for a in "$@"; do
        if [ "$need_option_arg" -eq 1 ]; then need_option_arg=0; continue; fi
        case "$a" in
          -n|-c|-b) need_option_arg=1 ;;
          -*) ;;
          *) return 0 ;;
        esac
      done
      if [ "$need_option_arg" -eq 1 ]; then
        print_error "$cmd 옵션에 필요한 값이 없습니다."
      else
        print_error "$cmd 명령에는 파일명이 필요합니다."
      fi
      return 1
      ;;
    grep)
      positional=0
      need_option_arg=0
      for a in "$@"; do
        if [ "$need_option_arg" -eq 1 ]; then need_option_arg=0; continue; fi
        case "$a" in
          -e|-f|-m|-A|-B|-C) need_option_arg=1 ;;
          -*) ;;
          *) positional=$((positional + 1)) ;;
        esac
      done
      if [ "$need_option_arg" -eq 1 ]; then
        print_error "grep 옵션에 필요한 값이 없습니다."
        return 1
      fi
      if [ "$positional" -lt 2 ]; then
        print_error "grep 명령에는 검색어와 파일명이 필요합니다."
        return 1
      fi
      ;;
  esac
  return 0
}

run_tail_command() {
  follow=0
  preview_args=()
  for a in "$@"; do
    case "$a" in
      -f|-F) follow=1 ;;
      *) preview_args+=("$a") ;;
    esac
  done
  if [ "$follow" -eq 1 ]; then
    command tail -n 10 "${preview_args[@]}"
    echo "[SIMULATION] tail follow mode stopped after initial log preview."
  else
    command tail "$@"
  fi
}

run_local_command() {
  line="$1"
  set -- $line
  cmd="$1"; shift || true
  case "$cmd" in
    clear) clear_screen ;;
    pwd) printf "%s\n" "${CURRENT_DIR#$ROOT_DIR/}" ;;
    cd)
      target="${1:-$SANDBOX_DIR}"
      [ "$target" = "." ] && return 0
      if [ "$target" = ".." ]; then new="$(dirname "$CURRENT_DIR")"; else new="$CURRENT_DIR/$target"; fi
      if [ -d "$new" ] && case "$new" in "$SANDBOX_DIR"*) true;; *) false;; esac; then CURRENT_DIR="$(cd "$new" && pwd)"; else print_error "sandbox 밖으로 이동할 수 없거나 디렉토리가 없습니다."; fi ;;
    ls) (cd "$CURRENT_DIR" && command ls "$@") ;;
    less)
      require_file_operand less "$@" || return 1
      for a in "$@"; do case "$a" in /*|*..*|~*) print_error "sandbox 내부 상대경로만 조회할 수 있습니다."; return 1;; esac; done
      (cd "$CURRENT_DIR" && command sed -n '1,20p' "$1") 2>&1 | sed 's#'"$SANDBOX_DIR"'#sandbox#g' ;;
    cat|head|tail|grep|find|du|df)
      require_file_operand "$cmd" "$@" || return 1
      for a in "$@"; do
        case "$a" in
          -*|"."|"*"*|ERROR|error|database|timeout|DATABASE_URL) ;;
          /*|*..*|~*) print_error "sandbox 내부 상대경로만 조회할 수 있습니다."; return 1 ;;
        esac
      done
      if [ "$cmd" = "tail" ]; then
        (cd "$CURRENT_DIR" && run_tail_command "$@") 2>&1 | sed 's#'"$SANDBOX_DIR"'#sandbox#g'
      else
        (cd "$CURRENT_DIR" && command "$cmd" "$@") 2>&1 | sed 's#'"$SANDBOX_DIR"'#sandbox#g'
      fi ;;
    whoami|uname|date|env)
      command "$cmd" "$@" 2>&1 ;;
    touch|mkdir|cp|mv|rm|chmod)
      for a in "$@"; do case "$a" in -*|"") ;; *) safe_rel_path "$a" || { print_error "sandbox 내부 상대경로만 허용합니다."; return 1; };; esac; done
      (cd "$CURRENT_DIR" && command "$cmd" "$@") 2>&1 ;;
    echo) echo "$*" ;;
    ps) echo "admin  4242  node server.js"; echo "admin  4300  nginx: worker process" ;;
    kill) echo "[SIMULATION] process ${1:-PID} terminated" ;;
    ss|lsof|netstat) echo "LISTEN 0 128 127.0.0.1:3000 users:(node,pid=4242)" ;;
    curl) echo "HTTP/1.1 502 Bad Gateway"; echo "x-devops-game: simulated" ;;
    export) echo "[SIMULATION] exported ${1:-VARIABLE=value}" ;;
    tar) echo "[SIMULATION] archive created: backup.tar.gz" ;;
    gzip) echo "[SIMULATION] gzip completed" ;;
    crontab) echo "0 2 * * * /srv/app/backup.sh # disabled: wrong path" ;;
    dig|nslookup) echo "api.example.local. 60 IN A 10.0.1.50" ;;
    traceroute) echo "1  10.0.0.1  1ms"; echo "2  10.0.1.50  3ms" ;;
    ip) [ "${1:-}" = "route" ] && echo "default via 10.0.0.1 dev en0" || echo "en0: inet 10.0.1.25/24" ;;
    *) print_warn "허용은 되었지만 이 게임에서는 요약 출력만 제공합니다." ;;
  esac
}

process_command() {
  line="$1"
  if is_dangerous_command "$line"; then
    print_error "위험 명령어 차단: 실제 실행하지 않습니다. 점수 -30"
    return 30
  fi
  set -- $line
  first="${1:-}"; second="${2:-}"
  if ! is_allowed_command "$first" "$second"; then
    print_warn "허용되지 않은 명령어입니다. help 또는 command examples를 참고하세요."
    return 2
  fi
  if simulated_command "$line"; then return 0; fi
  run_local_command "$line"
  return 0
}
