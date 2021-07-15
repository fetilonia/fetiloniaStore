
begin {
  
  # Capture File Path
  Copy-Item 'SourcePath\*.png' 'TargetPath\' -Force
  
  # WorkGroup Zone Daily Report File Copy
  $Today = Get-Date
  $FilePath = 'Report Files Path'
  $FileCheck = Get-ChildItem ("$filepath`*.csv", "$filepath`*.htm") | Where-Object { $_.lastwritetime -ge [datetime]::new($Today.Year, $Today.Month, $Today.Day) }
  $CopyPath = '\\AD SYSVOL\Destination Path'
  if ($FileCheck) {
    $FileCheck | Where-Object name -like '*htm' | ForEach-Object { Copy-Item $_.pspath $CopyPath\HTM }
    $FileCheck | Where-Object name -like '*csv' | ForEach-Object { Copy-Item $_.pspath $CopyPath\Prop }
  }
}

process {
  ##################################
  #region  ======== Image Set ========   보고서 표지에 사용할 그림 파일 Hash 화
  ################################## 
  #Logo 
  $LogoImagePath = 'Source Image File Path'
  $LogoImageBits = [Convert]::ToBase64String((Get-Content $LogoImagePath -Encoding Byte))
  $LogoImageFile = Get-Item $LogoImagePath
  $LogoImageType = $LogoImageFile.Extension.Substring(1)
  $LogoImageTag = "<Img align='center' width='100%' height='100%' src='data:image/$LogoImageType;base64,$($LogoImageBits)' Alt='$($LogoImageFile.Name)' style='opacity:0.5;'>"

  ##################################
  #endregion ======= Image Set =======
  ##################################

  #####################################
  #region  ======== Style Sheet ========
  #####################################

  $head = @"
<title> System Report_$(Get-Date -f 'MM/dd')</Title>
<style>
body { background -color:#E6E4E2;
             font-family:Monospace;
             font-size:10pt; }
td, th { border:0px solid black;
         border-collapse:collapse;
         white-space:pre;
         text-align:center;
         }
th { color:white;
     background-color:gray;
     }
table, tr, td, th { padding: 2px; margin: 0px ; white-space:pre; }
tr:hover td
    {
        background-color: DodgerBlue ;
        Color: #F5FFFA;
           }
tr:nth-child(odd) {background-color: lightgray }
table { width:96%;margin-left:6px; margin-bottom:20px;}
h1 {
    font-family:Malgun gothic;
    font-size:26pt;
    font-weight:bold;
    color:Navy
}

p {
    font-family:tahoma;
    font-size:11px;
    color:#0F6CFA;
   } 
     
h2 {
    font-family:Tahoma;
    color:#6D7B8D;
}

.OK
{ background-color:#96EA63 }

.Alert
{ background-color:#F6C669 }
   
.Warning
{ background-color:#FF6328;
  color:white;
  font-weight='bold';
  }

.OK1
{
  background-image:url(file path ex)file://ad sysvol/file.png);
  background-repeat: no-repeat;
  background-position: center;
  font-size:0px;
  }

.NG
{
  background-image:url(file path ex)file://ad sysvol/file.png);
  background-repeat: no-repeat;
  background-position: center;
  font-size:0px;
  }

.Null
{ background-color:white; }

.footer
{ color:green;
   margin-left:10px;
   font-family:Tahoma;
   font-size:8pt;
   font-style:italic;
.transparent {
    background-color:#E6E4E1
  }
.square
       {
              width:auto;
              height:100%;
              margin-bottom: 16px;
              margin-top: 16px;
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

.button
{ background-color: #4CAF50;
  border: none;
  color: white;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  cursor: pointer;
  }


#myDIV {
  width: 100%;
  padding: 50px 0;
  text-align: center;
  margin-top: 20px;
  }
}
</style>
"@

  ########################################
  #endregion  ======== Style Sheet ========
  ########################################

  $Today = Get-Date -UFormat "%Y-%m-%d"  
  $ServerName = 'Server Names ex)server1, server2 ...'

  # Var Clear
  $obj = $result = [xml]$Modify = $body = $disk1 = $disk2 = $disk3 = $disk4 = ''

  #$ServerName = 'D009TD4231','IMAD1','IMAD2','IMADTP','IMADDR','IMADDR2'
  $FilePath = 'File Copy Destination Path'



  $obj = foreach ($serv in $ServerName) {
    
    $ImportData = Import-Csv "$FilePath\Prop\$serv.csv"
    $CheckDate = (Get-ItemProperty $FilePath\HTM\$serv.htm).LastWriteTime
    $Convert = "{0:yyyy-MM-dd}" -f [datetime]$CheckDate
    $Compare = (Compare-Object $Today $Convert -IncludeEqual).SideIndicator

    $FileWrite = if ($Compare -eq '==') { 'OK' } else { 'NG' }


    $Hash = [ordered]@{"Name" = $ImportData.name[0];
      "CPU(%)"                = $ImportData.cpu[0];
      "MEM(%)"                = $ImportData.mem[0];
      "Disk1(Free%)"          = $ImportData.disk[0];
      "Disk2(Free%)"          = $ImportData.disk[1];
      "Disk3(Free%)"          = $ImportData.disk[2];
      "Disk4(Free%)"          = $ImportData.disk[3];
      "Disk5(Free%)"          = $ImportData.disk[4];
      Service                 = $ImportData.Service[0]
      Today                   = $FileWrite

    }

    New-Object PSobject -Property $Hash 

  }

  [xml]$Modify = $obj | ConvertTo-Html -Fragment 

  for ($i = 1; $i -le $Modify.table.tr.count - 1; $i++) {
    [int]$CPU = ($Modify.table.tr[$i].td[1])
    switch ($CPU) {
      { $CPU -le 60 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[1].attributes.append($class)
      }
      { $CPU -gt 60 -and $CPU -le 80 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[1].attributes.append($class)
      }
      { $CPU -gt 80 -and $CPU -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[1].attributes.append($class)
      }
    }
    [int]$Mem = ($Modify.table.tr[$i].td[2])
    switch ($Mem) {
      { $Mem -le 60 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[2].attributes.append($class)
      }
      { $Mem -gt 60 -and $Mem -le 80 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[2].attributes.append($class)
      }
      { $Mem -gt 80 -and $Mem -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[2].attributes.append($class)
      }
    }
                
    [int]$Disk1 = ($Modify.table.tr[$i].td[3])
    switch ($Disk1) {
      { $Disk1 -gt 40 -and $Disk1 -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[3].attributes.append($class)
      }
      { $Disk1 -gt 20 -and $Disk1 -le 40 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[3].attributes.append($class)
      }
      { $Disk1 -le 20 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[3].attributes.append($class)
      }
    }                

    [int]$Disk2 = ($Modify.table.tr[$i].td[4])
    switch ($Disk2) {
      { $Disk2 -gt 40 -and $Disk2 -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[4].attributes.append($class)
      }
      { $Disk2 -gt 20 -and $Disk2 -le 40 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[4].attributes.append($class)
      }
      { $Disk2 -lt 20 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[4].attributes.append($class)
      }
    }

    [string]$Disk3 = ($Modify.table.tr[$i].td[5])
    switch ($Disk3) {
      { ([string]::IsNullOrEmpty($Disk3)) -eq $true } { $null }
      { [int]$Disk3 -gt 40 -and [int]$Disk3 -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[5].attributes.append($class)
      }
      { [int]$Disk3 -gt 20 -and [int]$Disk3 -le 40 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[5].attributes.append($class)
      }
      { [int]$Disk3 -lt 20 -and [string]::IsNullOrEmpty($disk3) -eq $false } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[5].attributes.append($class)
      }
    }
    
    [string]$Disk4 = ($Modify.table.tr[$i].td[6])        
    switch ($Disk4) {
      { ([string]::IsNullOrEmpty($Disk4)) -eq $true } { $null }
      { [int]$Disk4 -gt 40 -and [int]$Disk4 -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[6].attributes.append($class)
      }
      { [int]$Disk4 -gt 20 -and [int]$Disk4 -le 40 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[6].attributes.append($class)
      }
      { [int]$Disk4 -lt 20 -and [string]::IsNullOrEmpty($Disk4) -eq $false } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[6].attributes.append($class)
      }
    }


    [string]$Disk5 = ($Modify.table.tr[$i].td[7])        
    switch ($Disk5) {
      { ([string]::IsNullOrEmpty($Disk5)) -eq $true } { $null }
      { [int]$Disk5 -gt 40 -and [int]$Disk5 -le 100 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'OK'
        $modify.table.tr[$i].childnodes[7].attributes.append($class)
      }
      { [int]$Disk5 -gt 20 -and [int]$Disk5 -le 40 } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Alert'
        $modify.table.tr[$i].childnodes[7].attributes.append($class)
      }
      { [int]$Disk5 -lt 20 -and [string]::IsNullOrEmpty($Disk5) -eq $false } {
        $class = $Modify.CreateAttribute("class")
        $class.Value = 'Warning'
        $modify.table.tr[$i].childnodes[7].attributes.append($class)
      }
    }

         
    if ($Modify.table.tr[$i].td[8] -eq 0) {
      $class = $Modify.CreateAttribute("class")
      $class.Value = 'OK1'
      $modify.table.tr[$i].childnodes[8].attributes.append($class)
    }
    else {
      $class = $Modify.CreateAttribute("class")
      $class.Value = 'NG'
      $modify.table.tr[$i].childnodes[8].attributes.append($class)
    }

    if ($Modify.table.tr[$i].td[9] -eq 'OK') {
      $class = $Modify.CreateAttribute("class")
      $class.Value = 'OK1'
      $modify.table.tr[$i].childnodes[9].attributes.append($class)
    }
    else {
      $class = $Modify.CreateAttribute("class")
      $class.Value = 'NG'
      $modify.table.tr[$i].childnodes[9].attributes.append($class)
    }
        
  }

  ###########################################
  #region ======= Adding HyperLink ==========
  ###########################################

  $Result = $Modify.InnerXml -replace "<th>*</th>", "<th>Name</th>"`
    -replace "<td>$($ServerName[0])</td>", "<td><a href=$FilePath\HTM\$($ServerName[0]).htm>$($servername[0])</a></td>"`
    -replace "<td>$($ServerName[1])</td>", "<td><a href=$FilePath\HTM\$($ServerName[1]).htm>$($servername[1])</a></td>"`
    -replace "<td>$($ServerName[2])</td>", "<td><a href=$FilePath\HTM\$($ServerName[2]).htm>$($servername[2])</a></td>"`
    -replace "<td>$($ServerName[3])</td>", "<td><a href=$FilePath\HTM\$($ServerName[3]).htm>$($servername[3])</a></td>"`
    -replace "<td>$($ServerName[4])</td>", "<td><a href=$FilePath\HTM\$($ServerName[4]).htm>$($servername[4])</a></td>"`
    -replace "<td>$($ServerName[5])</td>", "<td><a href=$FilePath\HTM\$($ServerName[5]).htm>$($servername[5])</a></td>"`
    -replace "<td>$($ServerName[6])</td>", "<td><a href=$FilePath\HTM\$($ServerName[6]).htm>$($servername[6])</a></td>"`
    -replace "<td>$($ServerName[7])</td>", "<td><a href=$FilePath\HTM\$($ServerName[7]).htm>$($servername[7])</a></td>"`
    -replace "<td>$($ServerName[8])</td>", "<td><a href=$FilePath\HTM\$($ServerName[8]).htm>$($servername[8])</a></td>"`
    -replace "<td>$($ServerName[9])</td>", "<td><a href=$FilePath\HTM\$($ServerName[9]).htm>$($servername[9])</a></td>"`
    -replace "<td>$($ServerName[10])</td>", "<td><a href=$FilePath\HTM\$($ServerName[10]).htm>$($servername[10])</a></td>"`
    -replace "<td>$($ServerName[11])</td>", "<td><a href=$FilePath\HTM\$($ServerName[11]).htm>$($servername[11])</a></td>"`
    -replace "<td>$($ServerName[12])</td>", "<td><a href=$FilePath\HTM\$($ServerName[12]).htm>$($servername[12])</a></td>"`
    -replace "<td>$($ServerName[13])</td>", "<td><a href=$FilePath\HTM\$($ServerName[13]).htm>$($servername[13])</a></td>"`
    -replace "<td>$($ServerName[14])</td>", "<td><a href=$FilePath\HTM\$($ServerName[14]).htm>$($servername[14])</a></td>"`
    -replace "<td>$($ServerName[15])</td>", "<td><a href=$FilePath\HTM\$($ServerName[15]).htm>$($servername[15])</a></td>"`
    -replace "<td>$($ServerName[16])</td>", "<td><a href=$FilePath\HTM\$($ServerName[16]).htm>$($servername[16])</a></td>"`
    -replace "<td>$($ServerName[17])</td>", "<td><a href=$FilePath\HTM\$($ServerName[17]).htm>$($servername[17])</a></td>"`
    -replace "<td>$($ServerName[18])</td>", "<td><a href=$FilePath\HTM\$($ServerName[18]).htm>$($servername[18])</a></td>"`
    -replace "<td>$($ServerName[19])</td>", "<td><a href=$FilePath\HTM\$($ServerName[19]).htm>$($servername[19])</a></td>"`
    -replace "<td>$($ServerName[20])</td>", "<td><a href=$FilePath\HTM\$($ServerName[20]).htm>$($servername[20])</a></td>"`
    -replace "<td>$($ServerName[21])</td>", "<td><a href=$FilePath\HTM\$($ServerName[21]).htm>$($servername[21])</a></td>"`
    -replace "<td>$($ServerName[22])</td>", "<td><a href=$FilePath\HTM\$($ServerName[22]).htm>$($servername[22])</a></td>"`
    -replace "<td>$($ServerName[23])</td>", "<td><a href=$FilePath\HTM\$($ServerName[23]).htm>$($servername[23])</a></td>"`
    -replace "<td>$($ServerName[24])</td>", "<td><a href=$FilePath\HTM\$($ServerName[24]).htm>$($servername[24])</a></td>"`
    -replace "<td>$($ServerName[25])</td>", "<td><a href=$FilePath\HTM\$($ServerName[25]).htm>$($servername[25])</a></td>"`
    -replace "<td>$($ServerName[26])</td>", "<td><a href=$FilePath\HTM\$($ServerName[26]).htm>$($servername[26])</a></td>"`
    -replace "<td>$($ServerName[27])</td>", "<td><a href=$FilePath\HTM\$($ServerName[27]).htm>$($servername[27])</a></td>"`
    -replace "<td>$($ServerName[28])</td>", "<td><a href=$FilePath\HTM\$($ServerName[28]).htm>$($servername[28])</a></td>"`
    -replace "<td>$($ServerName[29])</td>", "<td><a href=$FilePath\HTM\$($ServerName[29]).htm>$($servername[29])</a></td>"`
    -replace "<td>$($ServerName[30])</td>", "<td><a href=$FilePath\HTM\$($ServerName[30]).htm>$($servername[30])</a></td>"`
    -replace "<td>$($ServerName[31])</td>", "<td><a href=$FilePath\HTM\$($ServerName[31]).htm>$($servername[31])</a></td>"
                           

  ##############################################
  #endregion ======= Adding HyperLink ==========
  ##############################################

  $body = @"
<H1>$(Get-Date -f 'yy.MM.dd') - 일일점검</H1>
<br>

<input type="button" class="button" value="Console Report" button onclick="myFunction()">
<p><b>Note:</b> 버튼을 클릭하시면 스크린샷을 확인 가능 합니다.</p>

<div id="myDIV" style="display:none">
  <table>
    <colgroup><col/><col/><col/></colgroup>
    <tr><th>blabla</th></tr>
    <tr><td>$ImageTagVar</td>
    
  </table>
  </div>

<script>
function myFunction() {
  var x = document.getElementById("myDIV");
  if (x.style.display == "none") {
    x.style.display = "block";
  } else {
    x.style.display = "none";
  }
}
</script>


<br>
<hr size=1; width=90%;>

 <div style="width:70%; margin-left:6px; margin-right: auto;"> 
        <div class="rectangle" style="float: left;margin-left:6px;width: 900px;height:90px;">
            $result
        </div>
        <div class="square" style="float: left;margin-left:890px;margin-top:-93px;width:0.5px;height:680px;border-left:0.5px;outline-style:double;outline-color:#999898;"></div>
        <div class="square" style="float: left;margin-left:895px;margin-top:-679px;width:280px;height:150px;border-left:0.5px;">
            <table>
                <tr><th>CPU&MEM</th><th>Disk</th></tr>
                <tr><td style='background-color:#96EA63;'>0% ~ 60%</td><td style='background-color:#96EA63;'>100%~40%</td></tr>
                <tr><td style='background-color:#F6C669;'>60% ~ 80%</td><td style='background-color:#F6C669;'>40%~20%</td></tr>
                <tr><td style='background-color:#FF6328;'>80% ~ 100%</td><td style='background-color:#FF6328;'>20%~0%</td></tr>
            </table>
        </div>
        <div class="square" style="float: left;margin-left:900px;margin-top:-48px;width:140px;height:55px;">
            $LogoImageTag
        </div>
 
 </div>
 <br><br><br><br><br>
 <hr size=1; width=90%;margin-top:10px;>
 <p><b>Note:</b> 서버 이름을 클릭하시면 점검 결과 페이지로 이동합니다. </p>
 
"@
}

end {
  ConvertTo-Html -Head $head -body $body | Out-File "ReportFilePath\운영서버_일일점검_$("{0:yyyyMMdd}" -f (Get-Date)).htm"
}






