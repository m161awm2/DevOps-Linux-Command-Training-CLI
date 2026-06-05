# devops-linux-command-game

Bash 기반 DevOps Linux Command Training CLI 게임입니다. 단순 퀴즈가 아니라 장애 상황을 읽고, 실제 운영자가 입력할 법한 명령어를 통해 원인을 조사하고 복구 절차를 학습하도록 만들었습니다.

## 실행 방법

```bash
cd devops-linux-command-game
chmod +x game.sh
./game.sh
```

macOS와 Linux에서 Bash로 실행됩니다. 외부 서버, Docker, Kubernetes, AWS는 필요하지 않습니다. 모든 출력은 `sandbox/` 안의 로컬 파일과 시뮬레이션으로 처리됩니다.

## 게임 규칙

- 총 30개 스테이지입니다.
- 각 스테이지 기본 점수는 100점입니다.
- 오답은 -10점입니다.
- `hint` 사용은 -5점입니다.
- 위험 명령어 입력은 실제 실행하지 않고 -30점입니다.
- 오답 3회 이후 `answer`를 입력하면 정답 예시가 공개됩니다.
- 정답 공개 후 클리어하면 최대 60점입니다.
- 클리어 시 `incident_reports/`에 스테이지별 리포트가 저장됩니다.
- 진행 상황과 최고 점수는 `.progress`에 저장됩니다.

등급 기준:

- S: 90점 이상
- A: 80점 이상
- B: 70점 이상
- C: 60점 이상
- F: 60점 미만

## 게임 내 특수 명령어

```text
help   현재 스테이지 도움말 다시 보기
hint   추가 힌트 보기
answer 3회 이상 오답 후 정답 예시 보기
reset  현재 스테이지 점수와 상태 초기화
quit   메인 메뉴로 돌아가기
```

## 스테이지 목록

1. 기본 위치 확인
2. 설정 파일 읽기
3. 배포 체크 파일 생성
4. 로그 파일 찾기
5. 기본 로그 확인
6. ERROR 검색
7. 실시간 로그 추적
8. 실행 권한 문제
9. 프로세스 확인
10. 포트 리슨 확인
11. 환경변수 누락
12. PM2 프로세스 중지
13. systemd 서비스 실패
14. Nginx 502
15. DB 연결 장애
16. 디스크 Full
17. 백업 압축
18. Crontab 백업 실패
19. SSH 원격 접속
20. SCP 배포 파일 전송
21. Git 배포 실패 조사
22. Docker 컨테이너 로그
23. Docker 내부 환경 확인
24. Docker Compose 서비스 장애
25. Docker 포트/볼륨 확인
26. Kubernetes CrashLoopBackOff
27. Kubernetes ImagePull 장애
28. Service/Ingress 확인
29. DNS/네트워크 확인
30. AWS S3/EC2 권한 확인

## 명령어 학습표

| 영역 | 명령어 | 설명 | 예시 |
| --- | --- | --- | --- |
| 기본 | `pwd` | 현재 위치 확인 | 명령어만 단독 입력 |
| 기본 | `ls` | 파일 목록 확인 | `ls 폴더명` |
| 기본 | `cd` | 디렉토리 이동 | `cd 폴더명` |
| 기본 | `cat` | 파일 내용 출력 | `cat 파일명` |
| 기본 | `touch` | 빈 파일 생성 | `touch 파일명` |
| 기본 | `mkdir` | 디렉토리 생성 | `mkdir 폴더명` |
| 기본 | `cp` | 파일 복사 | `cp 원본 대상` |
| 기본 | `mv` | 이동/이름 변경 | `mv 원본 대상` |
| 기본 | `rm` | 파일 삭제 | `rm 파일명` |
| 로그 | `grep` | 문자열 검색 | `grep 검색어 파일명` |
| 로그 | `find` | 파일 검색 | `find 시작경로 조건 패턴` |
| 로그 | `tail` | 로그 끝부분 확인 | `tail 옵션 파일명` |
| 로그 | `tail -f` | 실시간 로그 추적 | `tail 옵션 파일명` |
| 권한 | `chmod` | 권한 변경 | `chmod 권한 파일명` |
| 프로세스 | `ps` | 프로세스 확인 | `ps 옵션 \| grep 이름` |
| 프로세스 | `kill` | 프로세스 종료 | `kill 1234` |
| 네트워크 | `ss` | 리슨 포트 확인 | `ss 옵션` |
| 네트워크 | `lsof` | 포트 점유 확인 | `lsof 옵션 포트` |
| HTTP | `curl` | HTTP 응답 확인 | `curl 옵션 URL` |
| 서비스 | `systemctl` | 서비스 상태/재시작 | `systemctl 명령 서비스명` |
| 서비스 | `journalctl` | systemd 로그 | `journalctl 옵션 서비스명` |
| 서비스 | `nginx -t` | Nginx 설정 검사 | `nginx 옵션` |
| 운영 | `df -h` | 디스크 사용량 | `df 옵션` |
| 운영 | `du -sh` | 디렉토리 용량 | `du 옵션 경로` |
| 운영 | `tar` | 묶고 압축 | `tar 옵션 압축파일 대상` |
| 운영 | `crontab` | 예약 작업 | `crontab 옵션` |
| 원격 | `ssh` | 원격 접속 | `ssh 사용자@호스트` |
| 원격 | `scp` | 원격 복사 | `scp 원본 사용자@호스트:대상` |
| Docker | `docker ps` | 컨테이너 목록 | `docker ps 옵션` |
| Docker | `docker logs` | 컨테이너 로그 | `docker logs 컨테이너명` |
| Docker | `docker exec` | 컨테이너 내부 실행 | `docker exec 컨테이너명 명령` |
| Docker | `docker compose` | compose 서비스 관리 | `docker compose 명령 서비스명` |
| Kubernetes | `kubectl get pods` | 파드 목록 | `kubectl get 리소스` |
| Kubernetes | `kubectl describe pod` | 파드 이벤트 | `kubectl describe 리소스 이름` |
| Kubernetes | `kubectl logs` | 파드 로그 | `kubectl logs 파드명` |
| Kubernetes | `kubectl rollout undo` | 배포 롤백 | `kubectl rollout undo 대상` |
| 네트워크 | `dig` | DNS 확인 | `dig 호스트명` |
| 네트워크 | `ip route` | 라우팅 확인 | `ip 명령` |
| AWS | `aws s3 ls` | S3 버킷 확인 | `aws s3 작업` |
| AWS | `aws ec2 describe-instances` | EC2 조회 | `aws ec2 작업` |

## 안전 설계

사용자 입력 전체를 `eval`로 실행하지 않습니다. `engine/command_parser.sh`가 첫 명령어를 허용 목록으로 제한하고, 위험 패턴은 `engine/safety.sh`에서 차단합니다.

차단 예:

```text
rm -rf /
sudo rm
mkfs
dd
shutdown
reboot
kill -9 1
chmod -R 777 /
chown -R /
fork bomb 패턴
```

다음 명령어는 실제 실행하지 않고 시뮬레이션 출력만 제공합니다.

```text
ssh, scp, aws, kubectl, docker, docker compose, systemctl,
journalctl, pm2, nginx -t, iptables
```

## 확장 방법

1. `stages/stage31_new_topic.sh` 파일을 추가합니다.
2. `load_stage_31` 함수를 만들고 `set_stage`에 상황, 목표, 힌트, 예시, 설명, 정답 패턴을 넣습니다.
3. `engine/scoring.sh`의 `TOTAL_STAGES` 값을 늘립니다.
4. 실제 실행하면 안 되는 새 명령은 `engine/command_parser.sh`의 시뮬레이션 분기에 추가합니다.

## 포트폴리오 어필 포인트

- Bash만으로 구현한 CLI 게임 엔진
- 안전한 명령어 파서와 위험 명령어 차단
- Docker/Kubernetes/AWS 없이 로컬 시뮬레이션으로 DevOps 학습 가능
- 스테이지별 점수, 진행 저장, Incident Report 자동 생성
- 초급 Linux부터 클라우드 장애 대응까지 단계형 커리큘럼
# DevOps-Linux-Command-Training-CLI
