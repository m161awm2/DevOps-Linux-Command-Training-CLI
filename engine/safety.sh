#!/usr/bin/env bash

is_dangerous_command() {
  line="$1"
  case "$line" in
    *"rm -rf /"*|*"sudo rm"*|*"mkfs"*|*"dd if="*|*"dd of="*|*"shutdown"*|*"reboot"*|*"kill -9 1"*|*"chmod -R 777 /"*|*"chown -R /"*|*":(){ :|:& };:"*|*":(){:"*|*"|:&"* )
      return 0 ;;
  esac
  return 1
}

is_allowed_command() {
  first="$1"; second="${2:-}"
  case "$first" in
    pwd|ls|cd|cat|touch|mkdir|cp|mv|rm|echo|clear|whoami|uname|date|grep|find|tail|head|less|chmod|chown|ps|kill|ss|lsof|netstat|curl|env|export|df|du|tar|gzip|crontab|ssh|scp|aws|kubectl|docker|docker-compose|git|systemctl|journalctl|pm2|nginx|iptables|dig|nslookup|traceroute|ip)
      return 0 ;;
  esac
  return 1
}

safe_rel_path() {
  p="$1"
  case "$p" in
    ""|/*|*..*|*~*) return 1 ;;
  esac
  return 0
}
