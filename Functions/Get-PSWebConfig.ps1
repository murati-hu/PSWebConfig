<#
.SYNOPSIS
    Returns a decrypted configurations from websites or applications
.DESCRIPTION
    The cmdlet finds the relevant web and app configs for the passed applications
    or websites and returns it in an XML/Text or File list format.

    It accepts either Path or an InputObject to discover the configuration files
    and if -Recurse is specified it discovers all sub-configuration too.

.PARAMETER InputObject
    Mandatory - Parameter to pass the Application or WebSite from pipeline
.PARAMETER Path
    Mandatory - Parameter to pass the path for the target application
.PARAMETER Recurse
    Optional - Switch to look for multiple web.config files in sub-folders for
    web applications
.PARAMETER Session
    Optional - PSSession to execute configuration file lookup
.PARAMETER AsXml
    Optional - Switch to return configuration as an unencypted and parsed
    XML object output (default behavior)
.PARAMETER AsText
    Optional - Switch to return configfiles as unencrypted plain text output
.PARAMETER AsFileName
    Optional - Switch to return found configfile names as an output
.PARAMETER Sections
    Optional - List of configuration sections to be decrypted

.EXAMPLE
    Get-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\'
.EXAMPLE
    Get-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\' -ComputerName 'server1.local.domain'
.EXAMPLE
    Get-WebSite | Get-PSWebConfig -AsText -Recurse
#>
function Get-PSWebConfig {
    [CmdletBinding(DefaultParameterSetName="FromPipeLine")]
    param(
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ValueFromPipeLine=$true)]
        [psobject[]]$InputObject,

        [Parameter(ParameterSetName="FromPath",Mandatory=$true)]
        [Alias('physicalPath')]
        [string]$Path,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsFileName")]
        [switch]$AsFileName,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsText")]
        [switch]$AsText,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsText")]
        [switch]$IncludeHeader,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsXml")]
        [switch]$AsXml,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsXml")]
        [switch]$Recurse,

        [string[]]$Sections = @('connectionStrings', 'appSettings', 'system.web'),

        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    process {
        if ($Path) {
            Write-Verbose "Processing by Path"
            $InputObject = New-Object -TypeName PsObject -Property @{
                physicalPath = $Path
                Session = $Session
            }
        }

        if ($InputObject) {
            Write-Verbose "Processing by InputObject"
            foreach ($entry in $InputObject) {
                if (($entry | Get-Member -Name physicalPath)) {
                    $EntrySession = $entry.Session
                    if ($Session) { $EntrySession = $Session }

                    if ($EntrySession) {
                        Write-Verbose "Remote Invoke-Command to '$($EntrySession.ComputerName)'"
                        Invoke-Command `
                            -Session $EntrySession `
                            -ArgumentList @($entry.physicalPath, $Sections, $AsFileName, $AsText, $Recurse) `
                            -ScriptBlock ${function:Get_ConfigFile} |
                        Add-Member -NotePropertyName Session -NotePropertyValue $EntrySession -Force -PassThru |
                        Set_Type -TypeName "PSWebConfig.WebConfig"
                    } else {
                        Write-Verbose "Local Invoke-Command"
                        Invoke-Command `
                            -ArgumentList @($entry.physicalPath, $Sections, $AsFileName, $AsText, $Recurse) `
                            -ScriptBlock ${function:Get_ConfigFile} |
                        Set_Type -TypeName "PSWebConfig.WebConfig"
                    }
                } else {
                    Write-Warning "Cannot get path from InputObject '$entry'"
                }
            }
        }
    }
}
