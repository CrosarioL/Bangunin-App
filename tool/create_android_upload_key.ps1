param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$keyFile = Join-Path $ProjectRoot 'android\app\upload-keystore.jks'
$propertiesFile = Join-Path $ProjectRoot 'android\key.properties'
$backupFile = Join-Path $ProjectRoot 'android\release-secrets-backup.txt'

if ((Test-Path -LiteralPath $keyFile) -or
    (Test-Path -LiteralPath $propertiesFile) -or
    (Test-Path -LiteralPath $backupFile)) {
    throw 'Release signing files already exist. Nothing was overwritten.'
}

$alphabet = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%_-'
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$randomBytes = New-Object byte[] 36
$rng.GetBytes($randomBytes)
$rng.Dispose()
$password = -join ($randomBytes | ForEach-Object {
    $alphabet[$_ % $alphabet.Length]
})
$alias = 'bangunin-upload'

$keytoolCandidates = @(
    'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe',
    'C:\Program Files\Android\Android Studio1\jbr\bin\keytool.exe'
)
if ($env:JAVA_HOME) {
    $keytoolCandidates = @((Join-Path $env:JAVA_HOME 'bin\keytool.exe')) + $keytoolCandidates
}
$keytool = $keytoolCandidates | Where-Object {
    $_ -and (Test-Path -LiteralPath $_)
} | Select-Object -First 1
if (-not $keytool) {
    throw 'keytool.exe was not found. Install Android Studio or set JAVA_HOME.'
}

& $keytool -genkeypair -v `
    -keystore $keyFile `
    -storetype PKCS12 `
    -storepass $password `
    -keypass $password `
    -keyalg RSA `
    -keysize 4096 `
    -validity 10000 `
    -alias $alias `
    -dname 'CN=Bangunin Upload, OU=Mobile, O=Bangunin, C=ID'

if ($LASTEXITCODE -ne 0) {
    throw "keytool failed with exit code $LASTEXITCODE"
}

@"
storePassword=$password
keyPassword=$password
keyAlias=$alias
storeFile=upload-keystore.jks
"@ | Set-Content -LiteralPath $propertiesFile -Encoding ASCII

@"
BANGUNIN ANDROID UPLOAD KEY — CONFIDENTIAL

Package: app.bangunin
Alias: $alias
Store password: $password
Key password: $password
Keystore: android/app/upload-keystore.jks

Back up this text file and upload-keystore.jks together in a secure password
manager or encrypted drive. Never commit, email, or send either file in chat.
Google Play App Signing will protect the production app-signing key, but this
upload key is still needed for routine future releases. Play Console can reset
an upload key if it is lost.
"@ | Set-Content -LiteralPath $backupFile -Encoding UTF8

Write-Output "Created Android upload key and local signing configuration."
Write-Output "Confidential backup: $backupFile"
