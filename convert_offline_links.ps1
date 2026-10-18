# convert_offline_links.ps1
# Script to convert online Kali documentation links (https://www.kali.org/tools/...)
# to local relative .html paths for offline browsing, ensuring all tools are
# seamlessly connected to all-tools/index.html.

param (
    [string]$ToolsDir = "C:\Users\ADMIN\Desktop\kali\Kali-Tools-Offline\www.kali.org\tools"
)

$toolsPath = (Resolve-Path $ToolsDir).Path
Write-Host "Target Tools Directory: $toolsPath"

$baseTagRegex = [regex]'<base\s+[^>]*>'
$cssRepairRegex = [regex]'href=["'']?\.\.?/index\.html["'']?\.min\.css'
$tagRepairRegex = [regex]'href=["'']?\.\.?/>([^"''/]+)/index\.html["'']?'
$linkRegex = [regex]'href=["'']?https://www\.kali\.org/tools/(?:([^"''\s/><#]+)/?)?(#[^"''\s>]*)?["'']?'

$htmlFiles = Get-ChildItem -Path $toolsPath -Filter "*.html" -Recurse
$totalFiles = $htmlFiles.Count
Write-Host "Found $totalFiles HTML files to process."

$processedCount = 0
$modifiedCount = 0

foreach ($file in $htmlFiles) {
    $processedCount++
    $filePath = $file.FullName
    $relPath = $filePath.Substring($toolsPath.Length).TrimStart('\', '/')
    
    $parts = $relPath -split '[\\/]'
    $isRoot = ($parts.Length -eq 1)
    $currentFolder = if ($isRoot) { "" } else { $parts[0] }

    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $originalContent = $content

    # 1. Remove base tag
    $content = $baseTagRegex.Replace($content, '')

    # 2. Repair potential CSS / tag collisions
    $content = $cssRepairRegex.Replace($content, 'href="https://www.kali.org/tools.min.css')
    $content = $tagRepairRegex.Replace($content, 'href="https://www.kali.org/tools/">$1')

    # 3. Rewrite href links
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
        param($match)
        $targetTool = $match.Groups[1].Value
        $anchor = $match.Groups[2].Value

        if ($isRoot) {
            if ([string]::IsNullOrEmpty($targetTool)) {
                return if ([string]::IsNullOrEmpty($anchor)) { 'href="./index.html"' } else { "href=`"$anchor`"" }
            } else {
                return "href=`"./$targetTool/index.html$anchor`""
            }
        } else {
            if ([string]::IsNullOrEmpty($targetTool)) {
                return if ([string]::IsNullOrEmpty($anchor)) { 'href="../index.html"' } else { "href=`"../index.html$anchor`"" }
            } elseif ($targetTool -eq $currentFolder) {
                return if ([string]::IsNullOrEmpty($anchor)) { 'href="./index.html"' } else { "href=`"$anchor`"" }
            } else {
                return "href=`"../$targetTool/index.html$anchor`""
            }
        }
    }

    $content = $linkRegex.Replace($content, $evaluator)

    # 4. In individual tool pages, ensure 'Go back' and 'Tools Documentation' connect to all-tools
    if (-not $isRoot -and $currentFolder -ne "all-tools" -and $currentFolder -ne "top-100") {
        $content = $content.Replace('<a href="../index.html" title="↤ Go back"></a>', '<a href="../all-tools/index.html" title="↤ Go back"></a>')
        $content = $content.Replace('<a href="../index.html">Tools Documentation</a>', '<a href="../all-tools/index.html">Tools Documentation</a>')
    }

    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
        $modifiedCount++
    }

    if ($processedCount % 100 -eq 0 -or $processedCount -eq $totalFiles) {
        Write-Host "Processed $processedCount / $totalFiles files ($modifiedCount updated)..."
    }
}

Write-Host "Done! Successfully processed $totalFiles files."
