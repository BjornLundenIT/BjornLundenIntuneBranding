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
    $logoScaleFactor = 0.5 # Adjust this value to control the logo size (e.g., 0.5 for half the current size)
    $TextLogoScaleFactor = 0.3
    Add-Type -AssemblyName System.Drawing
    # We've moved the System.Windows.Forms loading to the top

    # Retrieve primary monitor size
    try {
        $screenWidth = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
        $screenHeight = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
    }
    catch {
        $screenWidth = 1920
        $screenHeight = 1080
    }
    Write-Host "Screen Width: $screenWidth, Screen Height: $screenHeight"

    # Define background colors
    $colors = @("#FFEEC9", "#202020")


    # Select a random color
    $backgroundColor = [System.Drawing.ColorTranslator]::FromHtml((Get-Random -InputObject $colors))

    if($backgroundColor -eq "#202020" )#-or $backgroundColor -eq "#4A8B4D" -or $backgroundColor -eq "#1F79C3")
    {
        Write-host "Choose white BjornLunden Logo"
        $BLTextVersion = $bjornLundenWhitePngPath
    }else {
        Write-host "Choose dark BjornLunden Logo"
        $BLTextVersion = $bjornLundenPngPath
    }

    # Reference dimensions for scaling
    $referenceWidth = 1920
    $referenceHeight = 1080
    $scaleFactorX = $screenWidth / $referenceWidth
    $scaleFactorY = $screenHeight / $referenceHeight

    # Fixed margin values for the BjornLunden logo
    $fixedMarginY = [math]::Round(58 * $scaleFactorY)
    $fixedMarginX = [math]::Round(15 * $scaleFactorX)

    # Load the PNG images
    try {
        Write-Host "Attempting to load BLBear image from: $blBearPngPath"
        $blBearImage = [System.Drawing.Image]::FromFile($blBearPngPath)
        Write-Host "BLBear image loaded successfully."
        Write-Host "Attempting to load BjornLunden image from: $BLTextVersion"
        $bjornLundenImage = [System.Drawing.Image]::FromFile($BLTextVersion)
        Write-Host "BjornLunden image loaded successfully."

        # Calculate new sizes for PNGs using the logo scale factor
        $blBearNewWidth = [math]::Round($blBearImage.Width * $logoScaleFactor*1.5)
        $blBearNewHeight = [math]::Round($blBearImage.Height * $logoScaleFactor*1.5)
        $bjornLundenNewWidth = [math]::Round($bjornLundenImage.Width * $TextLogoScaleFactor)
        $bjornLundenNewHeight = [math]::Round($bjornLundenImage.Height * $TextLogoScaleFactor)

        Write-Host "Original BLBear Width: $($blBearImage.Width), Height: $($blBearImage.Height)"
        Write-Host "New BLBear Width: $blBearNewWidth, Height: $blBearNewHeight"
        Write-Host "Original BjornLunden Width: $($bjornLundenImage.Width), Height: $($bjornLundenImage.Height)"
        Write-Host "New BjornLunden Width: $bjornLundenNewWidth, Height: $bjornLundenNewHeight"

        # Create the final bitmap with a specific pixel format
        $finalBitmap = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb).value__
        Write-Host "Final bitmap created."

        try {
            $graphics = [System.Drawing.Graphics]::FromImage($finalBitmap)
            Write-Host "Graphics object created."
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

            # Fill the background with the selected color
            $solidBrush = New-Object System.Drawing.SolidBrush $backgroundColor
            $graphics.FillRectangle($solidBrush, 0, 0, $screenWidth, $screenHeight)
            $solidBrush.Dispose()

            # Calculate the X position for the BLBear image (slightly offscreen to the right)
            $blBearX = $screenWidth - ([math]::Round($blBearNewWidth * 0.55)) # Show about 75%
            $blBearY = ($screenHeight - $blBearNewHeight) / 2

            # Draw the BLBear image
            $graphics.DrawImage($blBearImage, $blBearX, $blBearY, $blBearNewWidth, $blBearNewHeight)

            # Position BjornLunden logo at the bottom left with margin
            $bjornLundenX = $fixedMarginX
            $bjornLundenY = $screenHeight - $bjornLundenNewHeight - $fixedMarginY

            # Draw BjornLunden logo
            $graphics.DrawImage($bjornLundenImage, $bjornLundenX, $bjornLundenY, $bjornLundenNewWidth, $bjornLundenNewHeight)

        }
        finally {
            if ($graphics) {
                $graphics.Dispose()
            }
        }

        # Check if $finalBitmap is null before saving
        Write-Host "Value of \$finalBitmap before Save: $($finalBitmap)"

        # Save the final image directly
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
    $logoScaleFactor = 0.3 # Adjust this value to control the logo size (e.g., 0.5 for half the current size)
    Add-Type -AssemblyName System.Drawing
    # We've moved the System.Windows.Forms loading to the top

    # Retrieve primary monitor size
    try {
        $screenWidth = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
        $screenHeight = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
    }
    catch {
        $screenWidth = 1920
        $screenHeight = 1080
    }
    Write-Host "Screen Width: $screenWidth, Screen Height: $screenHeight"

    # Define background colors
    $colors = @("#FFBB00", "#F7CFE0", "#FFEEC9", "#202020")

    # Select a random color
    $backgroundColor = [System.Drawing.ColorTranslator]::FromHtml((Get-Random -InputObject $colors))

    if($backgroundColor -eq "#202020")
    {
        Write-host "Choose white BjornLunden Logo"
        $BLTextVersion = $bjornLundenWhitePngPath
    }else {
        Write-host "Choose dark BjornLunden Logo"
        $BLTextVersion = $bjornLundenPngPath
    }
    

    # Reference dimensions for scaling (we'll use this for relative positioning)
    $referenceWidth = 1920
    $referenceHeight = 1080
    $scaleFactorX = $screenWidth / $referenceWidth
    $scaleFactorY = $screenHeight / $referenceHeight

    # Fixed margin values (scaled by screen resolution)
    $fixedMarginY = [math]::Round(58 * $scaleFactorY)
    $fixedMarginX = [math]::Round(15 * $scaleFactorX)

    # Load the PNG images
    try {
        $bearNoseImage = [System.Drawing.Image]::FromFile($bearNosePngPath)
        $bjornLundenImage = [System.Drawing.Image]::FromFile($BLTextVersion)

        # Calculate new sizes for PNGs using the new scale factor
        $bearNoseNewWidth = [math]::Round($bearNoseImage.Width * $logoScaleFactor)
        $bearNoseNewHeight = [math]::Round($bearNoseImage.Height * $logoScaleFactor)
        $bjornLundenNewWidth = [math]::Round($bjornLundenImage.Width * $logoScaleFactor)
        $bjornLundenNewHeight = [math]::Round($bjornLundenImage.Height * $logoScaleFactor)

        Write-Host "Original Bear Nose Width: $($bearNoseImage.Width), Height: $($bearNoseImage.Height)"
        Write-Host "New Bear Nose Width: $bearNoseNewWidth, Height: $bearNoseNewHeight"
        Write-Host "Original BjornLunden Width: $($bjornLundenImage.Width), Height: $($bjornLundenImage.Height)"
        Write-Host "New BjornLunden Width: $bjornLundenNewWidth, Height: $bjornLundenNewHeight"

        # Create the final bitmap
        $finalBitmap = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight
        $graphics = [System.Drawing.Graphics]::FromImage($finalBitmap)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        # Fill the background with the selected color
        $solidBrush = New-Object System.Drawing.SolidBrush $backgroundColor
        $graphics.FillRectangle($solidBrush, 0, 0, $screenWidth, $screenHeight)
        $solidBrush.Dispose()

        # Calculate center position for the bear nose
        $bearNoseX = ($screenWidth - $bearNoseNewWidth) / 2
        $bearNoseY = ($screenHeight - $bearNoseNewHeight) / 2

        # Draw the bear nose onto the final bitmap with new dimensions
        $graphics.DrawImage($bearNoseImage, $bearNoseX, $bearNoseY, $bearNoseNewWidth, $bearNoseNewHeight)

        # Position BjornLunden logo at the bottom left with margin
        $bjornLundenX = $fixedMarginX
        $bjornLundenY = $screenHeight - $bjornLundenNewHeight - $fixedMarginY

        # Draw BjornLunden logo onto the final bitmap with new dimensions
        $graphics.DrawImage($bjornLundenImage, $bjornLundenX, $bjornLundenY, $bjornLundenNewWidth, $bjornLundenNewHeight)

        # Save the final image
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