@echo off
cd /d F:\ops-notes
git add .
git diff --cached --quiet
if %errorlevel% equ 0 exit /b 0
git commit -m "sync %date:/=-% %time%"
git push origin main