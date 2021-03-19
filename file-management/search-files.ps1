# Get all files older than 2 days under the current path
Get-ChildItem -Recurse | Where-Object {$_.lastwritetime -ge (get-date).AddDays(-2)}