# Created by: Jonathon Miles
# Create Date: 11/12/2021
# Modified by: Jonathon Miles
# Modified Date:12/21/2021

# Purpose: To compare to Registry exports and output the differences in a CSV file.
# Requires: 2 *.reg files to compare

# Source File location
$BeforeFile = "C:\Git\registrycompare\Before.reg"
$AfterFile = "C:\Git\registrycompare\After.reg"

# Outfile location
$ResultsFile = "C:\Git\registrycompare\Results.csv"

#Create a backup of the original files because I'll be changing them
Write-Host "Creating backup files"
Copy-Item $BeforeFile -Destination ($BeforeFile).Replace(".", "-orig.")
Copy-Item $AfterFile -Destination ($AfterFile).Replace(".", "-orig.")

# Replace any ",\" followed by linebreak with nothing. Write that to the source file.
Write-Host "Replacing specific strings"
(Get-Content $BeforeFile -raw ) -replace (",\\`r`n", "") -replace ("  ", ",")| Set-Content -Path $BeforeFile
(Get-Content $AfterFile -raw ) -replace (",\\`r`n", "") -replace ("  ", ",")| Set-Content -Path $AfterFile

# ingest the modified source files
Write-Host "Ingesting Files"
$oldReg = Get-Content $BeforeFile 
$newReg = Get-Content $AfterFile  

#Reset all the variable that will be used in the loop.
Write-Host "Processing After Hive"
$Newline = ''
$AfterArray =New-Object System.Collections.Generic.List[string]

#Loop to create the comparison file There is some logic in the order of the If statements to basically capture all the lines between 2 empty lines
foreach( $Line in $newReg){
        
    if ($line.Length -eq '0'){
        
        # Add $NewLine to the List variable. Newline should be a single line version of what previously was 2-1000+ lines
        #$LineList1.Add($Newline)
        $AfterArray.Add($Newline.ToUpper())
        $Newline = ''
       
    }
    Else{
        #Newline should be a single line version of what previously was 2-1000+ lines
        $Newline = $NewLine + $Line
         
    }
}

#Reset all the variable that will be used in the loop.
Write-Host "Processing Before hive"
$Newline = ''
$BeforeArray = New-Object System.Collections.Generic.List[string]

#Loop to create the comparison file There is some logic in the order of the If statements to basically capture all the lines between 2 empty lines
foreach( $Line in $OldReg){
    #$count++
    
    if ($line.Length -eq '0'){
        
        # Add $NewLine to the List variable. Newline should be a single line version of what previously was 2-1000+ lines
        $BeforeArray.Add($Newline.ToUpper())
        $Newline = ''
       
    }
    Else{
        
        $Newline = $NewLine + $Line

    }
}

#Compare the two files
Write-Host "Comparing the two hives"
$BeforeHashSet = [System.Collections.Generic.HashSet[string]]::new(
    [string[]] $BeforeArray,
    [System.StringComparer]::OrdinalIgnoreCase
)

$differences = $AfterArray.Where({ -not $BeforeHashSet.Contains($_) }) -replace (",", "-")
$differences = $differences.split("`n")

#Export to CSV
Write-Host "Exporting CSV"
$differences | Out-File -Filepath $ResultsFile