####################################################
# 
# A.Baumeler, 2020
#
# Simple script to sign another PS Script.
# cert.pfx needs to contain the private key.
####################################################
$cert = Get-PfxCertificate -FilePath "D:\Path\To\Your\cert.pfx"
Set-AuthenticodeSignature -FilePath "D:\Path\To\Your\script.ps1" -Certificate $cert
