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
