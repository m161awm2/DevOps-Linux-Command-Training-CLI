#!/usr/bin/env bash

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'
MAGENTA=$'\033[35m'; CYAN=$'\033[36m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'

color() { printf "%s%s%s" "$1" "$2" "$RESET"; }
clear_screen() { printf "\033c"; }
print_ok() { printf "%s\n" "$(color "$GREEN" "[OK] $*")"; }
print_warn() { printf "%s\n" "$(color "$YELLOW" "[WARN] $*")"; }
print_error() { printf "%s\n" "$(color "$RED" "[ERROR] $*")"; }
print_info() { printf "%s\n" "$(color "$CYAN" "$*")"; }
hr() { printf "%s\n" "$(color "$DIM" "------------------------------------------------------------")"; }
pause() { echo; printf "%s" "$(color "$DIM" "Enter를 누르면 계속합니다...")"; read -r _; }

logo() {
  color "$GREEN" " ____              ___                 ____                  "
  echo
  color "$GREEN" "|  _ \  _____   __/ _ \ _ __  ___     / ___| __ _ _ __ ___   ___"
  echo
  color "$GREEN" "| | | |/ _ \ \ / / | | | '_ \/ __|   | |  _ / _\` | '_ \` _ \ / _ \\"
  echo
  color "$GREEN" "| |_| |  __/\ V /| |_| | |_) \__ \   | |_| | (_| | | | | | |  __/"
  echo
  color "$GREEN" "|____/ \___| \_/  \___/| .__/|___/    \____|\__,_|_| |_| |_|\___|"
  echo
  color "$GREEN" "                       |_|"
  echo
}

stage_clear_animation() {
  echo
  for word in "STAGE" "CLEAR" "✓"; do
    printf "%s " "$(color "$GREEN$BOLD" "$word")"
    sleep 0.12
  done
  echo
}

show_help() {
  clear_screen
  logo
  cat <<'EOF'
게임 안에서 사용할 수 있는 특수 명령어
- help   : 현재 스테이지 도움말 다시 보기
- hint   : 추가 힌트 보기, -5점
- answer : 3회 이상 오답 후 정답 예시 보기
- reset  : 현재 스테이지를 처음부터 다시 보기
- quit   : 메인 메뉴로 돌아가기

입력한 명령어는 실제 서버가 아니라 sandbox/ 안의 로컬 시뮬레이션으로 처리됩니다.
ssh, scp, docker, kubectl, aws, systemctl 같은 명령어는 실제 실행하지 않고 가짜 운영 출력만 보여줍니다.
EOF
}

show_command_examples() {
  clear_screen
  logo
  cat <<'EOF'
Linux 기본
pwd    - 현재 위치 확인                 예시: pwd
ls     - 파일 목록 확인                 예시: ls 폴더명
cd     - 디렉토리 이동                  예시: cd 폴더명
cat    - 파일 내용 출력                 예시: cat 파일명
touch  - 빈 파일 생성                   예시: touch 파일명
mkdir  - 디렉토리 생성                  예시: mkdir 폴더명
cp     - 파일 복사                      예시: cp 원본 대상
mv     - 파일 이동/이름 변경             예시: mv 원본 대상
rm     - 파일 삭제                      예시: rm 파일명
echo   - 문자열 출력                    예시: echo 문자열
clear  - 화면 정리                      예시: clear
whoami - 현재 사용자 확인               예시: whoami
uname  - OS 정보 확인                   예시: uname 옵션
date   - 현재 시간 확인                 예시: date

로그/검색/운영
grep   - 특정 문자열 검색               예시: grep 검색어 파일명
find   - 파일 검색                      예시: find 시작경로 조건 패턴
tail   - 로그 마지막 부분 확인           예시: tail 옵션 파일명
head   - 파일 앞부분 확인               예시: head 옵션 파일명
less   - 파일 페이지 단위 확인           예시: less 파일명
chmod  - 파일 권한 변경                 예시: chmod 권한 파일명
chown  - 소유자 변경                    예시: chown 사용자 파일명
ps     - 프로세스 확인                  예시: ps 옵션
kill   - 프로세스 종료                  예시: kill PID
ss     - 포트 확인                      예시: ss 옵션
lsof   - 포트/파일 점유 확인             예시: lsof 옵션 포트
netstat- 네트워크 상태 확인              예시: netstat 옵션
curl   - HTTP 응답 확인                 예시: curl 옵션 URL

서비스/배포
env       - 환경변수 확인               예시: env
export    - 환경변수 설정               예시: export 변수명=값
pm2       - Node 프로세스 관리           예시: pm2 명령 앱이름
systemctl - 서비스 상태/재시작           예시: systemctl 명령 서비스명
journalctl- systemd 로그 확인           예시: journalctl 옵션 서비스명
nginx     - 설정 검사                   예시: nginx 옵션
tar/gzip  - 압축/묶기                   예시: tar 옵션 압축파일 대상
crontab   - 예약 작업 확인/편집          예시: crontab 옵션
ssh       - 원격 서버 접속               예시: ssh 사용자@호스트
scp       - 원격 파일 복사               예시: scp 원본 사용자@호스트:대상

Docker/Kubernetes/AWS
docker ps              - 컨테이너 목록       예시: docker ps 옵션
docker logs            - 컨테이너 로그       예시: docker logs 컨테이너명
docker exec            - 컨테이너 내부 실행   예시: docker exec 컨테이너명 명령
docker inspect         - 상세 정보 확인      예시: docker inspect 컨테이너명
docker compose logs    - compose 로그        예시: docker compose logs 서비스명
docker compose up -d   - compose 실행        예시: docker compose up 옵션
kubectl get pods       - 파드 목록           예시: kubectl get 리소스
kubectl describe pod   - 파드 이벤트         예시: kubectl describe 리소스 이름
kubectl logs           - 파드 로그           예시: kubectl logs 파드명
kubectl rollout status - 배포 상태           예시: kubectl rollout status 대상
kubectl rollout undo   - 배포 롤백           예시: kubectl rollout undo 대상
dig/nslookup           - DNS 확인            예시: dig 호스트명
ip a/ip route          - 네트워크/라우팅      예시: ip 명령
aws s3 ls              - S3 버킷 확인        예시: aws s3 작업
aws ec2 describe-instances - EC2 조회        예시: aws ec2 작업
EOF
}
