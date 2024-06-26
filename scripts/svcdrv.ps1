using namespace System.Collections.Generic
using namespace System.ServiceProcess
using namespace System.Diagnostics
using namespace System.Runtime.InteropServices
using namespace System.ComponentModel

enum ServiceControllerExType {
    Driver  = 0x1
    Service = 0x2
}
class ServiceControllerEx {
    [ServiceControllerExType] $Type
    [ServiceType] $ServiceType
    [string] $ServiceName
    [string] $DisplayName
    [string] $Description
    [ServiceControllerStatus] $Status
    [Nullable[ServiceStartMode]] $StartType
    [Nullable[bool]] $DelayedAutoStart # Win32_Service
    [string] $UserName
    [ServiceControllerEx[]] $RequiredServices
    [ServiceControllerEx[]] $DependentServices
    hidden [ServiceController[]] $scRequiredServices
    hidden [ServiceController[]] $scDependentServices
    [string] $Path  # Win32_Service/SystemDriver
    [bool] $CanPauseAndContinue
    [bool] $CanShutdown
    [bool] $CanStop
    [string] $ErrorControl # Win32_Service/SystemDriver
    hidden [Nullable[uint32]] $ProcessId # Win32_Service
    [Process] $Process
    [SafeHandle] $ServiceHandle
    [ISite] $Site
    [IContainer] $Container

    #Win32_SystemDriver:
    [Nullable[datetime]] $InstallDate
    [Nullable[bool]] $DesktopInteract
    [Win32Exception] $ExitCode
    [Nullable[UInt32]] $ServiceSpecificExitCode
    [Nullable[UInt32]] $TagId

    # addtiionally from Win32_Service
    [Nullable[uint32]] $CheckPoint
    [Nullable[uint32]] $WaitHint

    # less important properties
    [string] $MachineName
    [string] $HostName
    [string] $HostDomain
}

class ServiceControllerExService : ServiceControllerEx {}
class ServiceControllerExDriver : ServiceControllerEx {}

function Get-ServiceEx {
    [CmdletBinding(DefaultParameterSetName='ServiceName')]
    param(
        # Parameter help description
        [Parameter(ParameterSetName='ServiceName', Position=0)]
        [Parameter(ParameterSetName='ProcessId', Position=0)]
        [Parameter(ParameterSetName='ProcessName', Position=0)]
        [SupportsWildcards()]
        [string[]]
        $Name,

        # Parameter help description
        [Parameter(ParameterSetName='ProcessId')]
        [uint32[]]
        $ProcessId,

        # Parameter help description
        [Parameter(ParameterSetName='ProcessName')]
        [SupportsWildcards()]
        [string[]]
        $ProcessName,

        # Parameter help description
        [Parameter()]
        [ServiceControllerExType[]]
        $Type = ('Service', 'Driver'),

        # Parameter help description
        [Parameter()]
        [switch]
        $HasError
    )

    begin {
        $cimComputerSystem = Get-CimInstance Win32_ComputerSystem -Property Domain, DNSHostName
        $hostDomain        = $cimComputerSystem.Domain
        $hostDnsName       = $cimComputerSystem.DNSHostName

        $processDict = [Dictionary[UInt32, Process]]::new()
        foreach ($process in (Get-Process)) {
            $process.psobject.Methods.add(
                [psscriptmethod]::new('ToString', { '{0} ({1})' -f $this.ProcessName, $this.ID })
            )

            $processDict[$process.ID] = $process
        }

        $servicesAndDriversDict = [Dictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)

        # non-device driver and OS services
        foreach ($service in [ServiceController]::GetServices()) {
            $serviceEx = [ServiceControllerExService]@{
                Type                = [ServiceControllerExType]::Service
                HostName            = $hostDnsName
                HostDomain          = $hostDomain
                ServiceName         = $service.ServiceName
                DisplayName         = $service.DisplayName
                Status              = $service.Status
                scRequiredServices  = $service.RequiredServices
                scDependentServices = $service.DependentServices
                CanPauseAndContinue = $service.CanPauseAndContinue
                CanShutdown         = $service.CanShutdown
                CanStop             = $service.CanStop
                MachineName         = $service.MachineName
                StartType           = $service.StartType
                ServiceType         = $service.ServiceType
                ServiceHandle       = $service.ServiceHandle
                Site                = $service.Site
                Container           = $service.Container
            }

            $servicesAndDriversDict.Add($serviceEx.ServiceName, $serviceEx)
        }

        # device-driver services
        foreach ($driver in [ServiceController]::GetDevices()) {
            $driverEx = [ServiceControllerExDriver]@{
                Type                = [ServiceControllerExType]::Driver
                HostName            = $hostDnsName
                HostDomain          = $hostDomain
                ServiceName         = $driver.ServiceName
                DisplayName         = $driver.DisplayName
                Status              = $driver.Status
                scRequiredServices  = $driver.RequiredServices
                scDependentServices = $driver.DependentServices
                CanPauseAndContinue = $driver.CanPauseAndContinue
                CanShutdown         = $driver.CanShutdown
                CanStop             = $driver.CanStop
                MachineName         = $driver.MachineName
                StartType           = $driver.StartType
                ServiceType         = $driver.ServiceType
                ServiceHandle       = $driver.ServiceHandle
                Site                = $driver.Site
                Container           = $driver.Container
            }

            $servicesAndDriversDict.Add($driverEx.ServiceName, $driverEx)
        }

        $win32Services      = Get-CimInstance -ClassName Win32_Service
        $win32SystemDrivers = Get-CimInstance -ClassName Win32_SystemDriver

        foreach ($win32Service in $win32Services) {
            $win32ServiceName = $win32Service.Name
            $service          = $servicesAndDriversDict[$win32ServiceName]

            if ($null -ne $service) {
                $service.InstallDate             = $win32Service.InstallDate -as [datetime]
                $service.DesktopInteract         = $win32Service.DesktopInteract
                $service.Description             = $win32Service.Description
                $service.ErrorControl            = $win32Service.ErrorControl
                $service.ExitCode                = $win32Service.ExitCode -as [int]
                $service.Path                    = $win32Service.PathName
                $service.ServiceSpecificExitCode = $win32Service.ServiceSpecificExitCode
                $service.UserName                = $win32Service.StartName
                $service.TagId                   = $win32Service.TagId
                $service.CheckPoint              = $win32Service.CheckPoint
                $service.DelayedAutoStart        = $win32Service.DelayedAutoStart
                # with if clause to avoid assigning the idle process (0)
                $service.ProcessId               = if ($win32Service.ProcessId) { $win32Service.ProcessId };
                $service.WaitHint                = $win32Service.WaitHint
            } else {
                # this should never happen, but can be important to know.
                Write-Warning "No service found for Win32_Service '$win32ServiceName'!"
            }
        }

        foreach ($win32Device in $win32SystemDrivers) {
            $win32DeviceName = $win32Device.Name
            $service         = $servicesAndDriversDict[$win32DeviceName]

            if ($null -ne $service) {
                $service.InstallDate             = $win32Device.InstallDate
                $service.DesktopInteract         = $win32Device.DesktopInteract
                $service.Description             = $win32Device.Description
                $service.ErrorControl            = $win32Device.ErrorControl
                $service.ExitCode                = $win32Device.ExitCode -as [int]
                $service.Path                    = $win32Device.PathName
                $service.ServiceSpecificExitCode = $win32Device.ServiceSpecificExitCode
                $service.UserName                = $win32Device.StartName
                $service.TagId                   = $win32Device.TagId
                $service.CheckPoint              = $win32Device.CheckPoint
                $service.DelayedAutoStart        = $win32Device.DelayedAutoStart
                $service.ProcessId               = $win32Device.ProcessId
                $service.WaitHint                = $win32Device.WaitHint
            } else {
                # this should never happen, but can be important to know.
                Write-Warning "No service found for Win32_SystemDriver '$win32DeviceName'!"
            }
        }

        foreach ($item in $servicesAndDriversDict.GetEnumerator()) {
            $value = $item.Value

            if ($value.scRequiredServices.Count) {
                $value.RequiredServices = foreach ($scRequiredService in $value.scRequiredServices) {
                    $serviceName = [string] $scRequiredService.ServiceName
                    $servicesAndDriversDict[$serviceName]
                }
            }

            if ($value.scDependentServices.Count) {
                $value.DependentServices = foreach ($scDependentService in $value.scDependentServices) {
                    $serviceName = [string] $scDependentService.ServiceName
                    $servicesAndDriversDict[$serviceName]
                }
            }

            if ($null -ne $value.ProcessId) {
                $value.Process = $processDict[$value.ProcessId]
            }
        }

        $servicesAndDrivers = [ServiceControllerEx[]]$servicesAndDriversDict.Values
    }

    process {
        if ($Type.Count) {
            $servicesAndDrivers = $servicesAndDrivers.Where{ $_.Type -in $Type }
        }

        if ($Name.Count) {
            $servicesAndDrivers = foreach ($service in $servicesAndDrivers) {
                foreach ($nameItem in $Name) {
                    if ($service.ServiceName -like $nameItem -or
                        $service.DisplayName -like $nameItem -or
                        $service.Description -like $nameItem -or
                        $service.Path -like $nameItem) {
                        $service
                    }
                }
            }
        }

        if ($HasError) {
            # 0 = "Success" ; 1077 = "No attempts to start the service has been made since the last boot"
            $servicesAndDrivers = $servicesAndDrivers.Where{ $_.ExitCode.NativeErrorCode -notin $null, 0, 1077 }
        }

        if ($ProcessId.Count) {
            $servicesAndDrivers = $servicesAndDrivers.Where{ $_.Process.Id -in $ProcessId }

        } elseif ($ProcessName.Count) {
            $servicesAndDrivers = foreach ($service in $servicesAndDrivers) {
                foreach ($nameItem in $ProcessName) {
                    if ($service.Process.ProcessName -like $nameItem) {
                        $service
                    }
                }
            }
        }

        $servicesAndDrivers | Out-GridView -PassThru -Title 'Services/Drivers Script by Carpel'
    }
}

# Call the function to execute the script logic
Get-ServiceEx
