#########################################
#
# A.Baumeler, 2020
#
# A Collection of powershell funcitons to
# convert GUIDs between different formats
# and to extract guids from filenames
#########################################


# Convert Binary Array to Hex
function BinToHex {
	param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	[Byte[]]$Bin
	)
	if ($bin.Length -eq 1) {$bin = @($input)}
	$return = -join ($Bin |  foreach { "{0:X2}" -f $_ })
	return $return
}

# Convert Hex Guid to String guid
function HexToBin {
	param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]              
	[string]$id
	)
	$return = @()    
	return $return
}

# Convert String Guid to HexStringGuid
function ConvertStringGUIDToHexStringGUID {
	param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	[String]$strGUID
	)
	
	Write-Host $strGUID
	$tmpGUID = $strGUID
	$tmpGUID = $tmpGUID.replace("}","") 
	$tmpGUID = $tmpGUID.replace("{","") 
	$tmpGUID = $tmpGUID.replace("-","")
	
	Write-Host $tmpGUID

	$octetStr =  ""
	$octetStr = $octetStr + $tmpGUID.substring(6, 2)             
	$octetStr = $octetStr + $tmpGUID.substring( 4, 2) 
	$octetStr = $octetStr + $tmpGUID.substring( 2, 2)  
	$octetStr = $octetStr + $tmpGUID.substring( 0, 2)  
	$octetStr = $octetStr + $tmpGUID.substring( 10, 2) 
	$octetStr = $octetStr + $tmpGUID.substring( 8, 2)  
	$octetStr = $octetStr + $tmpGUID.substring( 14, 2) 
	$octetStr = $octetStr + $tmpGUID.substring( 12, 2) 
	$octetStr = $octetStr + $tmpGUID.substring( 16, ($tmpGUID.Length-16))

	return $octetStr
}

function ConvertHexGUIDToStringGUID {
	param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
	[String]$hexGUID
	)
	$oct1 = $hexGUID.substring(0,2)
	$oct2 = $hexGUID.substring(2,2)
	$oct3 = $hexGUID.substring(4,2)
	$oct4 = $hexGUID.substring(6,2)
	$oct5 = $hexGUID.substring(8,2)
	$oct6 = $hexGUID.substring(10,2)
	$oct7 = $hexGUID.substring(12,2)
	$oct8 = $hexGUID.substring(14,2)
	$oct9 = $hexGUID.substring(16,4)
	$oct10 = $hexGUID.substring(20,12)

	$strOut = "{" + "$oct4" + "$oct3" + "$oct2" + "$oct1" + "-" + "$oct6" + "$oct5" + "-" + "$oct8" + "$oct7" + "-" + "$oct9" + "-" + "$oct10" + "}"

	return $strOut		
}

# Extract GUID from Filename
function ExtractGuidFromFilename {
    param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$false)]
	[String]$path
	)
    $files = Get-ChildItem $path
    foreach ($file in $files){
        # Looks for a GUID in the form of {d7d63032-1176-4e74-afe1-dd1b917ecbe3} in the filename
	    $file.Name -match ("{[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}}") | Out-Null
	    $Guid =  $Matches[0] 
	    Write-Host $Guid
    }
}

