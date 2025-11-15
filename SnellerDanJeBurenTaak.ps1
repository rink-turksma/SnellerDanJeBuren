<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2025 v5.9.259
	 Created on:   	15-11-2025 19:35
	 Created by:   	Rink Turksma
	 Filename:     	SnellerDanJeBuren.ps1
	===========================================================================
	.DESCRIPTION
		Check TomTom voor laadpalen en toon alleen een popup als er een paal vrij is.
		Met -Debug ook een popup als er géén vrije palen zijn.
#>

[int]$MaxStations = 8
$ErrorActionPreference = "Stop"

try
{
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
catch { }

function Get-TomTomApiKeyFromRegistry
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

# Als er geen key als parameter is meegegeven: probeer registry
if (-not $TomTomApiKey)
{
	$TomTomApiKey = Get-TomTomApiKeyFromRegistry
	if (-not $TomTomApiKey)
	{
		throw "TomTom API key niet gevonden in HKCU:\Software\AlsEersteBijDePaal (TomTomApiKey) en niet meegegeven via -TomTomApiKey."
	}
}

function Invoke-TomTom
{
	param ([string]$Url)
	try
	{
		Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 20
	}
	catch
	{
		throw "TomTom API-fout bij $Url : $($_.Exception.Message)"
	}
}

# CSV-locatie
$folderPath = Join-Path $env:APPDATA 'SnellerDanJeBuren'
$csvPath = Join-Path $folderPath 'config_SnellerDanJeBuren.csv'

if (-not (Test-Path $csvPath))
{
	throw "CSV-bestand niet gevonden: $csvPath"
}

$csvData = Import-Csv $csvPath

# Mapping voor nette connector-namen
$connectorNames = @{
	"IEC62196Type2Outlet"	     = "Type 2 (socket)"
	"IEC62196Type2CableAttached" = "Type 2 (kabel)"
	"IEC62196CCS2"			     = "CCS2 (Combo)"
	"Chademo"				     = "CHAdeMO"
	"TeslaConnector"			 = "Tesla"
	"IEC62196Type1"			     = "Type 1"
}

$resultRows = @()

foreach ($row in $csvData)
{
	
	if (-not $row.Adres) { continue }
	
	# Volledig adres uit CSV gebruiken voor geocoding
	$adresQuery = "$($row.Adres), NL"
	
	# 1) Geocodeer adres -> lat/lon
	$geoUrl = "https://api.tomtom.com/search/2/geocode/$([uri]::EscapeDataString($adresQuery)).json?key=$TomTomApiKey&limit=1&countrySet=NL"
	$geo = Invoke-TomTom $geoUrl
	
	$lat = $null
	$lon = $null
	if ($geo.results -and $geo.results[0] -and $geo.results[0].position)
	{
		$lat = $geo.results[0].position.lat
		$lon = $geo.results[0].position.lon
	}
	
	$staticConnectors = @()
	$availSummary = "Geen live data"
	$hasFree = $false # bijhouden of er iets vrij is
	
	if ($lat -and $lon)
	{
		# 2) Zoek EV-stations in de buurt van dit adres
		$catUrl = "https://api.tomtom.com/search/2/categorySearch/electric%20vehicle%20station.json?key=$TomTomApiKey&lat=$lat&lon=$lon&radius=400&limit=25&countrySet=NL"
		$cat = Invoke-TomTom $catUrl
		
		$nearest = $null
		if ($cat.results)
		{
			# Neem het dichtstbijzijnde laadpunt
			$nearest = $cat.results |
			Sort-Object { if ($_.dist) { [double]$_.dist }
				else { [double]::PositiveInfinity } } |
			Select-Object -First 1
		}
		
		if ($nearest)
		{
			# Statische connectoren van TomTom
			if ($nearest.chargingPark -and $nearest.chargingPark.connectors)
			{
				foreach ($c in $nearest.chargingPark.connectors)
				{
					if (-not $c) { continue }
					$label = if ($connectorNames.ContainsKey($c.connectorType))
					{
						$connectorNames[$c.connectorType]
					}
					else
					{
						$c.connectorType
					}
					if ($c.ratedPowerKW) { $label = "$label $($c.ratedPowerKW)kW" }
					$staticConnectors += $label
				}
			}
			
			# Live availability via chargingAvailability.id
			$chargingId = $null
			if ($nearest.dataSources -and $nearest.dataSources.chargingAvailability)
			{
				$chargingId = $nearest.dataSources.chargingAvailability.id
			}
			
			if ($chargingId)
			{
				$availUrl = "https://api.tomtom.com/search/2/chargingAvailability.json?key=$TomTomApiKey&chargingAvailability=$chargingId"
				try
				{
					$avail = Invoke-TomTom $availUrl
					if ($avail -and $avail.connectors)
					{
						$parts = @()
						foreach ($item in $avail.connectors)
						{
							if (-not $item) { continue }
							$t = if ($connectorNames.ContainsKey($item.type))
							{
								$connectorNames[$item.type]
							}
							else
							{
								$item.type
							}
							$free = $item.availability.current.available
							$total = $item.total
							
							if ($null -ne $free -and $null -ne $total)
							{
								$parts += "$t : $free vrij van $total"
								if ($free -gt 0)
								{
									$hasFree = $true # ER IS IETS VRIJ
								}
							}
						}
						if ($parts.Count -gt 0)
						{
							$availSummary = ($parts -join "; ")
						}
						else
						{
							$availSummary = "Geen connector-informatie in live data"
						}
					}
				}
				catch
				{
					$availSummary = "Live data niet beschikbaar"
				}
			}
			else
			{
				$availSummary = "Geen chargingAvailability-id bekend bij TomTom"
			}
		}
		else
		{
			$availSummary = "Geen laadpunt gevonden in de buurt van dit adres"
		}
	}
	else
	{
		$availSummary = "Geen geocode-resultaat voor '$adresQuery'"
	}
	
	$resultRows += [pscustomobject]@{
		Naam					 = $row.Naam
		Adres				     = $row.Adres
		Afstand_m			     = $row.Afstand_m
		"Connectoren (statisch)" = if ($staticConnectors.Count -gt 0)
		{
			$staticConnectors -join ", "
		} else {
			$row.'Connectoren (statisch)'
		}
		"Beschikbaarheid (live)" = $availSummary
		VrijBeschikbaar		     = $hasFree
	}
}

if ($resultRows.Count -eq 0)
{
	if ($Debug)
	{
		Add-Type -AssemblyName System.Windows.Forms
		[void][System.Windows.Forms.MessageBox]::Show("Geen regels verwerkt uit $csvPath.", 'SnellerDanJeBuren - Debug')
	}
	return
}

# Altijd als array casten, zodat .Count betrouwbaar is
$vrijePalen = @($resultRows | Where-Object { $_.VrijBeschikbaar -eq $true })

# Alleen popup als:
# - er vrije palen zijn, of
# - Debug aan staat (debug-modus)
if ($vrijePalen.Count -gt 0 -or $Debug)
{
	
	$msgLines = @()
	
	if ($vrijePalen.Count -gt 0)
	{
		foreach ($p in $vrijePalen)
		{
			$msgLines += "$($p.Naam)`r`n$($p.Adres)`r`n$($p.'Beschikbaarheid (live)')"
		}
	}
	else
	{
		# Debug aan, maar geen vrije palen
		$msgLines += "Geen vrije laadpalen gevonden."
		$msgLines += ""
		$msgLines += "Laatste status:"
		foreach ($p in $resultRows)
		{
			$msgLines += "$($p.Naam) - $($p.Adres) - $($p.'Beschikbaarheid (live)')"
		}
	}
	
	$message = $msgLines -join "`r`n`r`n"
	
	Add-Type -AssemblyName System.Windows.Forms
	
	$title = if ($vrijePalen.Count -gt 0) { 'Laadpaal vrij!' }
	else { 'SnellerDanJeBuren - Debug' }
	[void][System.Windows.Forms.MessageBox]::Show($message, $title)
}
