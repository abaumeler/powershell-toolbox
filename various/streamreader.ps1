####################################################
# 
# A.Baumeler, 2020
#
# Streamreader example. Usefull to process files
# that are too big to be loaded into memory entirely
# Reads the file provided line by line and writes 
# each line to the host.
# 
# Careful: Write-Host slows the reader down considerably.
# Use this only for demo purposes 
####################################################

$stream_reader = New-Object System.IO.StreamReader{C:\Path\To\Your\Infile.txt}
while(!$stream_reader.EndOfStream){
    $line = $stream_reader.ReadLine()
    Write-Host $line
}