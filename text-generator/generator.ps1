####################################################
# 
# A.Baumeler, 2020
#
# Simple script to copy phrases to the clipboard.
# Phrases can be selected by key from a dictionary
# Useful to type long emails with similar phrases
####################################################

$dict = @{ 
key1 = "Long phrase to be copied to the clipboard when key 1 is selected. "; 
key2 = "Long phrase to be copied to the clipboard when key 2 is selected. "; 
key3 = "Long phrase to be copied to the clipboard when key 2 is selected. "}

$run = $true
while($run) {
   $key = Read-Host "key"

   if ($dict.ContainsKey($key)){
    Set-Clipboard -Append $dict.$key
    Write-Host "ok"
   }elseif($key.Equals("show") -or $key.Equals("help")){
    $dict | Out-String
   }elseif($key.Equals(" ") -or $key.Equals("clear")){
    Set-Clipboard -Value " "
    Write-Host "cleared"
   }
   elseif($key.Equals("exit")){
    $run = $false
   }else{
    Write-Host "key not found"
   }
}
