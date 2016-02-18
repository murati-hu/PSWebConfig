<#
.SYNOPSIS
    Tests a ConnectionStrings from a local or remote machine
.DESCRIPTION
    The cmdlet takes a ConnectionString as an input object or as a direct
    parameter then it tries to connect to the database.

    If Initial Catalog is specified it queries the server for the specified
    database otherwise it checks whether it can access the tempdb.

    If a Session Property is passed via InputObject or directly with -Session
    parameter, the ConnectionString test will be executed against it.

    If -ReplaceRules hashtable is specified it will replace hash-keys with it's
    values in the ConnectionString to be tested.

.PARAMETER InputObject
    Mandatory - Pipeline input of PsConnectionString

.PARAMETER ConnectionString
    Mandatory - Parameter to pass a ConnectionString as a string

.PARAMETER ReplaceRules
    Optional - Hashtable that replaces hash-keys with it's values in the
    ConnectionString to be tested.

.PARAMETER Session
    Optional - PSSession to execute the test-against it.

.EXAMPLE
    Test-PSConnectionString -ConnectionString 'Server=address;Database=db;User Id=uname;Password=***;'
.EXAMPLE
    Get-WebSite mysite | Get-PSWebConfig | Get-PSConnectionString | Test-PSConnectionString
#>
function Test-PSConnectionString {
    [CmdletBinding(DefaultParameterSetName='InputObject')]
    param(
        [Parameter(ParameterSetName="InputObject",ValueFromPipeLine=$true)]
        [psobject[]]$InputObject,

        [Parameter(ParameterSetName="ConnectionString",ValueFromPipeLine=$true)]
        [string]$ConnectionString,

        [hashtable]$ReplaceRules,
        [System.Management.Automation.Runspaces.PSSession[]]$Session
    )

    process {
        if ($ConnectionString) {
            $InputObject =  New-Object -TypeName PsObject -Property @{
                ConnectionString = $ConnectionString
                Session = $Session
            }
        }

        foreach ($entry in $InputObject) {
            if ($entry | Get-Member -Name ConnectionString) {

                $EntrySession = $entry.Session
                if ($Session) { $EntrySession = $Session }

                if ($EntrySession) {
                    Invoke-Command `
                        -Session $EntrySession `
                        -ArgumentList $entry.ConnectionString,$ReplaceRules `
                        -ScriptBlock $Function:Test_ConnectionString
                } else {
                    Invoke-Command `
                        -ArgumentList $entry.ConnectionString,$ReplaceRules `
                        -ScriptBlock $Function:Test_ConnectionString
                }
            } else {
                Write-Verbose "InputObject doesn't contain ConnectionString property"
            }
        }
    }
}
