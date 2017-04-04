    $aFolder="C:\Askida\Build\Net\hydrosolution\api\0.2.0.107" ;
    cd $aFolder ;
    $openDir="CodeCoverage" ;
    echo "mkdir $openDir" ;
    mkdir $openDir;
    $openCov="packages\OpenCover.4.6.519\tools\OpenCover.Console.exe" ;
    $openUsr="user" ;
    $openTgt="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe" ;
    $openTar="BusinessLogic.Test\bin\Debug\BusinessLogic.Test.dll DataModels.Test\bin\Debug\DataModels.Test.dll API.Test\bin\Debug\API.Test.dll" ;
    $openLog="trx" ;
    $openDiag="$openDir\API.trx" ;
    $openFilter="+[DataModels*]* +[API*]* +[BusinessLogic*]* -[BusinessLogic.Test]* -[API.Test]* -[DataModels.Test]*";
    $openOut="$openDir\API.xml" ;
    $openGenerator="packages\ReportGenerator.2.5.6\tools\ReportGenerator.exe" ;
    $openTarDir="$openDir\Html" ;
    $openLaunch="$openDir\Html\index.htm" ;
    Invoke-Expression -Command 'cmd.exe /c $openCov -register:"$openUsr" -target:"$openTgt" -targetargs:"$openTar /logger:$openLog /Diag:$openDiag" -filter:$openFilter -mergebyhash -skipautoprops -output:"$openOut" '
    Invoke-Expression -Command 'cmd.exe /c $openGenerator -reports:"$openOut" -targetdir:"$openTarDir" '
