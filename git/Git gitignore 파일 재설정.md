> `.gitignore` 파일 변경시에 로컬 캐시 비우고 파일에 ignore 재적용, 변경사항 푸시

```sh
git rm --cached -r .
git add .
git commit -m "gitignore 재설정"
#git push
```
