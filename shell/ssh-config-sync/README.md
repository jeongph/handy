# ssh-config-sync.sh

## 사용 방법

1. 이 Repository 가져오기
``` sh
git clone https://github.com/jeongph/handy.git && cd handy
```

2. (선택) config.local 파일 생성
``` sh
# 직접 생성하거나, 예시를 사용
cp shell/ssh-config-sync/config.local.example shell/ssh-config-sync/config.local # 그 다음 본인 환경에 맞게 수정
```

3. 스크립트 실행
``` sh
./shell/ssh-config-sync/ssh-config-sync.sh
```

4. 완료 후 생성 파일 확인
``` sh
vim ~/.ssh/config
```

## 기능 설명

1. 기존 ssh config (`~/.ssh/config`) 파일 백업 to `config.bak.timestamp`
2. config.common 과 (있다면) config.local 파일을 병합하여 config 파일 생성
3. 권한 정리
