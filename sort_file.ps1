$Folder = 'm:\example\'
$sumfile = $Folder + 'summary.xml'
#$destfold = 'd:\123\'
$destfold = 'm:\example\example\'



while($true){

    Write-Host("$(Get-Date)    Начало обработки файлов")
    
    $dirEntries = Get-ChildItem $Folder

    foreach($dir in $dirEntries)
    {
	    
	    $sumfile = $dir.FullName + '\summary.xml'	
	
	    if ([System.IO.File]::Exists($sumfile))
	    {
		    try {
			    [XML]$sumxml = Get-Content $sumfile
             
			    if ($sumxml.GUARANTEES.GUARANTEE.BEGIN.GUARANTEENUM)
			    {	
				    $guanum = $sumxml.GUARANTEES.GUARANTEE.BEGIN.GUARANTEENUM
				    $guainn = $sumxml.GUARANTEES.GUARANTEE.BEGIN.PRINCIPAL.INN
			    }
			    elseif ($sumxml.GUARANTEES.GUARANTEE.PRINCIPAL.CLIENT_ORG.INN)
			    {
				    $guanum = $sumxml.GUARANTEES.GUARANTEE.GUARANTEE_UIN
				    $guainn = $sumxml.GUARANTEES.GUARANTEE.PRINCIPAL.CLIENT_ORG.INN
			    }
			    else
			    {
				    $guanum = $sumxml.GUARANTEES.GUARANTEE.GUARANTEENUM[0].Split("-")[0]
				    $guainn = $sumxml.GUARANTEES.PRINCIPAL.INN
			    }
		    }
		    catch {
                
			    Write-Output('Error XML ' + $di.FullName)
			    $a = Select-String -path $sumfile -Pattern "<GUARANTEENUM>" -List
			    $b = $a.Line
			    $guanum = $b.Substring($b.IndexOf("<GUARANTEENUM>") + 14,$b.IndexOf("</GUARANTEENUM>")-$b.IndexOf("<GUARANTEENUM>") - 14)
			    $a = Select-String -path $sumfile -Pattern "<INN>" -List
			    $b = $a.Line
			    $guainn = $b.Substring($b.IndexOf("<INN>") + 5,$b.IndexOf("</INN>")-$b.IndexOf("<INN>") - 5)
		    }
		    if ($dir.Name -eq $guanum)
		    {		
			    Write-OutPut ($dir.FullName + ' ' + $guanum + ' ' + $guainn)
		    }
		    else
		    {
	         	    Write-OutPut ('Error ' + $dir.FullName)
			    continue
		    }
		    $destfoldtemp = $destfold + $guainn + '\' + $guanum + '\'	
		    [IO.Directory]::CreateDIrectory($destfoldtemp)
		    Get-ChildItem -Path ($dir.FullName + '\*') -Recurse | Move-Item -Destination $destfoldtemp -Force 
		    Remove-Item -Path $dir.FullName -Recurse -Confirm:$false
	    }

    }

    Write-Host("$(Get-Date)    Завершаю обработку файлов")
    [System.GC]::Collect()
    Write-Host("$(Get-Date)    Пауза 4 часа")
    Start-Sleep 14400

}
