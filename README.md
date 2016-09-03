PSWebConfig PowerShell module
==========================

[![Build status](https://ci.appveyor.com/api/projects/status/4tcovid4e04m1vdx?svg=true)](https://ci.appveyor.com/project/muratiakos/pswebconfig)

PSWebConfig is a PowerShell module that provides an easy way to automatically decrypt,
inspect and test web.config or any .NET based application configuration files both
locally or remotely.

## Installation
PSWebConfig is available via [PowerShell Gallery][PowerShellGallery] or [PsGet][psget],
so you can simply install it with the following command:
```powershell
Install-Module PSWebConfig

# Or alternatevely you can install it with PsGet from this repository
Install-Module -ModuleUrl https://github.com/murati-hu/PSWebConfig/archive/master.zip
```
Of course you can download and install the module manually too from
[Downloads][download]

## Usage
```powershell
Import-Module PSWebConfig
```

## Examples
### View and decrypt a web.config
`Get-PSWebConfig` cmdlet automatically fetches and decrypts any web.config
file both locally and remotely without altering the actual config file on the
target computer:
```powershell
# Pipe any site into Get-PSWebConfig to show the decrypted config
Get-Website | Get-PSWebConfig -AsText

# You can use -Path attribute to find web.config files
Get-PSWebConfig -Path C:\inetpub\wwwroot\

# If you wish to override the config with its decrypted version
Get-Website | Decrypt-PSWebConfig -Confirm $false
```
### Test config files
`Test-PSWebConfig` function  allows complete tests on all connectionStrings and
Service addresses from a configuration both on local or remote computers.
```powershell
# Pipe a config into Test-PSWebConfig
Get-Website * | Test-PSWebConfig

# Or use -Session to test it via remote PSSession
$server1 = New-PSSession 'server1.local.domain'
Get-PSWebConfig -Path C:\inetpub\wwwroot\ -Session $server1 | Test-PSWebConfig
```

### Inspect ConnectionStrings
```powershell
# Pipe Get-PSWebConfig into Get-PSConnectionString to get decrypted connectionstrings
Get-Website * | Get-PSWebConfig | Get-PSConnectionString

# You can also use -IncludeAppSettings to find connectionstrings from appSetting section
Get-PSWebConfig -Path C:\inetpub\wwwroot\ | Get-PSConnectionString -IncludeAppSettings
```

### Test ConnectionStrings
`Test-PSConnectionString` cmdlet tries to initiate a SQL connection from a local or
remote computer to test if there are any issue connection to a database.
```powershell
# Pipe Get-PSConnectionString to Test-PSConnectionString
Get-Website * | Get-PSWebConfig | Get-PSConnectionString -Inc | Test-PSConnectionString

# You can also transform the connectionString with regex -ReplaceRules hashtable
Test-PSConnectionString -Conn "Server=dbserver.local;Database=##TARGET_DB##" -ReplaceRules @{ '##TARGET_DB##'='myDb'}
```

### Inspect appSettings
```powershell
# Pipe Get-PSWebConfig into Get-PSAppSetting to get decrypted appSettings
Get-Website * | Get-PSWebConfig | Get-PSAppSetting
```

### Get service endpoints and URIs
```powershell
# Pipe Get-PSWebConfig into Get-PSEndpoint to get decrypted webservice addresses
Get-Website * | Get-PSWebConfig | Get-PSEndpoint

# Or pipe Get-PSWebConfig into Get-PSUri to get URLs from appSettings too.
Get-Website * | Get-PSWebConfig | Get-PSUri
```

Call `help` on any of the PSWebConfig cmdlets for more information and examples.

## Documentation
Cmdlets and functions for PSWebConfig have their own help PowerShell help, which
you can read with `help <cmdlet-name>`.

## Versioning
PSWebConfig aims to adhere to [Semantic Versioning 2.0.0][semver].

## Issues
In case of any issues, raise an [issue ticket][issues] in this repository and/or
feel free to contribute to this project if you have a possible fix for it.

## Development
* Source hosted at [Github.com][repo]
* Report issues/questions/feature requests on [Github Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the [repo][repo]
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors
Created and maintained by [Akos Murati][muratiakos] (<akos@murati.hu>).

## License
Apache License, Version 2.0 (see [LICENSE][LICENSE])

[repo]: https://github.com/murati-hu/PsWebConfig
[issues]: https://github.com/murati-hu/PsWebConfig/issues
[muratiakos]: http://murati.hu
[license]: LICENSE
[semver]: http://semver.org/
[psget]: http://psget.net/
[PowerShellGallery]: https://www.powershellgallery.com/packages/PSWebConfig
[download]: https://github.com/murati-hu/PSWebConfig/archive/master.zip
