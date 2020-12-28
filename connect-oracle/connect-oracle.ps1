##################################################################
#
#  A.Baumeler, 2020
#
# Script to connect to a Oracle Database without an installed
# Oracle Developer or SQL Client
#
# Prerequisites:
# - Uses Oracle ODP.NET_Managed121020, install
#             as described in: https://blog.darrenjrobinson.com/using-powershell-to-query-oracle-dbs-without-using-the-oracle-client-oracle-data-provider-for-net/
# - Needs an tsnames.ora file available under the 
#             path set in the TNSNAMES environment variable
# - Oracle Setup can be done with .cmd from this repo
##################################################################

#############################
# Parameters
#############################

# SQL DB Username, Password and DataSource Alias (as per tnsnames.ora)
$username = "User"
$password = "Password"
$datasource = "PRODDB01"

# Path to ODAC.NET Installation
$OracleMDAPath = "C:\OracleDAC\odp.net\managed\common\Oracle.ManagedDataAccess.dll"

#############################
# Functions
#############################

# Initialize a database Connection, returns an open connection
function SetupConnection {
                Add-Type -Path $OracleMDAPath
                $connectionstring = 'User Id=' + $username + ';Password=' + $password + ';Data Source=' + $datasource 
                $con = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($connectionstring)
    $con.Open()
                Write-Host "Connection established"
                return $con
}

# Takes a connection and an SQL Query as string, 
# returns a reader object if the query could be executed
function ExecuteTextQuery {
                param(
				[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$false)]         
                [Oracle.ManagedDataAccess.Client.OracleConnection]$connection,
                [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$false)]             
                [string]$query
                )
                $reader = $false
                Write-Host "Executing Query: $($query)"
                $cmd = $connection.CreateCommand()
				$cmd.CommandType = "text"
				$cmd.CommandText = $query

				$reader = $cmd.ExecuteReader()
                #$result = $reader.GetDataTypeName(0)
                #$result = $reader.GetValue(5)
                return $reader
}

function CloseConnection {
                param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$false)]         
                [Oracle.ManagedDataAccess.Client.OracleConnection]$connection
                )
                $connection.Close()
                Write-Host "Connection closed"
}

#############################
# Script Entry
#############################

$connection = SetupConnection
$query = "SELECT * FROM ...."
ExecuteQuery $connection $query
CloseConnection $connection
