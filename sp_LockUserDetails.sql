
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[sp_LockUserDetails]
AS
DECLARE @Spid As Int
DECLARE @Blocked As Int
DECLARE @Id As Int
BEGIN
	
	CREATE TABLE #Inputbuffer(EventType NVARCHAR(30) NULL,Parameters INT NULL,EventInfo NVARCHAR(255) NULL)
	
	SELECT @Spid=(SELECT MIN(spid) FROM master..sysprocesses WHERE blocked<>0 and spid<>blocked)
	
	print @spid

	WHILE ISNULL(@Spid,0)<>0
	BEGIN		
		SELECT @Blocked=(Select MAX(Blocked) FROM master..sysprocesses WHERE spid=@Spid and spid<>blocked)	 
		SELECT @Spid=@Blocked 
		IF @Spid<>0 
			SELECT @Id=@Spid
	END

	IF @Id>0
	  INSERT INTO #Inputbuffer EXEC('DBCC INPUTBUFFER('+@Id+')')

	
	--Locking user
	SELECT a.spid,a.blocked,a.hostname,a.status,a.cmd, LockedUSersCount =(Select Count(spid) From master..sysprocesses Where blocked<>0) ,b.*
	FROM master..sysprocesses a, #Inputbuffer b WHERE Spid=@Id 
 	
	--Locked users
	SELECT spid,blocked,hostname,nt_username,waittime/1000 AS WTime,hostprocess,status,cmd,cpu,memusage  
	FROM master..sysprocesses
	WHERE blocked<>0 ORDER BY waittime/1000 DESC
	

	DROP TABLE #Inputbuffer
END