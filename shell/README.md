### 외부 스크립트 파일 실행 

```sh
wget -O - <external_link> | bash
# e.g. wget -O - https://raw.githubusercontent.com/jeongph/handy/main/shell/hello.sh | bash
```

### 외부 스크립트 파일 저장

```sh
wget -O <file_name> <external_link> | bash
# e.g. wget -O hello.sh https://raw.githubusercontent.com/jeongph/handy/main/shell/hello.sh | bash
```
