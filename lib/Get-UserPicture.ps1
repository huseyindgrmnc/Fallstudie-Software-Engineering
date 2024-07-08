# Define the PSN username
param (
    [string]$username
)

# Load the HtmlAgilityPack DLL
Add-Type -Path "C:\Users\silviu.moldovan\AndroidStudioProjects\fallstudiev2\lib\HtmlAgilityPack.dll"

Write-Output "Fetching profile picture for PSN user: $username"

# Define the URL for the PSNProfiles profile page
$url = "https://psnprofiles.com/$username"

# Send a web request to the profile page
$response = Invoke-WebRequest -Uri $url

# Check if the request was successful
if ($response.StatusCode -ne 200) {
    Write-Host "Failed to retrieve profile page. Status code: $($response.StatusCode)"
    exit
}

# Parse the HTML to find the profile picture URL using HtmlAgilityPack
$html = $response.Content
$doc = New-Object HtmlAgilityPack.HtmlDocument
$doc.LoadHtml($html)

# Function to extract profile image URL
function Get-ProfileImageUrl {
    param (
        [HtmlAgilityPack.HtmlDocument]$doc,
        [string]$className
    )

    $profileImgTag = $doc.DocumentNode.SelectSingleNode("//div[@class='$className']/img")
    if ($profileImgTag) {
        return $profileImgTag.Attributes["src"].Value
    } else {
        return $null
    }
}

# Try to get the profile image URL from both possible class names
$profileImgUrl = Get-ProfileImageUrl -doc $doc -className 'avatar'
if (-not $profileImgUrl) {
    $profileImgUrl = Get-ProfileImageUrl -doc $doc -className 'ps-plus'
}

if ($profileImgUrl) {
    Write-Host "Profile picture URL: $profileImgUrl"

    # Define the output path for the downloaded image
    $outputPath = "C:\Users\hdegirmenci\AndroidStudioProjects\fallstudie1\assets\$username-profile-picture.jpg"

    # Download the profile picture
    Invoke-WebRequest -Uri $profileImgUrl -OutFile $outputPath
    Write-Host "Profile picture downloaded to: $outputPath"

    # Ensure only 3 images in the assets folder
    $assetsPath = "C:\Users\silviu.moldovan\AndroidStudioProjects\fallstudiev2\assets"
    $images = Get-ChildItem -Path $assetsPath -Filter *.jpg | Sort-Object LastWriteTime
    $imageCount = $images.Count

    if ($imageCount -gt 3) {
        $imagesToDelete = $images[0..($imageCount - 4)]
        foreach ($image in $imagesToDelete) {
            Remove-Item -Path $image.FullName
            Write-Host "Deleted old image: $($image.FullName)"
        }
    }
} else {
    Write-Host "Failed to find profile picture URL in the profile page."
}
