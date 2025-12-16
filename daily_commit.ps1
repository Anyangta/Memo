$OutputEncoding = [System.Text.Encoding]::UTF8
$script:ErrorActionPreference = "Stop"

# --- 설정 변수 ---
$SourceDir = "NonRead"
$GitBranch = "main"

# --- 1. 오늘 날짜 포맷팅 (YYYYMMDD) ---
$Today = (Get-Date).ToString("yyyyMMdd")
$DateFormatted = (Get-Date).ToString("yyyy/MM/dd") 

Write-Host "--- [Git Daily Archiver for Windows] ---"
Write-Host "오늘 날짜 폴더: $Today"

# --- 2. 날짜 폴더 생성 ---
if (-not (Test-Path -Path $Today -PathType Container)) {
    New-Item -Path $Today -ItemType Directory | Out-Null
    Write-Host "✅ 날짜 디렉토리 ($Today) 생성 완료." -ForegroundColor Green
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
    Write-Host "⚠️ 경고: 임시 폴더 ($SourceDir)에 파일이 없습니다. 작업을 건너뜁니다." -ForegroundColor Yellow
    exit 0
}

Write-Host "➡️ 파일 이동 시작..." -ForegroundColor Cyan
# !!! 폴더 중복 방지 수정 적용: $Today 뒤에 백슬래시(\) 추가 !!!
Move-Item -Path "$SourceDir\*" -Destination "$Today\" -Force 
Write-Host "✅ 파일 이동 완료." -ForegroundColor Green


# --- 4. Git 작업 수행 ---
Write-Host "➡️ Git 작업 시작 (Add, Commit, Push)..." -ForegroundColor Cyan

git add .

# 사용자에게 키워드를 입력받습니다.
$UserInput = Read-Host "커밋 키워드를 입력하세요 (예: DB, CODE, DOC 등)"

# 사용자 입력이 있는지 확인
if ([string]::IsNullOrWhiteSpace($UserInput)) {
    # 입력이 없으면 기본 메시지 사용
    $CommitMessage = "Archive: $DateFormatted Daily Log"
} else {
    # 입력이 있으면 'Archive: 날짜 키워드' 형식으로 설정
    $CommitMessage = "Archive: $DateFormatted $UserInput"
}

# 커밋 수행
git commit -m $CommitMessage

# 원격 저장소에 푸시 (실패 방지를 위해 별도의 명령어 사용)
git push origin $GitBranch

Write-Host "--- [작업 완료] ---" -ForegroundColor Green
Write-Host "커밋 메시지: '$CommitMessage'" -ForegroundColor Green
Write-Host "파일들이 $Today 폴더에 보관되었습니다." -ForegroundColor Green