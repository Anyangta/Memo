$OutputEncoding = [System.Text.Encoding]::UTF8
$script:ErrorActionPreference = "Stop" # (추가: 오류 발생 시 스크립트 즉시 중단)

# --- 설정 변수 ---
$SourceDir = "NonRead"       # 커밋할 파일들이 들어있는 임시 폴더 이름
$GitBranch = "main"                  # 사용하는 Git 브랜치 이름 (master 대신 main 사용 권장)

# --- 1. 오늘 날짜 포맷팅 (YYYYMMDD) ---
# PowerShell에서 오늘 날짜를 YYYYMMDD 형식으로 가져옵니다.
$Today = (Get-Date).ToString("yyyyMMdd")
# YYYY/MM/DD 형식의 날짜 (커밋 메시지에 사용)
$DateFormatted = (Get-Date).ToString("yyyy/MM/dd") 

Write-Host "--- [Git Daily Archiver for Windows] ---"
Write-Host "오늘 날짜 폴더: $Today"

# --- 2. 날짜 폴더 생성 ---
if (-not (Test-Path -Path $Today -PathType Container)) {
    New-Item -Path $Today -ItemType Directory | Out-Null
    Write-Host "✅ 날짜 디렉토리 ($Today) 생성 완료."
}

# --- 3. 임시 폴더 확인 및 파일 이동 ---
if (-not (Test-Path -Path $SourceDir -PathType Container)) {
    Write-Host "❌ 에러: 임시 파일 폴더 ($SourceDir)가 존재하지 않습니다." -ForegroundColor Red
    Write-Host "커밋할 파일들을 먼저 이 폴더에 넣어주세요." -ForegroundColor Red
    exit 1
}

# 임시 폴더가 비어있는지 확인
$FilesToMove = Get-ChildItem -Path $SourceDir -Force
if ($FilesToMove.Count -eq 0) {
    Write-Host "⚠️ 경고: 임시 폴더 ($SourceDir)에 파일이 없습니다. 작업을 건너뜜." -ForegroundColor Yellow
    exit 0
}

Write-Host "➡️ 파일 이동 시작..."
# 임시 폴더의 모든 파일을 날짜 폴더로 이동
Move-Item -Path "$SourceDir\*" -Destination $Today -Force
Write-Host "✅ 파일 이동 완료."


# --- 4. Git 작업 수행 ---
Write-Host "➡️ Git 작업 시작 (Add, Commit, Push)..."

# 모든 변경 사항 추가 (새로 생성된 폴더와 파일 포함)
git add .

# 커밋 메시지 설정
$CommitMessage = "Archive: $DateFormatted Daily Log"

# 커밋 수행
git commit -m $CommitMessage

# 원격 저장소에 푸시 (실패 방지를 위해 별도의 명령어 사용)
git push origin $GitBranch

Write-Host "--- [작업 완료] ---" -ForegroundColor Green
Write-Host "커밋 메시지: '$CommitMessage'" -ForegroundColor Green
Write-Host "파일들이 $Today 폴더에 보관되었습니다." -ForegroundColor Green