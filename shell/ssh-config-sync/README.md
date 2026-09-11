# ssh-config-sync.sh

## 사용 방법

1. 이 저장소 내려받기
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

1. 기존 SSH 설정 파일(`~/.ssh/config`)을 `config.bak.timestamp`로 백업한다
2. `config.common`과 `config.local`(있는 경우)을 병합해 설정 파일을 생성한다
3. 생성한 파일의 권한을 설정한다
