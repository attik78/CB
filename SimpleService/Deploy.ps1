Import-Module SQLPS -DisableNameChecking
################################
# variables:
$serviceVer = "1.0"
$serviceName = "Simple Service"
$serviceRoot = "c:\working\SimpleService\"
$serviceBinSource = "c:\working\SimpleService\_sln\SimpleService\bin\Release\"
$databaseName = "attila"
$server = "demosqluser"
$backupPath = "D:\MSSQL\BACKUP\{1}.{0}.bak" -f [DateTime]::UtcNow.ToFileTime(),$databaseName
$tablesCmd = "
CREATE TABLE [dbo].[InvItem](
	[InvItemId] [int] NOT NULL  primary key ,
	[InvItemName] [nvarchar](50) NOT NULL,
	[InvItemPrice] [money] NOT NULL,
	[InvId] [int] NOT NULL)

CREATE TABLE [dbo].[Inv](
	[InvId] [int] NOT NULL  primary key,
	[InvDate] [datetime] NOT NULL,
	[CustId] [int] NOT NULL)

CREATE TABLE [dbo].[Cust](
	[CustId] [int] NOT NULL  primary key,
	[CustName] [nvarchar](50) NOT NULL)
"

$DropCmd = "
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'{0}'
ALTER DATABASE {0} SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE {0}
" -f $databaseName 
################################



$db = Get-SqlDatabase  -Name $databaseName -ServerInstance $server -ErrorAction SilentlyContinue

if ($db -ne $null)
{
	Backup-SqlDatabase -Database $databaseName -BackupAction Database -BackupFile $backupPath -ServerInstance $server -NoRecovery -NoRewind  -SkipTapeHeader -Initialize
	Invoke-Sqlcmd -Database master -ServerInstance $server -Query $DropCmd

}

# when you create DB in real life there are many params which should be setup (e.g. file location)
Invoke-Sqlcmd -Database master -ServerInstance $server -Query ("CREATE DATABASE {0}"  -f $databaseName)
Invoke-Sqlcmd -Database $databaseName -ServerInstance $server -Query $tablesCmd

$serviceBinDest = ("{0}{1}\" -f $serviceRoot,$serviceVer) # beter is use combine path from .Net
$serviceRunPath = ("{0}{1}\" -f $serviceRoot,"bin") # beter is use combine path from .Net

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
#Pre-deploy binaries

if ($service -ne $null)
{
	try
	{
		stop-service -Name $service.Name
	}
	catch 
	{
		"Cannot stop service {0}" -f $service.Name
	}
}

if (Test-Path $serviceBinDest )
{
	rmdir $serviceBinDest -Recurse -Force
}

md $serviceBinDest
copy  ($serviceBinSource + "*")  $serviceBinDest 

if ($service -eq $null)
{
	echo "Service doesn't not exist and will be installed"
	New-Service -BinaryPathName ($serviceRunPath + "SimpleService.exe") -Name $serviceName -StartupType Automatic -ErrorAction SilentlyContinue 
	$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue	
}

if (Test-Path ($serviceRunPath))
{
cmd /C ("rmdir {0}" -f $serviceRunPath)
}
cmd /C ("mklink /J {0} {1}" -f $serviceRunPath,$serviceBinDest)
$service.Start()
	



