# 기존 프로젝트를 빈 원격 저장소에 올리기

``` sh
read -p "Enter remote repository URL: " URL
git init
git add --all
git commit -m "init: initialize"
git branch -M main
git remote add origin "$URL"
git push -u origin main
```
