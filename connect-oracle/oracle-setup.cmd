REM Downlaod libraries for correct DB Version from
REM https://www.oracle.com/database/technologies/dotnet-utilsoft-downloads.html
REM (Requires Oracle Account)
REM Extract libs to C:\ODP.NET_Managed121020\
REM Create a sqlnet.ora and tnsnames.ora under C:\OracleConnection
echo "creating Oracle dir"
mkdir c:\OracleDAC > NUL
echo "copy Oracle libs"
cd "C:\ODP.NET_Managed121020\" > NUL
echo "installing Oracle libs"
call install_odpm.bat c:\OracleDAC x64 true > NUL
echo "setting env"
set TNSNAMES="C:\OracleDAC\network\admin"
echo "copy configs"
copy "C:\OracleConnection\sqlnet.ora" "C:\OracleDAC\network\admin" > NUL
copy "C:\OracleConnection\tnsnames.ora" "C:\OracleDAC\network\admin" > NUL
echo "done"
pause
