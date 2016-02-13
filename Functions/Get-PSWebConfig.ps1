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
        [switch]$Recurse
    )
    process {
        if ($Path) {
            Write-Verbose "Processing by Path"
            $InputObject = New-Object -TypeName PsObject -Property @{ComputerName = $ComputerName; physicalPath=$Path }
        }

        if ($InputObject) {
            Write-Verbose "Processing by InputObject"
            foreach ($i in $InputObject) {
                if (($i | Get-Member -Name physicalPath) -and ($i | Get-Member -Name ComputerName)) {
                    Invoke-Command -ComputerName $i.ComputerName -ArgumentList $i.physicalPath,(-NOT $AsFileName),$AsText,$IncludeHeader,$Recurse,$VerbosePreference -ScriptBlock ${function:Read-AppConfig} -EnableNetworkAccess
                } else {
                    Write-Warning "Cannot figure folder from InputObject '$i'"
                }
            }
        }
    }
}
