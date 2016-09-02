function Set_Type {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [psobject[]]$InputObject,
        [string]$TypeName
    )
    process {
        foreach ($object in $InputObject) {
            if ($TypeName) {
                $object.psobject.TypeNames.Insert(0, $TypeName)
            }
            $object
        }
    }
}

function Invoke-SessionCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter()]
        [Object[]]$ArgumentList,

        [Parameter()]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    if ($Session) {
        Write-Verbose "Executing remotely from '$($Session.ComputerName)'.."
        Invoke-Command -Session $Session -ArgumentList $ArgumentList -ScriptBlock $ScriptBlock |
        Add-Member -NotePropertyName Session -NotePropertyValue $Session -Force -PassThru
    } else {
        Write-Verbose 'Executig locally..'
        Invoke-Command -ArgumentList $ArgumentList -ScriptBlock $ScriptBlock
    }
}
