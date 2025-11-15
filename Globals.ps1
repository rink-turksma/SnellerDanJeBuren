#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------


#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory

function Get-TomTomApiKey
{
	$regPath = 'HKCU:\Software\AlsEersteBijDePaal'
	$valueName = 'TomTomApiKey'
	
	if (-not (Test-Path -Path $regPath)) { return $null }
	
	$props = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
	if ($props -and $props.$valueName)
	{
		return $props.$valueName
	}
	else
	{
		return $null
	}
	
	
}
function refreshLaadPaal
{
	
		$folderPath = Join-Path $env:APPDATA 'SnellerDanJeBuren'
		$csvPath = Join-Path $folderPath 'config_SnellerDanJeBuren.csv'
		
		if (-not (Test-Path -Path $folderPath))
		{
			New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
		}
		
		if (Test-Path -Path $csvPath)
		{
		
		try
		{
			
			$TenantsCSV = Import-Csv $csvPath -ErrorAction Stop
			$treeview1.BeginUpdate()
			$treeview1.Refresh()
			$treeview1.Nodes.Clear()
			$Root = $treeview1.Nodes.Add("Laadpalen")
			foreach ($tenantCSV in $TenantsCSV)
			{
				
				$naam = $tenantCSV.Naam + ',' + $tenantCSV.Adres + "," + $tenantCSV.'Connectoren (statisch)'
				$node = $Root.Nodes.Add($naam)
		
				$node.Tag = $tenantCSV.Adres
				$node.Name = $naam
			
				
			}
			$Root.Expand()
			$treeview1.EndUpdate()
			
			
		}
		catch
		{
			
		}
		
	}
	
	
	
	
}
