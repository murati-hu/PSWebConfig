<#
.SYNOPSIS
    Returns a decrypted configurations from websites or applications
.DESCRIPTION
    The cmdlet finds the relevant web and app configs for the passed applications
    or websites and returns it in an XML/Text or File list format.

    It accepts either Path or an InputObject to discover the configuration files
    and if -Recurse is specified it discovers all sub-configuration too.

    Remote configurations can be fetched by setting -Session parameter.

    If the input object is received from a PSSession instance, it will try to
    use the session's InstanceId to fetch the configuration remotely.

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
.PARAMETER AsFile
    Optional - Switch to return found configfile names as an output

.EXAMPLE
    Get-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\'
.EXAMPLE
    $server1 = New-PSSession 'server1.local.domain'
    Get-PSWebConfig -Path 'c:\intepub\wwwroot\testapp\' -Session $server1
.EXAMPLE
    Get-WebSite | Get-PSWebConfig -AsText -Recurse
#>
function Get-PSWebConfig {
    [CmdletBinding(DefaultParameterSetName="FromPipeLine")]
    param(
        [Parameter(ParameterSetName="FromPipeLine",Position=0)]
        [Parameter(ValueFromPipeLine=$true)]
        [psobject[]]$InputObject,

        [Parameter(ParameterSetName="FromPath",Position=0,Mandatory=$true)]
        [Alias('physicalPath')]
        [string]$Path,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsFileInfo")]
        [switch]$AsFileInfo,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsText")]
        [switch]$AsText,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsXml")]
        [switch]$AsXml,

        [Parameter(ParameterSetName="FromPath")]
        [Parameter(ParameterSetName="FromPipeLine")]
        [Parameter(ParameterSetName="AsXml")]
        [switch]$Recurse,

        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    process {
        Write-Verbose "Executing Get-PSWebConfig"
        if (!$AsText -and !$AsFileInfo) {
            Write-Verbose "Defaulting output-format to XML object"
            $AsXml = $true
        }

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
                # Setting Remote Session
                $EntrySession = $entry.Session
                if ($Session) {
                    Write-Verbose "Overriding session from -Session Parameter"
                    $EntrySession = $Session
                }
                elseif ($entry | Get-Member -Name RunspaceId) {
                    Write-Verbose "Getting Session from RunspaceId '$($entry.RunspaceId)'"
                    $EntrySession = Get-PSSession -InstanceId $entry.RunspaceId
                }

                if ($entry -is [System.IO.FileInfo] -or $entry.psobject.TypeNames -icontains 'Deserialized.System.IO.FileInfo') {
                    Write-Verbose "Adding physicalPath alias for [System.IO.FileInfo] FullName"
                    $entry = $entry | Add-Member -MemberType AliasProperty -Name physicalPath -Value FullName -PassThru
                }

                if ($entry | Get-Member -Name physicalPath) {
                    if ($EntrySession) {
                        Write-Verbose "Remote configuration fetch from '$($EntrySession.ComputerName + " " + $entry.physicalPath)'"
                        $response = Invoke-Command `
                            -Session $EntrySession `
                            -ArgumentList @($entry.physicalPath, $AsFileInfo, $AsText, $Recurse) `
                            -ScriptBlock ${function:Get_ConfigFile} |
                        Add-Member -NotePropertyName Session -NotePropertyValue $EntrySession -Force -PassThru
                    } else {
                        Write-Verbose "Local configuration fetch from '$($entry.physicalPath)'"
                        $response = Invoke-Command `
                            -ArgumentList @($entry.physicalPath, $AsFileInfo, $AsText, $Recurse) `
                            -ScriptBlock ${function:Get_ConfigFile}
                    }

                    if ($AsXml) {
                        $response | Set_Type -TypeName "PSWebConfig.WebConfig"
                    } else {
                        $response
                    }
                } else {
                    Write-Warning "Cannot get path from InputObject '$entry'"
                }
            }
        }
    }
}
