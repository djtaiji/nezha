#Get server and key
param($server, $key)
# Download latest release from github
$repo = "naiba/nezha"
#  x86 or x64
if ([System.Environment]::Is64BitOperatingSystem) {
    $file = "nezha-agent_windows_amd64.zip"
}
else {
    $file = "nezha-agent_windows_386.zip"
}
$releases = "https://api.github.com/repos/$repo/releases"
Write-Host "Determining latest nezha release" -BackgroundColor DarkGreen -ForegroundColor White
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tag = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name
$download = "https://github.com/$repo/releases/download/$tag/$file"
Invoke-WebRequest $download -OutFile "C:\nezha.zip"
#使用nssm安装服务
Invoke-WebRequest "http://nssm.cc/release/nssm-2.24.zip" -OutFile "C:\nssm.zip"
#解压
Expand-Archive "C:\nezha.zip" -DestinationPath "C:\temp" -Force
Expand-Archive "C:\nssm.zip" -DestinationPath "C:\temp" -Force
if (!(Test-Path "C:\nezha")) { New-Item -Path "C:\nezha" -type directory }
#整理文件
Move-Item -Path "C:\temp\nezha-agent.exe" -Destination "C:\nezha\nezha.exe"
if ($file = "nezha-agent_windows_amd64.zip") {
    Move-Item -Path "C:\temp\nssm-2.24\win64\nssm.exe" -Destination "C:\nezha\nssm.exe"
}
else {
    Move-Item -Path "C:\temp\nssm-2.24\win32\nssm.exe" -Destination "C:\nezha\nssm.exe"
}
#清理垃圾
Remove-Item "C:\nezha.zip"
Remove-Item "C:\nssm.zip"
Remove-Item "C:\temp" -Recurse
#安装部分
C:\nezha\nssm.exe install nezha C:\nezha\nezha.exe -s $server -p $key -d 
C:\nezha\nssm.exe start nezha
#enjoy
Write-Host "Enjoy It!" -BackgroundColor DarkGreen -ForegroundColor Red