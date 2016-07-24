<#
.SYNOPSIS
    Tests all URI and ConnectionStrings from web or application configuration.

.DESCRIPTION
    The cmdlet fetches all ConnectionString and service endpoint URIs
    from a configuration xml and executes a test against them on a
    local or remote machine.

    If -IncludeAppSettings switch is defined, it will include any URI or
    ConnectionStrings to the tests.

.PARAMETER InputObject
    Mandatory - Parameter to pass a PSWebConfig object

.PARAMETER Session
    Optional - PSSession to execute configuration test

.PARAMETER IncludeAppSettings
    Optional - Switch to include URIs and ConnectionStrings from appSettings
    sections

.EXAMPLE
    Get-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\' | Test-PSWebConfig

.EXAMPLE
    Get-WebSite | Get-PSWebConfig -Recurse | Test-PSWebConfig
#>
function Test-PSWebConfig {
    [CmdletBinding(DefaultParameterSetName="FromPipeLine")]
    param(
        [Parameter(
            ParameterSetName="FromPipeLine",
            ValueFromPipeLine=$true,
            Position=0,
            Mandatory=$true)]
        [psobject[]]$ConfigXml,

        [switch]$IncludeAppSettings,
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    process {
        Write-Verbose "Executing Test-PSWebConfig"

        if (-Not $ConfigXml.configuration) {
            Write-Verbose "InputObject is not a valid XML configuration, trying to get config XML."
            $ConfigXml = Get-PSWebConfig -InputObject $ConfigXml
        }

        Get-PSUri -ConfigXml $ConfigXml -IncludeAppSettings:$IncludeAppSettings |
        Test-PSUri -Session $Session

        Get-PSConnectionString -ConfigXml $ConfigXml -IncludeAppSettings:$IncludeAppSettings |
        Test-PSConnectionString -Session $Session
    }
}
