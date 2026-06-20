> 기존 프로젝트를 비어있는 Repository 에 밀어넣기

``` sh
read -p "Enter remote repository URL: " URL
git init
git add --all
git commit -m "init: initialize"
git branch -M main
git remote add origin "$URL"
git push -u origin main
```
