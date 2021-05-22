$fragment = @()

# Define Export File Path 
$DriveLetter = (Get-Volume).DriveLetter
$Path = foreach ($drv in $DriveLetter) {
  Get-ChildItem -Path "$drv`:\" -ErrorAction SilentlyContinue | Where-Object { $_.name -like '*search string*' }
}
            
$RunPath = ($Path).FullName


#############################################
#region =============== Function ================
#############################################
Function Create-ProcBarChart {
  param($ComputerName = $env:computername,
    [int32]$ProcessNumber
  )
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
 
  # chart object
  try {
    $chart1 = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
    $chart1.Width = 550
    $chart1.Height = 250
    $chart1.BackColor = [System.Drawing.Color]::White
 
    # title
    [void]$chart1.Titles.Add("Top $ProcessNumber - Memory Usage")
    $chart1.Titles[0].Font = "tahoma,13pt,style=bold"
    $chart1.Titles[0].Alignment = "topLeft"
 
    # chart area
    $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $chartarea.Name = "ChartArea1"
    $Chartarea.AxisX.MajorGrid.LineWidth = 0
    $Chartarea.AxisY.MajorGrid.LineWidth = 0
    $chartarea.AxisY.Title = "Memory (MB)"
    #$chartarea.AxisX.Title = "Process Name(MB)"
    $chartarea.AxisX.TitleFont = "tahoma,10pt"
    $chartarea.AxisY.TitleFont = "tahoma, 10pt"
    $chartarea.AxisY.IsLogarithmic = $false
    #$chartarea.AxisY.Interval = 100
    $chartarea.AxisX.Interval = 1
    $chart1.ChartAreas.Add($chartarea)
 
    # legend
    $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $legend.name = "Legend1"
    $legend.font = "Arial"
    $Legend.docking = "Right"
    $Legend.title = "Processes"
    $Legend.TitleFont = "Arial"
    $legend.alignment = "center"
    $Legend.Istextautofit = $true
    #$Legend.IsDockedInsideChartArea = $false
    #$chart1.Legends.Add($legend)

  
 
    # data source
    $datasource = Get-Process | Select-Object Name, ID, WorkingSet64 | Sort-Object WorkingSet64 -Descending | Select-Object -First $ProcessNumber
 
    # data series
    [void]$chart1.Series.Add("WSMem")
    $chart1.Series["WSMem"].ChartType = "Bar"
    #$chart1.Series["WSMem"].IsVisibleInLegend = $true
    $chart1.Series["WSMem"].BorderWidth = 3
    $chart1.Series["WSMem"].chartarea = "ChartArea1"
    #$chart1.Series["WSMem"].Legend = "Legend1"
    $chart1.Series["WSMem"].Palette = "SemiTransparent"
    $Chart1.Series["WSMem"]["DrawingStyle"] = "Cylinder"
    $datasource | ForEach-Object { $chart1.Series["WSMem"].Points.addxy( ($_.Name + " " + ([Math]::Round($_.WorkingSet64 / 1mb)) + " MB") , ([Math]::Round($_.WorkingSet64 / 1mb))) }

    # save chart
    $chart1.SaveImage('D:\' + "\ProcBar-" + $computername + ".png", "png")
  } 
  catch {
    "Error creating chart. Verify Microsoft Chart Controls for Microsoft .NET Framework 3.5 is installed"
  }
}
Function Create-CPUPieChart {
  param($ComputerName = $env:computername
  )
              
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
       
  #Get CPU Data
  $CpuInfo = Get-WmiObject -ComputerName $computername -Class win32_processor
  $CpuName = $CpuInfo | Select-Object -First 1 -Expand Name
  $CpuAddr = $CpuInfo | Select-Object -First 1 -Expand DataWidth
  $CpuCores = $CpuInfo | Select-Object -expand NumberOfCores
  $Global:CpuUsage = $CpuInfo | Select-Object Loadpercentage | Measure-Object LoadPercentage -Average | Select-Object -expand Average
  $CpuFree = 100 - [int]$CpuUsage
   
           
  #Create our chart object
  try {
    $Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart      
    $Chart.Width = 200
    $Chart.Height = 200
    $Chart.Left = 10
    $Chart.Top = 10
   
    #Create a chartarea to draw on and add this to the chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Chart.ChartAreas.Add($ChartArea)
    [void]$Chart.Series.Add("Data")
    #Add a datapoint for each value specified in the arguments (args)
    Write-Host "Now processing chart value: " + $CpuUsage
    $datapoint = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $CpuUsage)
    $datapoint.AxisLabel = "$CpuUsage% Used"
    $datapoint.Color = "FireBrick"
    $Chart.Series["Data"].Points.Add($datapoint)
   
    Write-Host "Now processing chart value: " + $CpuFree
    $datapoint1 = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $CpuFree)
    $datapoint1.AxisLabel = "$CPUFree% Free"
    $datapoint1.Color = "DodgerBlue"
    $Chart.Series["Data"].Points.Add($datapoint1)
       
   
    $Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Doughnut
    $Chart.Series["Data"]["PieLabelStyle"] = "Outside"
    $Chart.Series["Data"]["PieLineColor"] = "Black"
    $Chart.Series["Data"]["PieDrawingStyle"] = "Concave"
    ($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true
    $Chart.Series["Data"].Font = "Arial"
   
    # Create chart legend
    $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $legend.name = "Legend1"
    $legend.font = "Arial"
    $Legend.docking = "Top"
    $Legend.title = "CPU Usage"
    $Legend.TitleFont = "Arial,style=bold"
    $legend.alignment = "center"
    $Legend.Istextautofit = $true
       
 
    # Add chart legend to chart object
    $chart.legends.add($legend)
       
    #Save the chart to a file
    $Chart.SaveImage('D:\' + "\CPU-" + $computername + ".png", "png")
  }
  catch {
    "Error creating chart. Verify Microsoft Chart Controls for Microsoft .NET Framework 3.5 is installed"
  }
}
Function Create-RAMPieChart {
  param($ComputerName = $env:computername
  )
              
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
       
  #Gather RAM Data
  $SystemInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
  $TotalRAM = $SystemInfo.TotalVisibleMemorySize / 1MB
  $FreeRAM = $SystemInfo.FreePhysicalMemory / 1MB
  $Global:UsedRAM = $TotalRAM - $FreeRAM
  $RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
  $Free = [Math]::Round($FreeRAM, 2)
  $Used = [Math]::Round($UsedRAM, 2)
         
   
  #Create our chart object
  try {
    $Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart      
    $Chart.Width = 250
    $Chart.Height = 200
    $Chart.Left = 10
    $Chart.Top = 10
   
    #Create a chartarea to draw on and add this to the chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Chart.ChartAreas.Add($ChartArea)
    [void]$Chart.Series.Add("Data")
    #Add a datapoint for each value specified in the arguments (args)
    Write-Host "Now processing chart value: " + $used
    $datapoint = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $Used)
    $datapoint.AxisLabel = "$used GB Used"
    $datapoint.Color = "FireBrick"
    $Chart.Series["Data"].Points.Add($datapoint)
   
    Write-Host "Now processing chart value: " + $Free
    $datapoint1 = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $Free)
    $datapoint1.AxisLabel = "$Free GB Free"
    $datapoint1.Color = "DodgerBlue"
    $Chart.Series["Data"].Points.Add($datapoint1)
       
   
    $Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Doughnut
    $Chart.Series["Data"]["PieLabelStyle"] = "Outside"
    $Chart.Series["Data"]["PieLineColor"] = "Black"
    $Chart.Series["Data"]["PieDrawingStyle"] = "Concave"
    ($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true
    $Chart.Series["Data"].Font = "Arial"
   
    # Create chart legend
    $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $legend.name = "Legend1"
    $legend.font = "Arial"
    $Legend.docking = "Top"
    $Legend.title = "RAM Usage"
    $Legend.TitleFont = "Arial,style=bold"
    $legend.alignment = "center"
    $Legend.Istextautofit = $true
        
       
    # Add chart legend to chart object
    $chart.legends.add($legend)
       
    #Set the title of the Chart to the current date and time
    #$Title = new-object System.Windows.Forms.DataVisualization.Charting.Title
    #$Chart.Titles.Add($Title)
    #$Chart.Titles[0].Text = "RAM Usage"
    #$Chart.Titles[0].Font = "Arial"
    #Save the chart to a file
    $Chart.SaveImage('D:\' + "\RAM-" + $computername + ".png", "png")
   
  }
  catch {
    "Error creating chart. Verify Microsoft Chart Controls for Microsoft .NET Framework 3.5 is installed"
  } 
}
function ServiceInfo {
  $ServiceName = switch ($env:COMPUTERNAME) {
    'serverName' {'ServiceName'}
  }
                                
  $Arr = @()
  $ServiceData = foreach ($Serv in $ServiceName) {
    $Source = Get-CimInstance win32_service | Where-Object { $_.displayname -eq $serv } 
    $StartTime = if ([string]::IsNullOrEmpty($((Get-Process -id $Source.ProcessId).StartTime)) -ne $true) { (Get-Process -id $Source.ProcessId).StartTime }else { Write-Output 'Null' }
            

    $obj = New-Object pscustomobject 
    $obj | Add-Member -MemberType NoteProperty -Name Name -Value $Source.DisplayName
    $obj | Add-Member -MemberType NoteProperty -Name Status -Value $Source.State
    $obj | Add-Member -MemberType NoteProperty -Name StartTime -Value $StartTime
    $Arr += $obj
    
  }
  $Arr
}
#############################################
#endregion ============= Function ==============
#############################################    

##################################
#region  ======== Image Set ========
##################################
#Logo 
$LogoImagePath = "$RunPath\Report\Image\Logo.png"
$LogoImageBits = [Convert]::ToBase64String((Get-Content $LogoImagePath -Encoding Byte))
$LogoImageFile = Get-Item $LogoImagePath
$LogoImageType = $LogoImageFile.Extension.Substring(1)
$LogoImageTag = "<Img src='data:image/$LogoImageType;base64,$($LogoImageBits)' Alt='$($LogoImageFile.Name)' style='float:Right' width='130' height='50' hspace=65>"

#Port Listen Check Online
$OnlineImagePath = "$RunPath\Report\Image\Online.png"
$OnlineImageBits = [Convert]::ToBase64String((Get-Content $OnlineImagePath -Encoding Byte))
$OnlineImageFile = Get-Item $OnlineImagePath
$OnlineImageType = $OnlineImageFile.Extension.Substring(1)
$OnlineImageTag = "<Img src='data:image/$OnlineImageType;base64,$($OnlineImageBits)' Alt='$($OnlineImageFile.Name)' style='float:Left' width='25' height='25'>"

#Port Listen Check Offline
$OfflineImagePath = "$RunPath\Report\Image\\Error.png"
$OfflineImageBits = [Convert]::ToBase64String((Get-Content $OfflineImagePath -Encoding Byte))
$OfflineImageFile = Get-Item $OfflineImagePath
$OfflineImageType = $OfflineImageFile.Extension.Substring(1)
$OfflineImageTag = "<Img src='data:image/$OfflineImageType;base64,$($OfflineImageBits)' Alt='$($OfflineImageFile.Name)' style='float:Left' width='25' height='25'>"

#CPU Chart
Create-CPUPieChart
$CPUImagePath = "d:\CPU-$env:COMPUTERNAME.png"
$CPUImageBits = [Convert]::ToBase64String((Get-Content $CPUImagePath -Encoding Byte))
$CPUImageFile = Get-Item $CPUImagePath
$CPUImageType = $CPUImageFile.Extension.Substring(1)
$CPUImageTag = "<Img src='data:image/$CPUImageType;base64,$($CPUImageBits)' Alt='$($CPUImageFile.Name)'>" #style='float:Left' width='150' height='150' hspace=15>"
Remove-Item "d:\CPU-$env:COMPUTERNAME.png" -Force

#Memory Chart
Create-RAMPieChart
$RAMImagePath = "d:\RAM-$env:COMPUTERNAME.png"
$RAMImageBits = [Convert]::ToBase64String((Get-Content $RAMImagePath -Encoding Byte))
$RAMImageFile = Get-Item $RAMImagePath
$RAMImageType = $RAMImageFile.Extension.Substring(1)
$RAMImageTag = "<Img src='data:image/$RAMImageType;base64,$($RAMImageBits)' Alt='$($RAMImageFile.Name)'>"#style='float:Left' width='150' height='150' hspace=15>"
Remove-Item "d:\RAM-$env:COMPUTERNAME.png" -Force

#Process Chart
Create-ProcBarChart -ProcessNumber 10
$ProcImagePath = "d:\ProcBar-$env:COMPUTERNAME.png"
$ProcImageBits = [Convert]::ToBase64String((Get-Content $ProcImagePath -Encoding Byte))
$ProcImageFile = Get-Item $ProcImagePath
$ProcImageType = $ProcImageFile.Extension.Substring(1)
$ProcImageTag = "<Img src='data:image/$ProcImageType;base64,$($ProcImageBits)' Alt='$($ProcImageFile.Name)'>"# style='float:Left' width='400' height='200' hspace=15>"
Remove-Item "d:\ProcBar-$env:COMPUTERNAME.png" -Force

##################################
#endregion ======= Image Set =======
##################################


###################################
#region  ======== System Info ========
###################################

$fragment += "<H1>$env:COMPUTERNAME System Report</H1>"
$fragment += "<br>"

$fragment += "<H2>OS Information</H2>"
        
$systemInfo = Get-CimInstance win32_operatingsystem

  $fragment += "<div style='width:50%; margin-left:5px; margin-right: auto;'>"
  $fragment += "<div class='rectangle' style='float: left;margin-left:5px;width: 520px;'>"

  $obj = New-Object PSCustomObject -Property @{LastBootUpTime = $systemInfo.LastBootUpTime;
    Version                                                   = $systemInfo.Version;  
    OperatingSystem                                           = $systemInfo.Caption
  } | ConvertTo-Html -Fragment -as list 

  $fragment += $obj
    
  $fragment += "</div>"
  $fragment += "</div>"
        

######################################
#endregion  ======== System Info ========
######################################

######################################
#region Directory Works Log Counting
######################################

# Check Daily Log Counting 

######################################
#endregion Directory Works Log Counting
######################################


######################################
#region  ======== Resource Usage ========
######################################

$fragment += "<br><br><br><br><br><br><br>"
$fragment += "<H2>CPU & Memory Usage (Process)</H2>"
$fragment += "<hr size=1 width=90%'>"


$FrameSet = @"

    <div style="width:50%; margin-left:30px; margin-top:20px; margin-right: auto;"> 
        <div class="rectangle" style="float: left;margin-left:30px;width: 200px;border:1px solid black;background-color:black;">
        $CPUImageTag
            </div>
        <div class="rectangle" style="float: left;margin-left:5px;width: 250px;border:1px solid black;background-color:black;">
        $RAMImageTag
            </div>
                <div class="square" style="float: left;margin-left:40px;width: 0.5px;height:230px;border-left:0.5px;outline-style:dotted;outline-color:#999898;"></div>
                <div class="square" style="float: left;margin-left:15px;width: 1%;">
        $ProcImageTag
            </div>
    </div>
    
"@    

$fragment += $FrameSet
$fragment += "<hr size=1 width='90%'>"

#########################################
#endregion  ======== Resource Usage ========
#########################################

##############################################
#region  ============ Disk Usage Table =============
##############################################

$gradient = @"
filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, 
StartColorStr=#0FBF43, EndColorStr=#F8AD61)
background-color: #4BED5C;
background-image: -mso-linear-gradient(left, #0FBF43 {0}%, #F8AD61 {1}%);
background-image: -ms-linear-gradient(left, #0FBF43 {0}%, #F8AD61 {1}%);
background-image: -moz-linear-gradient(left, #0FBF43 {0}%, #F8AD61 {1}%);
background-image: -o-linear-gradient(left, #0FBF43 {0}%, #F8AD61 {1}%);
background-image: -webkit-linear-gradient(left, #0FBF43 {0}%, #F8AD61 {1}%);
background-image: linear-gradient(left, #0FBF43 {0}%, #F8AD61 {1}%);
"@

$data = Get-CimInstance Win32_logicaldisk -filter "drivetype=3" 

$drives = foreach ($item in $data) {
  $prophash = [ordered]@{
    Drive           = $item.DeviceID
    Volume          = $item.VolumeName
    "TotalSize(GB)" = $item.size / 1GB -as [int]
    "FreeSpace(GB)" = "{0:N2}" -f ($item.Freespace / 1GB)
    "Free(%)"       = [math]::Round(($item.Freespace / $item.size) * 100, 2)
  }
  New-Object PSObject -Property $prophash
} #foreach item
 
[xml]$Volume = $drives | ConvertTo-Html -Fragment
  
#add the computer name as the table caption
#$caption= $Volume.CreateElement("caption")                                                                     
#$Volume.table.AppendChild($caption) | Out-Null                                                                            
#$Volume.table.caption= $data[0].SystemName

#go through rows again and add gradient
for ($i = 1; $i -le $Volume.table.tr.count - 1; $i++) {
  $class = $Volume.CreateAttribute("style")
  [int]$start = $Volume.table.tr[$i].td[-1]
  #create the gradient using starting and ending values
  #based on %free
  $class.value = $Gradient -f $start, (100 - $start)
  $Volume.table.tr[$i].ChildNodes[4].Attributes.Append($class) | Out-Null
} #for
 
#add the html to the fragments

$DiskUtilization += $Volume.InnerXml

$fragment += ConvertTo-Html -PreContent "<h2>Disk Utilization</h2>" -PostContent $DiskUtilization | ForEach-Object { $PSItem -replace "<td>", "<td style='text-align:center;'>" }
$DiskUtilization = ''

#############################################
#endregion ========== Disk Usage Table ===========
#############################################

##############################################
#region  ============= Service Check ============
##############################################

$fragment += "<H2>Service Info</H2>"
$fragment += ServiceInfo | ConvertTo-Html -Fragment -As Table | ForEach-Object { $PSItem -replace "<td>Stopped</td>", "<td style='color:white;background-color:#FF3737;font-weight:bold;text-align:center;'>Stopped</td>" -replace "<td>Running</td>", "<td style=text-align:center;>Running</td>" }

##############################################
#endregion  ============= Service Check ============
##############################################


##########################################
#region ==========  KMS Host Check ===========
##########################################
#d6992aac-29e7-452a-bf10-bbfb8ccabe59
if ($((Get-WindowsOptionalFeature -Online | Where-Object { $_.featurename -like '*volume*' }).State) -eq 'enabled') {
  $fragment += "<H2>KMS Status</H2>"
  $KMSObject = @()
  # Windows License KMS Key
  $IDs = 'KMS ID'
  foreach ($ID in $IDs) {
    $KMS = cscript c:\windows\system32\slmgr.vbs /dlv $ID
    $KMSName = ($KMS | Where-Object { $_ -match '이름:\s(.*)' }).trim("이름:\s\s")
    $KMSLicense = ($KMS | Where-Object { $_ -match '라이선스 상태:\s(.*)' }).trim("라이선스 상태:\s")
    $KMSreAlm = ($KMS | Where-Object { $_ -match '남은 Windows[\s\S]+?:\s(.*)|남은 앱[\s\S]+?:\s(.*)' }) -replace '남은 Windows 라이선스 초기화 횟수:', '' -replace '남은 앱 라이선스 초기화 횟수:', ''
    $KMSTrust = ($KMS | Where-Object { $_ -match '신뢰[\s\S]+?:\s(.*)' }).trim("신뢰할 수 있는 시간:\s")
    $KMSCount = ($KMS | Where-Object { $_ -match '현재 수:\s(.*)' }).trim("현재 수:\s")

    $KMSHash = [ordered]@{
      'Name'      = $KMSName
      'License'   = $KMSLicense
      'ReAlm'     = $KMSreAlm
      'TrustDate' = $KMSTrust
      'KCount'    = $KMSCount
    }
        
    $KMSObject += New-Object PSobject -Property $KMSHash 
  }
 
  $KMSCss = @"
<table>
<colgroup><col/><col/><col/></colgroup>
<tr><th>Name</th><th>License</th><th>ReAlm</th><th>TrustDate</th><th>Count</th></tr>
<tr><td>$($KMSObject.name[0])</td><td>$($KMSObject.license[0])</td><td>$($KMSObject.ReAlm[0])</td><td>$($KMSObject.TrustDate[0])</td><td>$($KMSObject.KCount[0])</td></tr>
<tr><td>$($KMSObject.name[1])</td><td>$($KMSObject.license[1])</td><td>$($KMSObject.ReAlm[1])</td><td>$($KMSObject.TrustDate[1])</td><td>$($KMSObject.KCount[1])</td></tr>
<tr><td>$($KMSObject.name[2])</td><td>$($KMSObject.license[2])</td><td>$($KMSObject.ReAlm[2])</td><td>$($KMSObject.TrustDate[2])</td><td>$($KMSObject.KCount[2])</td></tr>
</table>              
"@


  $fragment += $KMSCss
       
}
##########################################
#endregion ========  KMS Host Check ======
##########################################

<#
##########################################
#region =========  EventLog Result ==========
##########################################

$fragment += "<H2>EventLog Info</H2>"


[xml]$html = Get-EventLog -List | select @{n="Max(K)";e={"{0:n0}" -f $_.MaximumKilobytes }},
                                                                      @{n='Retain';e={$_.MininumRetentionDays }}, 
                                                                       OverFlowAction,
                                                                       @{n='Entries';e={"{0:N0}" -f $_.entries.count }},
                                                                       @{n='Log';e={$_.LogDisplayName}} | ConvertTo-Html -Fragment

for ($i=1;$i -le $html.table.tr.count -1;$i++) {
    if ($html.table.tr[$i].td[3] -eq 0) {
        $class = $html.CreateAttribute("class")
        $class.Value = 'alert'
        $html.table.tr[$i].attributes.append($class) #| Out-Null
        }
    }
$fragment += $html.InnerXml

##########################################
#endregion =========  EventLog Result ==========
##########################################
#>

$fragment += "<p class='footer'>$(Get-Date)</p>"
$fragment += "<hr size=1 width=90%'>"
$fragment += $LogoImageTag

#############################################
#region =============== CSS Style ================
#############################################
$ConvertParams = @{
  head = @"
    <title>System Report - $($env:COMPUTERNAME)</Title>
<style>
body { background -color:#E5E4E2;
             font-family:Monospace;
             font-size:10pt; }
td, th { border:0px solid black;
             border-collapse:collapse;
             white-space:pre;
             }
th { color:white;
        background-color:gray;
        }
table, tr, td, th { padding: 2px; margin: 0px ; white-space:pre; }
tr:nth-child(odd) {background-color: lightgray }
table { width:95%;margin-left:5px; margin-bottom:20px;}
h1 {
    font-family:Eras ITC;
    font-size:25pt;
    color:Navy
}

h2 {
    font-family:Tahoma;
    color:#6D7B8D;
}
.alert {
    color: red;
    }
.footer
{ color:green;
   margin-left:10px;
   font-family:Tahoma;
   font-size:8pt;
   font-style:italic;
.transparent {
    background-color:#E5E4E1
  }
.square
       {
              width:auto;
              height:100%;
              margin-bottom: 15px;
              margin-top: 15px;
              text-align:center;
              align:center;
       }
.rectangle
    {
        width:72.3%;
        margin :0 auto;
        margin-top: 10px;
        margin-bottom: 10px;
        text-align:center;
    }
.V1
    {border-left: 1px solid black;
    height: 300px}
    
}
</style>
"@
  body = $fragment
}
#############################################
#endregion ============= CSS Style ===============
#############################################

#############################################
#region ========  Export DashBoard Data =========
#############################################

# CPU Usage
$CpuInfo = Get-WmiObject -Class win32_processor
$CpuUsage = $CpuInfo | Select-Object Loadpercentage | Measure-Object LoadPercentage -Average | Select-Object -expand Average

# Memory Usage
$ComputerMemory = Get-WmiObject -Class win32_operatingsystem
$Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory) * 100) / $ComputerMemory.TotalVisibleMemorySize)
$RoundMemory = [math]::Round($Memory, 2)

# Disk Usage

$data = Get-CimInstance Win32_logicaldisk -filter "drivetype=3" 
$drives = foreach ($item in $data) {
  $prophash = @{
    Free = [math]::Round(($item.Freespace / $item.size) * 100, 2)
    Used = [math]::round($item.size - ($item.size - $item.freespace / 1gb), 2)
  }
  New-Object PSObject -Property $prophash
} 

# Service Check

$ServiceChcek = ServiceInfo
$ServiceCount = ($ServiceChcek.status | Where-Object { $_ -eq 'Stopped' }).count


# Output Data Result
$DataResult = @()
$ExportObj = foreach ($drv in $drives) {
  $Hash = [ordered]@{Name = $env:COMPUTERNAME
    CPU                   = "{0:N0}" -f $CpuUsage
    Mem                   = "{0:N0}" -f $RoundMemory
    Disk                  = "{0:N0}" -f $drv.free
    Service               = $ServiceCount
    UseDisk               = $drv.Used
  }
  New-Object PSobject -Property $Hash
}
$DataResult += $ExportObj



do {

  if ((Test-Path "$RunPath\$env:COMPUTERNAME.csv" -PathType Leaf) -eq $false) {

    $DataResult | Export-Csv -Encoding utf8 -NoClobber -NoTypeInformation "$RunPath\$env:COMPUTERNAME.csv" -Force
  }
    
  else {
    Remove-Item "$RunPath\$env:COMPUTERNAME.csv" -force
	        
    $DataResult | Export-Csv -Encoding utf8 -NoClobber -NoTypeInformation "$RunPath\$env:COMPUTERNAME.csv" -Force
  }
        
  $check = Test-Path "$RunPath\$env:COMPUTERNAME.csv" -PathType Leaf
}
until ($check -eq $true)


################################################
#endregion ========  Export DashBoard Data ========
################################################

ConvertTo-Html @ConvertParams | Out-File "$RunPath\$env:COMPUTERNAME.htm"

$PWstore = 'Define Password File' | ConvertTo-SecureString -Key ('Define Key File')
$Credential = New-Object System.Management.Automation.PSCredential("UserName", $PWstore)
$session = New-PSSession -ComputerName 'DC Name' -Credential $Credential

Copy-Item "LocalPath:\$env:COMPUTERNAME.htm" 'Def Destination Report File' -ToSession $session -Force
Copy-Item "LocalPat:\$env:COMPUTERNAME.csv" 'Def Destination Report File' -ToSession $session -Force
