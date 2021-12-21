# Created by: Jonathon Miles
# Create Date: 11/12/2021
# Modified by: XYZ
# Modified Date:

# Purpose: To compare to Registry exports and output the differences in a CSV file.
# Requires: 2 *.reg files to compare

# Source File location
$BeforeFile = "C:\Git\Powershell\RegCompare\Before.reg"
$AfterFile = "C:\Git\Powershell\RegCompare\After.reg"

# Outfile location
$ResultsFile = "C:\Git\Powershell\RegCompare\Results.csv"

#Create a backup of the original files because I'll be changing them
Copy-Item $BeforeFile -Destination ($BeforeFile).Replace(".", "-orig.")
Copy-Item $AfterFile -Destination ($AfterFile).Replace(".", "-orig.")

# Replace any endbracket plus linebreak with nothing. Write that to the source file
 (Get-Content $BeforeFile -raw ) -replace (",\`r`n", "") | Set-Content -Path $BeforeFile
 (Get-Content $AfterFile -raw ) -replace (",\`r`n", "") | Set-Content -Path $AfterFile
#

#ingest the modified source files
$oldReg = Get-Content $BeforeFile 
$newReg = Get-Content $AfterFile  

$count = 0

foreach( $Line in $newReg){
    #$count++
    
    if ($line.Length -eq '0'){
        #Write-Host $count
        $Newline | select | Out-File -Encoding utf8 -Append -FilePath ($AfterFile).Replace(".", "-Compare.")
        # $LastBlank=$Blank
        # $Blank=$count
        $Newline = ''
       
    }
    Else{
        #write-host $count
        $Newline = $NewLine + $Line
           
    }

}

$count = 0

foreach( $Line in $OldReg){
    #$count++
    
    if ($line.Length -eq '0'){
        #Write-Host $count
        $Newline | select | Out-File -Encoding utf8 -Append -FilePath ($BeforeFile).Replace(".", "-Compare.")
        # $LastBlank=$Blank
        # $Blank=$count
        $Newline = ''
       
    }
    Else{
        #write-host $count
        $Newline = $NewLine + $Line
           
    }

}

#ingest the modified source files
$oldReg = Get-Content ($BeforeFile).Replace(".", "-Compare.")
$newReg = Get-Content ($AfterFile).Replace(".", "-Compare.")

#Compare the two files
$differences = Compare-Object -referenceObject $oldReg -differenceObject $newReg

#Export to CSV
$differences | Export-Csv -Path "C:\Git\Powershell\RegCompare\Results.csv"

#Replace the annoying Side Indicators with something more useful
(Get-Content "C:\Git\Powershell\RegCompare\Results.csv" -raw ) -replace ("=>", "After File Value") -replace ("<=", "Before File Value") | Set-Content -Path $ResultsFile

