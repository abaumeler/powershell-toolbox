param(
	[Parameter(Mandatory=$true)]
	[boolean]$isDebug = $true,
	[string] $name = "defaultName"
)

Write-Host "isDebug is set to: $($isDebug) and name is set to: $($name)"