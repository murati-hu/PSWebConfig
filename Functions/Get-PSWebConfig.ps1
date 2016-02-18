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
.PARAMETER ComputerName
    Optional - Parameter to query a target computer (Default is localhost)
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
        [string]$ComputerName='localhost',

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

        [string[]]$Sections = @('connectionStrings', 'appSettings', 'system.web')
    )
    process {
        if ($Path) {
            Write-Verbose "Processing by Path"
            $InputObject = New-Object -TypeName PsObject -Property @{
                ComputerName = $ComputerName
                physicalPath = $Path
            }
        }

        if ($InputObject) {
            Write-Verbose "Processing by InputObject"
            foreach ($site in $InputObject) {
                if (-NOT ($site | Get-Member -Name ComputerName)) {
                    $site = $site | Add-Member -NotePropertyName ComputerName -NotePropertyValue $ComputerName -PassThru
                }
                if (($site | Get-Member -Name physicalPath)) {
                    if ($site.ComputerName -ne 'localhost') {
                        Write-Verbose "Remote Invoke-Command to '$($i.ComputerName)'"
                        Invoke-Command `
                            -ComputerName $site.ComputerName `
                            -ArgumentList @($site.physicalPath, $Sections, $AsFileName, $AsText, $Recurse) `
                            -ScriptBlock ${function:Get_ConfigFile}
                    } else {
                        Write-Verbose "Local Invoke-Command"
                        Invoke-Command `
                            -ArgumentList @($site.physicalPath, $Sections, $AsFileName, $AsText, $Recurse) `
                            -ScriptBlock ${function:Get_ConfigFile}
                    }
                } else {
                    Write-Warning "Cannot get path from InputObject '$site'"
                }
            }
        }
    }
}
