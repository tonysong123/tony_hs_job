#设备名称: (deviceName)
#错误的进程号码: (processId)
#进程/服务名称: (processName)
#错误的原因（描述）(description)
#发生的时间（小时级），例如 0100-0200，0300-0400, (timeWindow)
#在小时级别内发生的次数 (numberOfOccurrence)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logFiles = $scriptPath + "\logs\interview_data_set"
#$logFiles = $scriptPath + "\logs\interview_data_set_test"

$logs = Get-content $logFiles

$reg = "(^\S+)\s(\S+)\s(\S+)\s(\S+)\s(.*?)\:(.*)"
$reg2 = "(\S+)\[([\d+])\].*"

$i = 0

$dt_list = @()
$dt_json_list = @()
foreach($log in $logs)
{
	$i++
	$process = ""
#	$log
#	Write-Host "Processing Logs: " $i -ForegroundColor Green
	
	if($log -match $reg)
	{
		$month = $matches[1]
		$day = $matches[2]
		$hour = $matches[3].split(":")[0]
		$deviceName = $matches[4]
		$process = $matches[5]
		$description = $matches[6]

		if($process -match $reg2)
		{
			$processName = $matches[1]
			$processId = $matches[2]
		}

		$startHour = '{0:d2}' -f [int]$hour + "00"
		$endHour = '{0:d2}' -f ([int]$hour+1) + "00"
		$timeWindow = $startHour + "-" + $endHour

		$res = $deviceName + "`t" + $processId + "`t" + $processName + "`t" + $description + "`t" + $timeWindow
		
		$dt_list = $dt_list + $res

	#	if($i -gt 20)
	#	{
	#		break
	#	}
	#	break
	}
	else {
		$log
	}
}

$dt_group = $dt_list | Group-Object

foreach($dt in $dt_group)
{
	$deviceName,$processId,$processName,$description,$timeWindow = $dt.name.split("`t")
	$numberOfOccurrence = $dt.count

	$dt_json = @{
	"deviceName" = $deviceName;
	"processId"=$processId;
	"processName"=$processName;
	"description"=$description;
	"timeWindow"=$timeWindow;
	"numberOfOccurrence"=$numberOfOccurrence
	}
	$dt_json_list = $dt_json_list + $dt_json
}

$body = ConvertTo-Json $dt_json_list

# 网络不通，未验证POST数据功能
$WebClient = New-Object System.Net.WebClient
$WebClient.Headers.Add("Content-Type","application/json")
[byte[]]$ByteArray = [System.Text.Encoding]::UTF8.GetBytes($body)
$Webpage = $WebClient.UploadData($WebServiceURL,"POST",$ByteArray);
$Response = [System.Text.Encoding]::UTF8.GetString($Webpage)
$Response