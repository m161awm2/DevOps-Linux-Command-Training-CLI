#!/usr/bin/env bash
load_stage_06(){ 
    set_stage 6 \
    "ERROR 검색" \
    "로그가 길어졌습니다. 에러 라인만 빠르게 추려야 합니다." \
    "logs/app.log에서 ERROR 문자열을 검색하세요." \
    "grep, cat" \
    "grep 검색어 파일명" \
    "grep은 파일에서 특정 패턴이 있는 줄만 출력합니다. -i로 대소문자 무시도 가능합니다." \
    "대량 로그에서 에러만 추리는 능력은 MTTR을 크게 줄입니다." \
    "ERROR 라인을 필터링해 database timeout 원인을 식별했다." \
    "검색할 단어와 파일명을 함께 입력하세요." \
    "grep 명령에 에러 키워드와 로그 파일 경로를 붙입니다." \
    '^grep[[:space:]]+["\']?ERROR["\']?[[:space:]]+logs/app\.log$' \
    '^grep[[:space:]]+-i[[:space:]]+["\']?error["\']?[[:space:]]+logs/app\.log$'; 
}
