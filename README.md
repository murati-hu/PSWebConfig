PSWebConfig PowerShell module
==========================

PSWebConfig is a PowerShell module that provides an easy way to decrypt and
inspect web.config or application configuration files locally or remotely.

## Installation
PSWebConfig is available via [PsGet][psget], so you can simply install it with the
following command:
```powershell
# Install it from PsGet
Install-Module PSWebConfig

# Or install it from this repository
Install-Module -ModuleUrl https://github.com/muratiakos/PSWebConfig/archive/master.zip
```
Of course you can download and install the module manually too from
[Downloads][download]

## Usage
```powershell
Import-Module PSWebConfig
```

## Examples
### Decrypt web.config
```powershell
# You can pipe any site into Get-PSWebConfig
Get-Website * | Get-PSWebConfig -AsText

# You can use -Path attribute to find web.config files
Get-PSWebConfig -Path C:\inetpub\wwwroot\
```

### Inspect ConnectionStrings
```powershell
# Pipe Get-PSWebConfig into Get-PSConnectionString to get decrypted connectionstrings
Get-Website * | Get-PSWebConfig | Get-PSConnectionString

# You can also use -IncludeAppSettings to fing connectionstrings from appSetting section
Get-PSWebConfig -Path C:\inetpub\wwwroot\ | Get-PSConnectionString -IncludeAppSettings
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

[repo]: https://github.com/muratiakos/PSWebConfig
[issues]: https://github.com/muratiakos/PSWebConfig/issues
[muratiakos]: http://murati.hu
[license]: LICENSE
[semver]: http://semver.org/
[psget]: http://psget.net/
[download]: https://github.com/muratiakos/PSWebConfig/archive/master.zip
