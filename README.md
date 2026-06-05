# devops-linux-command-game

Bash 기반 DevOps Linux Command Training CLI 게임입니다.

## 실행 방법

```bash
cd devops-linux-command-game
chmod +x game.sh
./game.sh
```

macOS와 Linux에서 Bash로 실행됩니다. 

## 게임 규칙

- 총 30개 스테이지입니다.
- 전체 순서대로 풀거나, 카테고리별로 묶어서 풀 수 있습니다.
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

## 카테고리별 문제 풀기

메인 메뉴의 `카테고리별 문제 풀기`에서 원하는 범주만 골라 순서대로 풀 수 있습니다.

| 카테고리 | 포함 스테이지 |
| --- | --- |
| Linux 기본/파일 | 1-4 |
| 로그 검색/추적 | 5-7 |
| 운영 점검/서비스 | 8-18 |
| 원격 접속/Git 배포 | 19-21 |
| Docker | 22-25 |
| Kubernetes | 26-28 |
| 네트워크/AWS | 29-30 |

## 명령어 학습표

| 영역 | 명령어 | 설명 | 예시 |
| --- | --- | --- | --- |
| 기본 | `pwd` | 현재 위치 확인 | `pwd` |
| 기본 | `ls` | 파일 목록 확인 | `ls -al` |
| 기본 | `cd` | 디렉토리 이동 | `cd logs` |
| 기본 | `cat` | 파일 내용 출력 | `cat config/app.env` |
| 기본 | `touch` | 빈 파일 생성 | `touch app/healthcheck.txt` |
| 기본 | `mkdir` | 디렉토리 생성 | `mkdir backup/today` |
| 기본 | `cp` | 파일 복사 | `cp app/deploy.sh backup/` |
| 기본 | `mv` | 이동/이름 변경 | `mv app.tmp app.conf` |
| 기본 | `rm` | 파일 삭제 | `rm app/debug.tmp` |
| 로그 | `grep` | 문자열 검색 | `grep ERROR logs/app.log` |
| 로그 | `find` | 파일 검색 | `find . -name "*.log"` |
| 로그 | `tail` | 로그 끝부분 확인 | `tail -n 50 logs/app.log` |
| 로그 | `tail -f` | 실시간 로그 추적 | `tail -f /var/log/nginx/error.log` |
| 권한 | `chmod` | 권한 변경 | `chmod +x deploy.sh` |
| 프로세스 | `ps` | 프로세스 확인 | `ps aux \| grep node` |
| 프로세스 | `kill` | 프로세스 종료 | `kill 1234` |
| 네트워크 | `ss` | 리슨 포트 확인 | `ss -ltnp` |
| 네트워크 | `lsof` | 포트 점유 확인 | `lsof -i :3000` |
| HTTP | `curl` | HTTP 응답 확인 | `curl -I http://localhost:3000` |
| 서비스 | `systemctl` | 서비스 상태/재시작 | `systemctl status nginx` |
| 서비스 | `journalctl` | systemd 로그 | `journalctl -u nginx -n 50` |
| 서비스 | `nginx -t` | Nginx 설정 검사 | `nginx -t` |
| 운영 | `df -h` | 디스크 사용량 | `df -h` |
| 운영 | `du -sh` | 디렉토리 용량 | `du -sh logs` |
| 운영 | `tar` | 묶고 압축 | `tar -czvf backup.tar.gz ./app` |
| 운영 | `crontab` | 예약 작업 | `crontab -l` |
| 원격 | `ssh` | 원격 접속 | `ssh -i ~/.ssh/devops-key.pem ec2-user@10.0.1.10` |
| 원격 | `scp` | 원격 복사 | `scp -i ~/.ssh/devops-key.pem app.tar.gz ec2-user@10.0.1.10:/home/ec2-user/` |
| Docker | `docker ps` | 컨테이너 목록 | `docker ps -a` |
| Docker | `docker logs` | 컨테이너 로그 | `docker logs app-container` |
| Docker | `docker exec` | 컨테이너 내부 실행 | `docker exec -it app-container sh` |
| Docker | `docker compose` | compose 서비스 관리 | `docker compose logs api` |
| Kubernetes | `kubectl get pods` | 파드 목록 | `kubectl get pods -n default` |
| Kubernetes | `kubectl describe pod` | 파드 이벤트 | `kubectl describe pod api-pod -n default` |
| Kubernetes | `kubectl logs` | 파드 로그 | `kubectl logs api-pod -n default` |
| Kubernetes | `kubectl rollout undo` | 배포 롤백 | `kubectl rollout undo deployment/api -n default` |
| 네트워크 | `dig` | DNS 확인 | `dig example.com` |
| 네트워크 | `ip route` | 라우팅 확인 | `ip route` |
| AWS | `aws s3 ls` | S3 버킷 확인 | `aws s3 ls` |
| AWS | `aws ec2 describe-instances` | EC2 조회 | `aws ec2 describe-instances --region ap-northeast-2` |

## 안전 설계

사용자 입력 전체를 `eval`로 실행하지 않습니다. `engine/command_parser.sh`가 첫 명령어를 허용 목록으로 제한하고, 위험 패턴은 `engine/safety.sh`에ƒ서 차단합니다.

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
