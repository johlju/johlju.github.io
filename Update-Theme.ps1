[CmdletBinding()]
param()

$sourceFullPath = 'C:\Source\minimal-mistakes'
$destinationFullPath = 'C:\Source\johlju.github.io'


$changedFiles = Get-ChildItem -Path $sourceFullPath -Recurse -File -Exclude @(
    '_config.yml'
    'authors.yml'
    'navigation.yml'
    '.editorconfig'
    '.gitattributes'
    '.gitignore'
    'CHANGELOG.md'
    'LICENSE.txt'
    'minimal-mistakes-jekyll.gemspec'
    'README.md'
    'screenshot-layouts.png'
    'screenshot.png'
    'CONTRIBUTING.md'
)

$changedFiles  = $changedFiles | Where-Object { -not $_.PSIsContainer }

$changedFiles = $changedFiles | Where-Object {
    $_.FullName -notmatch '\\docs' -and
    $_.FullName -notmatch '\\_posts' -and
    $_.FullName -notmatch '\\_pages' -and
    $_.FullName -notmatch '\\test' -and
    $_.FullName -notmatch '\\\.git' -and
    $_.FullName -notmatch '\\\.github'
}

$changedFiles | ForEach-Object -Process {
    $destinationFullName = ($_.FullName -replace ($sourceFullPath -replace '\\','\\'), $destinationFullPath)
    New-Item -ItemType File -Path $destinationFullName -Force | Out-Null # Used to touch the file so new paths are created.
    $_ | Copy-Item -Destination $destinationFullName -Force # Actually copies the new file contents.
}
