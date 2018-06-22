rmdir /S /Q bin
mkdir bin
..\7z.exe a bin\game.zip -x!*.bat -x!bin
mkdir .\bin\windows
copy ..\Love2d\* .\bin\windows
copy /b .\bin\windows\love.exe+\bin\game.love .\bin\windows\love.exe