[CmdletBinding()]
param()

$sourceFullPath = 'V:\Source\minimal-mistakes'
$destinationFullPath = 'V:\Source\johlju.github.io'


$changedFiles = Get-ChildItem -Path $source -Recurse -File -Exclude @(
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
    $destinationFullName = $_.FullName -replace ($sourceFullPath -replace '\\','\\'), $destinationFullPath
    $_ | Copy-Item -Destination $destinationFullName
}
