<#
.SYNOPSIS
    Tests a ConnectionStrings from a local or remote machine
.DESCRIPTION
    The cmdlet takes a ConnectionString as an input object or as a direct
    parameter then it tries to connect to the database.

    If Initial Catalog is specified, it queries the server for the specified
    database otherwise it checks whether it can access the tempdb.

    If a Session Property is passed via InputObject or directly with -Session
    parameter, the ConnectionString test will be executed against it.

    If -ReplaceRules hashtable is specified it will replace hash-keys with it's
    values in the ConnectionString to be tested.

    Passwords in the ConnectionString are masked by default, use -ShowPassword
    switch if you need to show passwords in test-results.

.PARAMETER InputObject
    Mandatory - Pipeline input of PsConnectionString

.PARAMETER ConnectionString
    Mandatory - Parameter to pass a ConnectionString as a string

.PARAMETER ReplaceRules
    Optional - Hashtable that replaces hash-keys with it's values in the
    ConnectionString to be tested.

.PARAMETER ShowPassword
    Optional - Switch to disable password masking for the test result.

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
        [System.Management.Automation.Runspaces.PSSession[]]$Session,

        [switch]$ShowPassword
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

                $ArgumentList = $entry.ConnectionString,$ReplaceRules,$ShowPassword
                if ($EntrySession) {
                    Invoke-Command `
                        -Session $EntrySession `
                        -ArgumentList $ArgumentList `
                        -ScriptBlock $Function:Test_ConnectionString |
                    Add-Member -NotePropertyName Session -NotePropertyValue $EntrySession -Force -PassThru |
                    Set_Type -TypeName 'PSWebConfig.TestResult'
                } else {
                    Invoke-Command `
                        -ArgumentList $ArgumentList `
                        -ScriptBlock $Function:Test_ConnectionString |
                    Set_Type -TypeName 'PSWebConfig.TestResult'
                }
            } else {
                Write-Verbose "InputObject doesn't contain ConnectionString property"
            }
        }
    }
}
