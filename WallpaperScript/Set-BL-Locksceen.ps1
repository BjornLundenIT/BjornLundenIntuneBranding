function Initialize-BearImage {
    $targetFolder = "C:\ProgramData\BLIntune\BL-Lockscreen"
    $bearImagePath = Join-Path $targetFolder "BLBear.png"
    $bearImageUrl = "https://github.com/BjornLundenIT/BjornLundenIntuneBranding/blob/main/BLBear.png?raw=true"

    # Create the folder if it doesn't exist
    if (-not (Test-Path -Path $targetFolder)) {
        New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
    }

    # Download the image if it doesn't exist
    if (-not (Test-Path -Path $bearImagePath)) {
        try {
            Invoke-WebRequest -Uri $bearImageUrl -OutFile $bearImagePath
            Write-Host "Bear image downloaded to $bearImagePath"
        }
        catch {
            Write-Warning "Failed to download bear image: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "Bear image already exists at $bearImagePath"
    }
}

function Build-BearWallpaper {
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms

    # Define image paths
    $bearPngPath = "C:\ProgramData\BLIntune\BL-Lockscreen\BLBear.png"
    $finalImagePath = "C:\ProgramData\BLIntune\BL-Lockscreen\BL_Lock1.png"
    $tmp_2thirdsBackgroundPic = "C:\ProgramData\BLIntune\BL-Lockscreen\Tmp_2thirdsbackground.png"
    $tmp_2thirdsBackgroundWithBearPic = "C:\ProgramData\BLIntune\BL-Lockscreen\Tmp_2thirdsbackgroundWBear.png"
    $tmp_backgroundPic = "C:\ProgramData\BLIntune\BL-Lockscreen\Tmp_background.png"

    # Retrieve primary monitor size
    $screenWidth = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
    $screenHeight = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
    Write-Host "Screen Width: $screenWidth, Screen Height: $screenHeight"

    # Define background color
    $backgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#202020")

    # Reference dimensions (we'll use these to control the scaling of the PNG)
    $referenceWidth = 1920
    $referenceHeight = 1080

    # Load the bear image to get its original dimensions
    try {
        $bearImageOriginal = [System.Drawing.Image]::FromFile($bearPngPath)
        $bearOriginalWidth = $bearImageOriginal.Width
        $bearOriginalHeight = $bearImageOriginal.Height
        Write-Host "Original Bear Width: $bearOriginalWidth, Original Bear Height: $bearOriginalHeight"

        $scaleFactorX = $screenWidth / $referenceWidth
        $scaleFactorY = $screenHeight / $referenceHeight
        
        # Use the smaller scale to maintain aspect ratio
        $uniformScaleFactor = [Math]::Max($scaleFactorX, $scaleFactorY)
        
        # Calculate new dimensions for the bear PNG using uniform scale
        $bearNewWidth = [math]::Round($bearOriginalWidth / 10.7 * 2 * $uniformScaleFactor)
        $bearNewHeight = [math]::Round($bearOriginalHeight / 10.7 * 2 * $uniformScaleFactor)
        
        Write-Host "New Bear Width: $bearNewWidth, New Bear Height: $bearNewHeight"
        $bearImageOriginal.Dispose()
    }
    catch {
        Write-Warning "Error loading the bear image: $($_.Exception.Message)"
        return # Exit the function if there's an error
    }

    # --- Create Backgrounds ---
    # Full background
    $background = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight
    $backgroundGraphics = [System.Drawing.Graphics]::FromImage($background)
    $solidBrush = New-Object System.Drawing.SolidBrush $backgroundColor
    $backgroundGraphics.FillRectangle($solidBrush, 0, 0, $screenWidth, $screenHeight)
    $backgroundGraphics.Dispose()
    $solidBrush.Dispose()
    $background.Save($tmp_backgroundPic, [System.Drawing.Imaging.ImageFormat]::Png)
    $background.Dispose()

    # 2/3 height background
    $twoThirdsHeight = [int]($screenHeight * (2/3))
    $twoThirdsBackground = New-Object System.Drawing.Bitmap $screenWidth, $twoThirdsHeight
    $twoThirdsBackgroundGraphics = [System.Drawing.Graphics]::FromImage($twoThirdsBackground)
    $solidBrush = New-Object System.Drawing.SolidBrush $backgroundColor
    $twoThirdsBackgroundGraphics.FillRectangle($solidBrush, 0, 0, $screenWidth, $twoThirdsHeight)
    $twoThirdsBackgroundGraphics.Dispose()
    $solidBrush.Dispose()
    $twoThirdsBackground.Save($tmp_2thirdsBackgroundPic, [System.Drawing.Imaging.ImageFormat]::Png)
    $twoThirdsBackground.Dispose()

    # --- Resize and Composite Bear onto the 2/3 background ---
    try {
        $bearImage = [System.Drawing.Image]::FromFile($bearPngPath)
        # Try explicitly setting the pixel format (CORRECTED SYNTAX)
        $resizedBear = New-Object System.Drawing.Bitmap $bearNewWidth, $bearNewHeight, 'Format32bppArgb'
        #
        # Temporary simplified resizing for testing:
        # $resizedBear = New-Object System.Drawing.Bitmap 200, 200

        $resizeGraphics = [System.Drawing.Graphics]::FromImage($resizedBear)
        $resizeGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $resizeGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

        $resizeGraphics.DrawImage($bearImage, 0, 0, $bearNewWidth, $bearNewHeight)
        $resizeGraphics.Dispose()
        $bearImage.Dispose()

        $twoThirdsBackgroundWithBear = [System.Drawing.Image]::FromFile($tmp_2thirdsBackgroundPic)
        $compositeGraphics = [System.Drawing.Graphics]::FromImage($twoThirdsBackgroundWithBear)

        # Calculate center position for the bear
        $bearX = ($screenWidth - $resizedBear.Width) / 2
        $bearY = ($twoThirdsHeight - $resizedBear.Height) / 2

        $compositeGraphics.DrawImage($resizedBear, $bearX, $bearY)
        $compositeGraphics.Dispose()
        $resizedBear.Dispose()
        $twoThirdsBackgroundWithBear.Save($tmp_2thirdsBackgroundWithBearPic, [System.Drawing.Imaging.ImageFormat]::Png)
        $twoThirdsBackgroundWithBear.Dispose()
    }
    catch {
        Write-Warning "Error processing and compositing the bear image: $($_.Exception.Message)"
        return # Exit the function if there's an error
    }

    # --- Composite the 2/3 image onto the full background ---
    try {
        $finalImage = [System.Drawing.Image]::FromFile($tmp_backgroundPic)
        $topImage = [System.Drawing.Image]::FromFile($tmp_2thirdsBackgroundWithBearPic)
        $finalGraphics = [System.Drawing.Graphics]::FromImage($finalImage)

        # Draw the top 2/3 image at the bottom of the full background
        $finalGraphics.DrawImage($topImage, 0, $screenHeight - $topImage.Height)

        $finalGraphics.Dispose()
        $topImage.Dispose()
        $finalImage.Save($finalImagePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $finalImage.Dispose()
    }
    catch {
        Write-Warning "Error compositing the final image: $($_.Exception.Message)"
    }

    # --- Clean up temporary files ---
    Remove-Item $tmp_backgroundPic -ErrorAction SilentlyContinue
    Remove-Item $tmp_2thirdsBackgroundPic -ErrorAction SilentlyContinue
    Remove-Item $tmp_2thirdsBackgroundWithBearPic -ErrorAction SilentlyContinue
}

$BL_BearLockscreenLog = "C:\ProgramData\BLIntune\BL-Lockscreen\Set-Lockscreen.log"

Start-Transcript -Path $BL_BearLockscreenLog

Initialize-BearImage
Build-BearWallpaper

RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True

Stop-Transcript