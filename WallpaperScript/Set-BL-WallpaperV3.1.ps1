Write-Host "Running BL Wallpaper V3.1"
# Load System.Windows.Forms assembly at the beginning
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

# Inline c# code to refresh the wallpaper. Alternative is to call it via rundll32
# rundll32.exe user32.dll, UpdatePerUserSystemParameters, 1, True
Add-Type @"
    using System.Runtime.InteropServices;

    public class Wallpaper {
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

        public static void Refresh(string path) {
            SystemParametersInfo(20, 0, path, 0x01|0x02); 
        }
    }
"@

# Define PNG paths
$bearNosePngUrl = "https://github.com/BjornLundenIT/BjornLundenIntuneBranding/blob/main/Bear_Nose.png?raw=true"
$bjornLundenPngUrl = "https://github.com/BjornLundenIT/BjornLundenIntuneBranding/blob/main/BjornLunden.png?raw=true"
$bjornLundenWhitePngUrl = "https://github.com/BjornLundenIT/BjornLundenIntuneBranding/blob/main/BjornLundenWhite.png?raw=true"
$blBearPngUrl = "https://github.com/BjornLundenIT/BjornLundenIntuneBranding/blob/main/BLBear.png?raw=true"

# Define the new image path & name
$finalImageDirectory = "C:\ProgramData\BLIntune\BL-Wallpaper"
$finalImageName = "BLWallpaper.png"
$finalImagePath = Join-Path -Path $finalImageDirectory -ChildPath $finalImageName

# Define local paths for downloaded PNGs
$bearNosePngPath = Join-Path $finalImageDirectory "Bear_Nose.png"
$bjornLundenPngPath = Join-Path $finalImageDirectory "BjornLunden.png"
$bjornLundenWhitePngPath = Join-Path $finalImageDirectory "BjornLundenWhite.png"
$blBearPngPath = Join-Path $finalImageDirectory "BLBear.png"

#Define BjornLunden Text Logo Y position
$intY = 75
$intX = 15

# Define the flag file path
$global:flagFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "\WallpaperFlagV3.0.txt"

# --------------------------------------

function Initialize-WallpaperResources {
    # Create the target folder if it doesn't exist
    if (-not (Test-Path -Path $finalImageDirectory)) {
        New-Item -ItemType Directory -Path $finalImageDirectory -Force | Out-Null
    }

    # Download Bear Nose PNG if it doesn't exist
    if (-not (Test-Path -Path $bearNosePngPath)) {
        try {
            Invoke-WebRequest -Uri $bearNosePngUrl -OutFile $bearNosePngPath
            Write-Host "Bear nose image downloaded to $bearNosePngPath"
        }
        catch {
            Write-Warning "Failed to download bear nose image: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "Bear nose image already exists at $bearNosePngPath"
    }

    # Download BjornLunden PNG if it doesn't exist
    if (-not (Test-Path -Path $bjornLundenPngPath)) {
        try {
            Invoke-WebRequest -Uri $bjornLundenPngUrl -OutFile $bjornLundenPngPath
            Write-Host "BjornLunden image downloaded to $bjornLundenPngPath"
        }
        catch {
            Write-Warning "Failed to download BjornLunden image: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "BjornLunden image already exists at $bjornLundenPngPath"
    }

    # Download BjornLunden PNG if it doesn't exist
    if (-not (Test-Path -Path $bjornLundenWhitePngPath)) {
      try {
          Invoke-WebRequest -Uri $bjornLundenWhitePngUrl -OutFile $bjornLundenWhitePngPath
          Write-Host "BjornLunden image downloaded to $bjornLundenWhitePngPath"
      }
      catch {
          Write-Warning "Failed to download BjornLunden image: $($_.Exception.Message)"
      }
    }
    else {
        Write-Host "BjornLunden image already exists at $bjornLundenWhitePngPath"
    }

    # Download BLBear PNG if it doesn't exist
    if (-not (Test-Path -Path $blBearPngPath)) {
        try {
            Invoke-WebRequest -Uri $blBearPngUrl -OutFile $blBearPngPath
            Write-Host "BLBear image downloaded to $blBearPngPath"
        }
        catch {
            Write-Warning "Failed to download BLBear image: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "BLBear image already exists at $blBearPngPath"
    }
}
function Build-APeakingBearWallpaper {
    # Base scale factors that are considered "perfect" for a 2560px wide screen
    $baseBlBearEffectiveScale = 0.5 * 1.5 # Original logoScaleFactor * 1.5
    $baseTextLogoEffectiveScale = 0.3

    Add-Type -AssemblyName System.Drawing

    try {
        $screenWidth = 4096#[System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
        $screenHeight = 1152#[System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
    }
    catch {
        $screenWidth = 1920 # Fallback
        $screenHeight = 1080 # Fallback
    }
    Write-Host "Screen Width: $screenWidth, Screen Height: $screenHeight"

    # Define the reference width where base scaling is perfect
    $perfectReferenceWidth = 2560.0 # Use float for precision

    # Calculate adjustment factor based on current screen width vs perfect reference width
    $resolutionScaleAdjustment = $screenWidth / $perfectReferenceWidth

    # Dynamically adjusted scale factors for the current resolution
    $currentBlBearScale = $baseBlBearEffectiveScale * $resolutionScaleAdjustment
    $currentTextLogoScale = $baseTextLogoEffectiveScale * $resolutionScaleAdjustment

    # Define background colors
    $colors = @("#FFEEC9", "#202020")
    $backgroundColor = [System.Drawing.ColorTranslator]::FromHtml((Get-Random -InputObject $colors))

    if($backgroundColor.ToArgb() -eq [System.Drawing.ColorTranslator]::FromHtml("#202020").ToArgb() ) { # Compare Argb values for colors
        Write-Host "Choose white BjornLunden Logo"
        $BLTextVersion = $bjornLundenWhitePngPath
    } else {
        Write-Host "Choose dark BjornLunden Logo"
        $BLTextVersion = $bjornLundenPngPath
    }

    # Margins are scaled relative to 1920x1080 as per original logic
    # If margins also need to be relative to 2560x1440, this part would also need adjustment
    $marginReferenceWidth = 1920.0
    $marginReferenceHeight = 1080.0
    $scaleFactorX_Margins = $screenWidth / $marginReferenceWidth
    $scaleFactorY_Margins = $screenHeight / $marginReferenceHeight
    $fixedMarginY = [math]::Round($intY * $scaleFactorY_Margins) # $intY = 75 (global)
    $fixedMarginX = [math]::Round($intX * $scaleFactorX_Margins) # $intX = 15 (global)

    try {
        Write-Host "Attempting to load BLBear image from: $blBearPngPath"
        $blBearImage = [System.Drawing.Image]::FromFile($blBearPngPath)
        Write-Host "BLBear image loaded successfully."
        Write-Host "Attempting to load BjornLunden image from: $BLTextVersion"
        $bjornLundenImage = [System.Drawing.Image]::FromFile($BLTextVersion)
        Write-Host "BjornLunden image loaded successfully."

        # Calculate new sizes for PNGs using dynamically adjusted scales
        $blBearNewWidth = [math]::Round($blBearImage.Width * $currentBlBearScale)
        $blBearNewHeight = [math]::Round($blBearImage.Height * $currentBlBearScale)
        $bjornLundenNewWidth = [math]::Round($bjornLundenImage.Width * $currentTextLogoScale)
        $bjornLundenNewHeight = [math]::Round($bjornLundenImage.Height * $currentTextLogoScale)

        Write-Host "Original BLBear Width: $($blBearImage.Width), Height: $($blBearImage.Height)"
        Write-Host "Adjusted BLBear Scale: $currentBlBearScale, New Width: $blBearNewWidth, New Height: $blBearNewHeight"
        Write-Host "Original BjornLunden Width: $($bjornLundenImage.Width), Height: $($bjornLundenImage.Height)"
        Write-Host "Adjusted BjornLunden Scale: $currentTextLogoScale, New Width: $bjornLundenNewWidth, New Height: $bjornLundenNewHeight"

        $finalBitmap = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb).value__
        Write-Host "Final bitmap created."

        try {
            $graphics = [System.Drawing.Graphics]::FromImage($finalBitmap)
            Write-Host "Graphics object created."
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

            $solidBrush = New-Object System.Drawing.SolidBrush $backgroundColor
            $graphics.FillRectangle($solidBrush, 0, 0, $screenWidth, $screenHeight)
            $solidBrush.Dispose()

            $blBearX = $screenWidth - ([math]::Round($blBearNewWidth * 0.55)) # Show about 55% of new width
            $blBearY = ($screenHeight - $blBearNewHeight) / 2
            $graphics.DrawImage($blBearImage, $blBearX, $blBearY, $blBearNewWidth, $blBearNewHeight)

            $bjornLundenX = $fixedMarginX
            $bjornLundenY = $screenHeight - $bjornLundenNewHeight - $fixedMarginY
            $graphics.DrawImage($bjornLundenImage, $bjornLundenX, $bjornLundenY, $bjornLundenNewWidth, $bjornLundenNewHeight)
        }
        finally {
            if ($graphics) { $graphics.Dispose() }
        }

        Write-Host "Attempting to save the peaking bear wallpaper to: $($finalImagePath)"
        $finalBitmap.Save($finalImagePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host "Peaking bear wallpaper saved successfully."
        $finalBitmap.Dispose()
        $blBearImage.Dispose()
        $bjornLundenImage.Dispose()
    }
    catch {
        Write-Warning "Error building the peaking bear wallpaper: $($_.Exception.Message)"
        return $null
    }
    return $finalImagePath
}

function Build-ABearWallpaper {
    # Base scale factor that is considered "perfect" for a 2560px wide screen
    $baseLogoEffectiveScale = 0.3

    Add-Type -AssemblyName System.Drawing

    try {
        $screenWidth = 4096#[System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
        $screenHeight = 1152#[System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
    }
    catch {
        $screenWidth = 1920 # Fallback
        $screenHeight = 1080 # Fallback
    }
    Write-Host "Screen Width: $screenWidth, Screen Height: $screenHeight"

    # Define the reference width where base scaling is perfect
    $perfectReferenceWidth = 2560.0 # Use float for precision

    # Calculate adjustment factor based on current screen width vs perfect reference width
    $resolutionScaleAdjustment = $screenWidth / $perfectReferenceWidth

    # Dynamically adjusted scale factor for the current resolution
    $currentLogoScale = $baseLogoEffectiveScale * $resolutionScaleAdjustment
    
    # Define background colors
    $colors = @("#FFBB00", "#F7CFE0", "#FFEEC9", "#202020")
    $backgroundColor = [System.Drawing.ColorTranslator]::FromHtml((Get-Random -InputObject $colors))

    if($backgroundColor.ToArgb() -eq [System.Drawing.ColorTranslator]::FromHtml("#202020").ToArgb() ) { # Compare Argb values for colors
        Write-Host "Choose white BjornLunden Logo"
        $BLTextVersion = $bjornLundenWhitePngPath
    } else {
        Write-Host "Choose dark BjornLunden Logo"
        $BLTextVersion = $bjornLundenPngPath
    }
    
    # Margins are scaled relative to 1920x1080 as per original logic
    $marginReferenceWidth = 1920.0
    $marginReferenceHeight = 1080.0
    $scaleFactorX_Margins = $screenWidth / $marginReferenceWidth
    $scaleFactorY_Margins = $screenHeight / $marginReferenceHeight
    $fixedMarginY = [math]::Round($intY * $scaleFactorY_Margins) # $intY = 75 (global)
    $fixedMarginX = [math]::Round($intX * $scaleFactorX_Margins) # $intX = 15 (global)

    try {
        $bearNoseImage = [System.Drawing.Image]::FromFile($bearNosePngPath)
        $bjornLundenImage = [System.Drawing.Image]::FromFile($BLTextVersion)

        # Calculate new sizes for PNGs using dynamically adjusted scale
        $bearNoseNewWidth = [math]::Round($bearNoseImage.Width * $currentLogoScale)
        $bearNoseNewHeight = [math]::Round($bearNoseImage.Height * $currentLogoScale)
        $bjornLundenNewWidth = [math]::Round($bjornLundenImage.Width * $currentLogoScale) # Uses same scale
        $bjornLundenNewHeight = [math]::Round($bjornLundenImage.Height * $currentLogoScale) # Uses same scale

        Write-Host "Original Bear Nose Width: $($bearNoseImage.Width), Height: $($bearNoseImage.Height)"
        Write-Host "Adjusted Bear Nose Scale: $currentLogoScale, New Width: $bearNoseNewWidth, New Height: $bearNoseNewHeight"
        Write-Host "Original BjornLunden Width: $($bjornLundenImage.Width), Height: $($bjornLundenImage.Height)"
        Write-Host "Adjusted BjornLunden Scale: $currentLogoScale, New Width: $bjornLundenNewWidth, New Height: $bjornLundenNewHeight"

        $finalBitmap = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight
        $graphics = [System.Drawing.Graphics]::FromImage($finalBitmap)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        $solidBrush = New-Object System.Drawing.SolidBrush $backgroundColor
        $graphics.FillRectangle($solidBrush, 0, 0, $screenWidth, $screenHeight)
        $solidBrush.Dispose()

        $bearNoseX = ($screenWidth - $bearNoseNewWidth) / 2
        $bearNoseY = ($screenHeight - $bearNoseNewHeight) / 2
        $graphics.DrawImage($bearNoseImage, $bearNoseX, $bearNoseY, $bearNoseNewWidth, $bearNoseNewHeight)

        $bjornLundenX = $fixedMarginX
        $bjornLundenY = $screenHeight - $bjornLundenNewHeight - $fixedMarginY
        $graphics.DrawImage($bjornLundenImage, $bjornLundenX, $bjornLundenY, $bjornLundenNewWidth, $bjornLundenNewHeight)

        $finalBitmap.Save($finalImagePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $graphics.Dispose()
        $finalBitmap.Dispose()
        $bearNoseImage.Dispose()
        $bjornLundenImage.Dispose()
    }
    catch {
        Write-Warning "Error building the wallpaper: $($_.Exception.Message)"
        return $null
    }
    return $finalImagePath
}

function Set-Wallpaper {
    # Pick Random Wallpaper Function
    $RandomWallpaper = 20 | ForEach-Object { Get-Random -InputObject @('Bear', 'PeakingBear') }
    if($RandomWallpaper -eq "Bear")
    {
        $wallpaperPath = Build-ABearWallpaper
    }else {
        $wallpaperPath = Build-APeakingBearWallpaper
    }

    #$wallpaperPath = Build-APeakingBearWallpaper #For testing
    if ($wallpaperPath) {
        Write-Host "Wallpaper created at: $wallpaperPath"
        Write-Host "Trigger wallpaper refresh using RUNDLL32"
        try {
            RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
            [Wallpaper]::Refresh($wallpaperPath)
            Write-Host "Wallpaper refresh triggered via RUNDLL32"
        }
        catch {
            Write-Warning "Error triggering wallpaper refresh via RUNDLL32: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Failed to build wallpaper."
    }
}

#--------------------------
#--- Main script start ----
#--------------------------
$logFilePath = Join-Path $finalImageDirectory "Set-Wallpaper_AsUser.log"
Start-Transcript -Path $logFilePath -Verbose

Write-Host "-Start script block"
Write-Host "Using wallpaper path: $finalImagePath"

Initialize-WallpaperResources

if (!(Test-Path $flagFilePath)) {
    # This is the first run of the script, so create the flag file
    Set-Content -Path $flagFilePath -Value "This is a flag file to indicate the wallpaper script has run at least once."

    # Regardless of the user-defined wallpaper, go ahead and set the new wallpaper
    Write-Host "First run detected, triggering Set-Wallpaper procedure regardless of user-defined wallpaper"
    Set-Wallpaper
}
else {
    if (Test-Path $finalImagePath) {
        Write-Host "Wallpaper already exists here: $finalImagePath"

        $regkey = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallPaper -ErrorAction SilentlyContinue
        if ($null -eq $regkey) {
            Write-Host "Missing wallpaper key in registry, not touching anything"
        }
        else {
            $currentWallpaper = $regkey.WallPaper
            Write-Host "Current wallpaper set in registry: $currentWallpaper"

            # Check if current wallpaper is still set to our wallpaper and not a user defined one.
            # If a user defined one is set in the meanwhile, we are not going to change it!
            if ($currentWallpaper -ceq $finalImagePath) {
                Write-Host "No user-defined wallpaper found for user [$env:USERNAME], triggering re-build and update"

                # Enforce new download and rebuild
                Initialize-WallpaperResources
                Set-Wallpaper
            }
            else {
                Write-Host "User-defined wallpaper found for user [$env:USERNAME], nothing to do"
            }
        }
    }
    else {
        # No image built yet, go and build the wallpaper and set it
        Write-Host "Wallpaper not found, trigger Set-Wallpaper procedure"
        # Download and refresh
        Set-Wallpaper
    }
}

Write-Host "-End script block"
Stop-Transcript