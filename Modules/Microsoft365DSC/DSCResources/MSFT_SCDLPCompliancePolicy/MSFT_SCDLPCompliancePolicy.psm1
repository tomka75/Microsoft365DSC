function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOf,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOfException,

        [Parameter()]
        [ValidateSet('Enable', 'TestWithNotifications', 'TestWithoutNotifications', 'Disable', 'PendingDeletion')]
        [System.String]
        $Mode = 'Enable',

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.UInt32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $TeamsLocation,

        [Parameter()]
        [System.String[]]
        $TeamsLocationException,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )

    Write-Verbose -Message "Getting configuration of DLPCompliancePolicy for $Name"
    if ($Global:CurrentModeIsExport)
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
            -InboundParameters $PSBoundParameters `
            -SkipModuleReload $true
    }
    else
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
            -InboundParameters $PSBoundParameters
    }

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $nullReturn = $PSBoundParameters
    $nullReturn.Ensure = 'Absent'
    try
    {
        $PolicyObject = Get-DlpCompliancePolicy -Identity $Name -ErrorAction SilentlyContinue

        if ($null -eq $PolicyObject)
        {
            Write-Verbose -Message "DLPCompliancePolicy $($Name) does not exist."
            return $nullReturn
        }
        else
        {
            Write-Verbose "Found existing DLPCompliancePolicy $($Name)"

            $ExchangeSenderMemberOfValue = @()
            if ($null -ne $PolicyObject.ExchangeSenderMemberOf)
            {
                foreach ($member in $PolicyObject.ExchangeSenderMemberOf)
                {
                    $ExchangeSenderMemberOfValue += (ConvertFrom-JSON $member).PrimarySmtpAddress
                }
            }

            $ExchangeSenderMemberOfExceptionValue = @()
            if ($null -ne $PolicyObject.ExchangeSenderMemberOfException)
            {
                foreach ($member in $PolicyObject.ExchangeSenderMemberOfException)
                {
                    $ExchangeSenderMemberOfExceptionValue += (ConvertFrom-JSON $member).PrimarySmtpAddress
                }
            }

            $result = @{
                Ensure                          = 'Present'
                Name                            = $PolicyObject.Name
                Comment                         = $PolicyObject.Comment
                ExchangeLocation                = $PolicyObject.ExchangeLocation.Name
                ExchangeSenderMemberOf          = $ExchangeSenderMemberOfValue
                ExchangeSenderMemberOfException = $ExchangeSenderMemberOfExceptionValue
                Mode                            = $PolicyObject.Mode
                OneDriveLocation                = $PolicyObject.OneDriveLocation.Name
                OneDriveLocationException       = $PolicyObject.OneDriveLocationException
                Priority                        = $PolicyObject.Priority
                SharePointLocation              = $PolicyObject.SharePointLocation.Name
                SharePointLocationException     = $PolicyObject.SharePointLocationException
                TeamsLocation                   = $PolicyObject.TeamsLocation.Name
                TeamsLocationException          = $PolicyObject.TeamsLocationException
            }

            Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"
            return $result
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $nullReturn
    }
}

function Set-TargetResource
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOf,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOfException,

        [Parameter()]
        [ValidateSet('Enable', 'TestWithNotifications', 'TestWithoutNotifications', 'Disable', 'PendingDeletion')]
        [System.String]
        $Mode = 'Enable',

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.UInt32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $TeamsLocation,

        [Parameter()]
        [System.String[]]
        $TeamsLocationException,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )

    Write-Verbose -Message "Setting configuration of DLPCompliancePolicy for $Name"

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
        -InboundParameters $PSBoundParameters

    $CurrentPolicy = Get-TargetResource @PSBoundParameters

    if (('Present' -eq $Ensure) -and ('Absent' -eq $CurrentPolicy.Ensure))
    {
        $CreationParams = $PSBoundParameters
        $CreationParams.Remove('Credential')
        $CreationParams.Remove('Ensure')
        New-DLPCompliancePolicy @CreationParams
    }
    elseif (('Present' -eq $Ensure) -and ('Present' -eq $CurrentPolicy.Ensure))
    {
        $CreationParams = $PSBoundParameters
        $CreationParams.Remove('Credential')
        $CreationParams.Remove('Ensure')
        $CreationParams.Remove('Name')
        $CreationParams.Add('Identity', $Name)

        # SharePoint Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.SharePointLocation -or `
                $null -ne $SharePointLocation)
        {
            $ToBeRemoved = $CurrentPolicy.SharePointLocation | `
                Where-Object { $SharePointLocation -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveSharePointLocation', $ToBeRemoved)
            }

            $ToBeAdded = $SharePointLocation | `
                Where-Object { $CurrentPolicy.SharePointLocation -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddSharePointLocation', $ToBeAdded)
            }

            $CreationParams.Remove('SharePointLocation')
        }

        # Exchange Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.ExchangeLocation -or `
                $null -ne $ExchangeLocation)
        {
            $ToBeRemoved = $CurrentPolicy.ExchangeLocation | `
                Where-Object { $ExchangeLocation -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveExchangeLocation', $ToBeRemoved)
            }

            $ToBeAdded = $ExchangeLocation | `
                Where-Object { $CurrentPolicy.ExchangeLocation -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddExchangeLocation', $ToBeAdded)
            }

            $CreationParams.Remove('ExchangeLocation')
        }

        # OneDrive Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.OneDriveLocation -or `
                $null -ne $OneDriveLocation)
        {
            $ToBeRemoved = $CurrentPolicy.OneDriveLocation | `
                Where-Object { $OneDriveLocation -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveOneDriveLocation', $ToBeRemoved)
            }

            $ToBeAdded = $OneDriveLocation | `
                Where-Object { $CurrentPolicy.OneDriveLocation -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddOneDriveLocation', $ToBeAdded)
            }
            $CreationParams.Remove('OneDriveLocation')
        }

        # OneDrive Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.OneDriveLocationException -or `
                $null -ne $OneDriveLocationException)
        {
            $ToBeRemoved = $CurrentPolicy.OneDriveLocationException | `
                Where-Object { $OneDriveLocationException -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveOneDriveLocationException', $ToBeRemoved)
            }

            $ToBeAdded = $OneDriveLocationException | `
                Where-Object { $CurrentPolicy.OneDriveLocationException -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddOneDriveLocationException', $ToBeAdded)
            }
            $CreationParams.Remove('OneDriveLocationException')
        }

        # SharePoint Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.SharePointLocationException -or `
                $null -ne $SharePointLocationException)
        {
            $ToBeRemoved = $CurrentPolicy.SharePointLocationException | `
                Where-Object { $SharePointLocationException -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveSharePointLocationException', $ToBeRemoved)
            }

            $ToBeAdded = $SharePointLocationException | `
                Where-Object { $CurrentPolicy.SharePointLocationException -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddSharePointLocationException', $ToBeAdded)
            }
            $CreationParams.Remove('SharePointLocationException')
        }

        # Teams Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.TeamsLocation -or `
                $null -ne $TeamsLocation)
        {
            $ToBeRemoved = $CurrentPolicy.TeamsLocation | `
                Where-Object { $TeamsLocation -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveTeamsLocation', $ToBeRemoved)
            }

            $ToBeAdded = $TeamsLocation | `
                Where-Object { $CurrentPolicy.TeamsLocation -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddTeamsLocation', $ToBeAdded)
            }
            $CreationParams.Remove('TeamsLocation')
        }

        # Teams Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CurrentPolicy.TeamsLocationException -or `
                $null -ne $TeamsLocationException)
        {
            $ToBeRemoved = $CurrentPolicy.TeamsLocationException | `
                Where-Object { $TeamsLocationException -NotContains $_ }
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add('RemoveTeamsLocationException', $ToBeRemoved)
            }

            $ToBeAdded = $TeamsLocationException | `
                Where-Object { $CurrentPolicy.TeamsLocationException -NotContains $_ }
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add('AddTeamsLocationException', $ToBeAdded)
            }
            $CreationParams.Remove('TeamsLocationException')
        }
        Write-Verbose "Updating Policy with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
        Set-DLPCompliancePolicy @CreationParams
    }
    elseif (('Absent' -eq $Ensure) -and ('Present' -eq $CurrentPolicy.Ensure))
    {
        # If the Policy exists and it shouldn't, simply remove it;
        try
        {
            $policy = Get-DlpCompliancePolicy -Identity $Name -ErrorAction SilentlyContinue
            if ($policy.Mode.ToString() -ne 'PendingDeletion')
            {
                Remove-DLPCompliancePolicy -Identity $Name
            }
            else
            {
                Write-Verbose -Message "Policy $Name is already in the process of being deleted."
            }
        }
        catch
        {
            New-M365DSCLogEntry  -Message $_ `
                -Exception $_ `
                -Source $MyInvocation.MyCommand.ModuleName
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOf,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOfException,

        [Parameter()]
        [ValidateSet('Enable', 'TestWithNotifications', 'TestWithoutNotifications', 'Disable', 'PendingDeletion')]
        [System.String]
        $Mode = 'Enable',

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.UInt32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $TeamsLocation,

        [Parameter()]
        [System.String[]]
        $TeamsLocationException,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )
    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message "Testing configuration of DLPCompliancePolicy for $Name"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('Credential') | Out-Null

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )
    $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
        -InboundParameters $PSBoundParameters `
        -SkipModuleReload $true

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        [array] $policies = Get-DLPCompliancePolicy -ErrorAction Stop | Where-Object -FilterScript { $_.Mode -ne 'PendingDeletion' }

        $i = 1
        $dscContent = ''
        if ($policies.Length -eq 0)
        {
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        else
        {
            Write-Host "`r`n" -NoNewline
        }
        foreach ($policy in $policies)
        {
            Write-Host "    |---[$i/$($policies.Count)] $($policy.Name)" -NoNewline
            $Results = Get-TargetResource @PSBoundParameters -Name $policy.Name
            $Results = Update-M365DSCExportAuthenticationResults -ConnectionMode $ConnectionMode `
                -Results $Results
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
            Write-Host $Global:M365DSCEmojiGreenCheckmark
        }
        return $dscContent
    }
    catch
    {
        Write-Host $Global:M365DSCEmojiRedX

        New-M365DSCLogEntry -Message 'Error during Export:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return ''
    }
}

Export-ModuleMember -Function *-TargetResource
