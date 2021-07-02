$list = cmdkey.exe /list 
$line = $list.Trim()

ForEach($l in $line){
    
    if ($l -eq '') 
    {
        if ($found) { $newobject }
        $found = $false
        $newobject = '' | Select-Object -Property Type, User, Info, Target
    }
    else
    {
        if ($l.StartsWith("Target: "))
        {
            $found = $true
            $newobject.Target = $l.Substring(8)
        }
        elseif ($l.StartsWith("Type: "))
        {
            $newobject.Type = $l.Substring(6)
        }
        elseif ($l.StartsWith("User: "))
        {
            $newobject.User = $l.Substring(5)
        }
        else
        {
            $newobject.Info = $l
        }

    }
}