function Test_ConnectionString {
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$ConnectionString,

        [Parameter(Position=1)]
        [hashtable]$ReplaceRules
    )

    $result = New-Object PsObject -Property @{
        ComputerName = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
        TestType='SqlTest'
        ConnectionString=$ConnectionString
        RawConnectionString=$ConnectionString
        SqlQuery= $null
        Result = $null
        Passed = $false
    }

    try {
        # Transform ConnectionString
        if ($ReplaceRules) {
            $ReplaceRules.GetEnumerator() | ForEach-Object {
                $result.ConnectionString = $result.ConnectionString -replace $_.Key,$_.Value
            }
        }

        # Figure target database to check
        $DbToCheck = 'tempdb'
        $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder $result.ConnectionString
        if ($builder.'Initial Catalog') {
            $DbToCheck = $builder.'Initial Catalog'
        }
        $result.SqlQuery="SELECT name FROM sysdatabases WHERE LOWER(name) = LOWER('$DbToCheck')"

        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection -ErrorAction Stop
        $SqlConnection.ConnectionString = $result.ConnectionString
        $SqlConnection.Open()

        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $result.SqlQuery
        $SqlCmd.Connection = $SqlConnection

        $result.Result = $SqlCmd.ExecuteScalar()
        $result.Passed = $true
    } catch {
        $result.Result = $_
        $result.Passed = $false
        Write-Error $_
    } finally {
        if ($SqlConnection) { $SqlConnection.Close() }
    }
    return $result
}
