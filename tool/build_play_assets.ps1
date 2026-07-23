param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sourceIcon = Join-Path $ProjectRoot 'marketing\brand\bangunin-icon-1024.png'
$mascotPath = Join-Path $ProjectRoot 'marketing\brand\poses_raw\crowing.png'
$fontPath = Join-Path $ProjectRoot 'assets\fonts\Baloo2.ttf'
$outputDir = Join-Path $ProjectRoot 'marketing\play-store\assets'
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

function New-Graphics([System.Drawing.Image]$bitmap) {
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    return $graphics
}

$iconSource = [System.Drawing.Image]::FromFile($sourceIcon)
$icon = New-Object System.Drawing.Bitmap 512, 512, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$iconGraphics = New-Graphics $icon
$iconGraphics.DrawImage($iconSource, 0, 0, 512, 512)
$icon.Save((Join-Path $outputDir 'app-icon-512.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$iconGraphics.Dispose()
$icon.Dispose()
$iconSource.Dispose()

$feature = New-Object System.Drawing.Bitmap 1024, 500, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = New-Graphics $feature
$bounds = New-Object System.Drawing.Rectangle 0, 0, 1024, 500
$gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $bounds,
    ([System.Drawing.Color]::FromArgb(14, 22, 48)),
    ([System.Drawing.Color]::FromArgb(31, 43, 91)),
    0
)
$graphics.FillRectangle($gradient, $bounds)

$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile($fontPath)
$fontFamily = $fonts.Families[0]
$titleFont = New-Object System.Drawing.Font $fontFamily, 80, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
$subtitleFont = New-Object System.Drawing.Font $fontFamily, 31, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(244, 245, 248))
$yellow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 214, 10))

$graphics.DrawString('Bangunin', $titleFont, $yellow, 96, 142)
$graphics.DrawString('Alarm yang memastikan', $subtitleFont, $white, 102, 254)
$graphics.DrawString('kamu benar-benar bangun.', $subtitleFont, $white, 102, 294)

$mascot = [System.Drawing.Image]::FromFile($mascotPath)
$mascotClip = New-Object System.Drawing.Drawing2D.GraphicsPath
$mascotClip.AddEllipse(570, -50, 500, 500)
$graphics.SetClip($mascotClip)
$graphics.DrawImage($mascot, 600, -30, 455, 455)
$graphics.ResetClip()

$feature.Save((Join-Path $outputDir 'feature-graphic-1024x500.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$mascot.Dispose()
$mascotClip.Dispose()
$titleFont.Dispose()
$subtitleFont.Dispose()
$white.Dispose()
$yellow.Dispose()
$fonts.Dispose()
$gradient.Dispose()
$graphics.Dispose()
$feature.Dispose()

Write-Output "Created Google Play icon and feature graphic in $outputDir"
