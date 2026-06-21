@echo off
echo 1. Компиляция Flutter Web...
call flutter build web --release --base-href "/nuvit/" --no-tree-shake-icons

echo 2. Переход в папку сборки...
cd build\web

echo 3. Инициализация Git и отправка...
git init
git add .
git commit -m "auto deploy"
git remote add origin https://github.com/nuvitsupport-cyber/nuvit.git
git push -f origin master:gh-pages

echo 4. Возврат в корень проекта...
cd ..\..
echo Готово! Сайт отправлен на сборку в GitHub.