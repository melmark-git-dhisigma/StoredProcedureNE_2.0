USE [MelmarkNE]
GO
/****** Object:  StoredProcedure [dbo].[ClientStatisticalGraph]    Script Date: 5/27/2025 3:15:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ClientStatisticalGraph]
@GetStudID NVARCHAR(MAX) = NULL,
@GetLocationID NVARCHAR(MAX) = NULL,
@GetRaceID NVARCHAR(MAX) = NULL,
@GetActiveID VARCHAR(MAX) = NULL,
@ParamStudName VARCHAR(500) = NULL,
@ParamGender VARCHAR(500) = NULL,
@ParamLanguage VARCHAR(500) = NULL,
@ParamRace VARCHAR(500) = NULL,
@ParamLocation VARCHAR(500) = NULL,
@ParamProgram VARCHAR(500) = NULL,
@ParamPlacement VARCHAR(500) = NULL,
@ParamDepartment VARCHAR(500) = NULL,
@ParamActive VARCHAR(500) = NULL,
@ParamCity VARCHAR(500) = NULL,
@ParamState VARCHAR(500) = NULL,
@ParamStudRow VARCHAR(500) = NULL

AS
BEGIN
	
	SET NOCOUNT ON

	IF Object_id('tempdb..#TEMPTEST') IS NOT NULL
	DROP TABLE #TEMPTEST

	IF(@ParamStudName IS NULL) BEGIN SET @ParamStudName = 'true' END
	IF(@ParamGender IS NULL) BEGIN SET @ParamGender = 'true' END
	IF(@ParamLanguage IS NULL) BEGIN SET  @ParamLanguage = 'true' END
	IF(@ParamRace IS NULL) BEGIN SET  @ParamRace = 'true' END
	IF(@ParamLocation IS NULL) BEGIN SET  @ParamLocation = 'true' END
	IF(@ParamProgram IS NULL) BEGIN SET  @ParamProgram = 'true' END
	IF(@ParamPlacement IS NULL) BEGIN SET  @ParamPlacement = 'true' END
	IF(@ParamDepartment IS NULL) BEGIN SET  @ParamDepartment = 'true' END
	IF(@ParamActive IS NULL) BEGIN SET  @ParamActive = 'true' END
	IF(@ParamCity IS NULL) BEGIN SET  @ParamCity = 'true' END
	IF(@ParamState IS NULL) BEGIN SET  @ParamState = 'true' END 
	IF(@ParamStudRow IS NULL) BEGIN SET  @ParamStudRow = 'true' END 

	--Dynamic Query Section
	DECLARE @QuerySelectAlias VARCHAR(MAX)
	DECLARE @QuerySelect VARCHAR(MAX)
	DECLARE @QueryFrom VARCHAR(MAX)
	DECLARE @QueryJoin VARCHAR(MAX)
	DECLARE @QueryWhere VARCHAR(MAX)
	DECLARE @QueryAlias VARCHAR(MAX)
	DECLARE @QueryAliasWhere VARCHAR(MAX)
	DECLARE @QueryGroup VARCHAR(MAX)
	DECLARE @QueryOrder VARCHAR(MAX)
	DECLARE @FinalQuery NVARCHAR(MAX)
	DECLARE @QuerySeparator NVARCHAR(MAX)
	DECLARE @QueryOption NVARCHAR(MAX)

	DECLARE @ActiveQueryWhere VARCHAR(MAX)
	DECLARE @DischargeQueryWhere VARCHAR(MAX)
	DECLARE @InactiveQueryWhere VARCHAR(MAX)
	DECLARE @ActiveQuerySelect VARCHAR(MAX)
	DECLARE @DischargeQuerySelect VARCHAR(MAX)
	DECLARE @InactiveQuerySelect VARCHAR(MAX)

	SET @QuerySelectAlias = ''
	SET @QuerySelect = ''
	SET @QueryFrom = ''
	SET @QueryJoin = ''
	SET @QueryWhere = ''
	SET @QueryAlias = ''
	SET @QueryAliasWhere = ''
	SET @QueryGroup = ''
	SET @QueryOrder = ''
	SET @FinalQuery = ''
	SET @QuerySeparator = ','
	SET @QueryOption = ''

	SET @ActiveQueryWhere = ''
	SET @DischargeQueryWhere = ''
	SET @InactiveQueryWhere = ''
	SET @ActiveQuerySelect += 'SELECT'
	SET @DischargeQuerySelect += 'SELECT'
	SET @InactiveQuerySelect += 'SELECT'


	SET @QuerySelectAlias += 'SELECT * INTO #TEMPTEST FROM' + CHAR(10) +'('
	SET @QuerySelect += 'SELECT'
	SET @QueryFrom += CHAR(10) + 'FROM StudentPersonal ST'
	SET @QueryJoin += CHAR(10) + 'INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId'
	SET @QueryJoin += CHAR(10) + 'INNER JOIN Class CLS ON PLC.Location = CLS.ClassId'
	SET @QueryJoin += CHAR(10) + 'LEFT JOIN StudentAddresRel SAL ON SAL.StudentPersonalId = ST.StudentPersonalId' 
	SET @QueryJoin += CHAR(10) + 'LEFT JOIN AddressList ADL ON ADL.AddressId = SAL.AddressId'
	SET @QueryJoin += CHAR(10) + 'INNER JOIN LookUp LU ON LU.LookUpId = PLC.Department'
	IF(@GetActiveID ='A')
	BEGIN
	SET @QueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and (PLC.EndDate>=cast (GETDATE() as DATE) OR PLC.EndDate is null) and PLC.Status=1 AND LU.LookUpType = ''Department'' and St.StudentPersonalId not in (SELECT Distinct ST.StudentPersonalId
									FROM StudentPersonal ST
									 --join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
									WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
									ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
									WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'')) and St.StudentPersonalId not in (
									SELECT Distinct ST.StudentPersonalId
									FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
									INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
									WHERE ST.StudentType=''Client'' and PLC.Status=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 
	END
	--ELSE IF(@GetActiveID ='I')
	--BEGIN
	--SET @QueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Status=1 and St.StudentPersonalId in (SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST 
	--								--join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
	--								WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
	--								ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
	--								WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'')) and St.StudentPersonalId not in (
	--								SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
	--								INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
	--								WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 
	--END
	ELSE IF(@GetActiveID ='D')
	BEGIN
	SET @QueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'''
	--SET @QueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'''
	END
	ELSE
	BEGIN
	SET @QueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'''
	END

	--IF(@GetActiveID ='A,I')
	--BEGIN
	--SET @ActiveQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and (PLC.EndDate>=cast (GETDATE() as DATE) OR PLC.EndDate is null) and PLC.Status=1 and St.StudentPersonalId not in (SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST 
	--								--join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
	--								WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
	--								ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
	--								WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'') UNION 
	--								SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
	--								INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
	--								WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 

	--SET @InactiveQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Status=1 and St.StudentPersonalId in (SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST 
	--								--join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
	--								WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
	--								ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
	--								WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'')) and St.StudentPersonalId not in (
	--								SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
	--								INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
	--								WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 
	--END
	
	IF(@GetActiveID ='A,D')
	BEGIN
	SET @ActiveQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and (PLC.EndDate>=cast (GETDATE() as DATE) OR PLC.EndDate is null) and PLC.Status=1 AND LU.LookUpType = ''Department'' and St.StudentPersonalId not in (SELECT Distinct ST.StudentPersonalId
									FROM StudentPersonal ST 
									--join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
									WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
									ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
									WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'') UNION 
									SELECT Distinct ST.StudentPersonalId
									FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
									INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
									WHERE ST.StudentType=''Client'' and PLC.Status=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 

	SET @DischargeQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'''
	--SET @DischargeQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'''
	END

	--IF(@GetActiveID ='I,D')
	--BEGIN
	--SET @InactiveQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Status=1 and St.StudentPersonalId in (SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST 
	--								--join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
	--								WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
	--								ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
	--								WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'')) and St.StudentPersonalId not in (
	--								SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
	--								INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
	--								WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 

	--SET @DischargeQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'''
	--END

	--IF(@GetActiveID ='A,I,D')
	--BEGIN
	--SET @ActiveQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and (PLC.EndDate>=cast (GETDATE() as DATE) OR PLC.EndDate is null) and PLC.Status=1 and St.StudentPersonalId not in (SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST 
	--								--join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
	--								WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
	--								ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
	--								WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'') UNION 
	--								SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
	--								INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
	--								WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 

	--SET @InactiveQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Status=1 and St.StudentPersonalId in (SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST
	--								 --join ContactPersonal cp on cp.StudentPersonalId=ST.StudentPersonalId
	--								WHERE ST.StudentType=''Client'' and sT.ClientId>0 and ST.StudentPersonalId not in (SELECT Distinct
	--								ST.StudentPersonalId FROM StudentPersonal ST join Placement PLC on PLC.StudentPersonalId=ST.StudentPersonalId
	--								WHERE (PLC.EndDate is null or PLC.EndDate>=cast (GETDATE() as DATE)) and PLC.Status=1 and ST.StudentType=''Client'')) and St.StudentPersonalId not in (
	--								SELECT Distinct ST.StudentPersonalId
	--								FROM StudentPersonal ST INNER JOIN Placement PLC ON ST.StudentPersonalId = PLC.StudentPersonalId
	--								INNER JOIN Class CLS ON PLC.Location = CLS.ClassId
	--								WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'')' 

	--SET @DischargeQueryWhere += CHAR(10) + 'WHERE ST.StudentType=''Client'' and PLC.Discharge=1 and ST.PlacementStatus = ''D'' and CLS.ClassCd = ''DSCH'''
	--END
	
	SET @QueryAlias = ') AS ClientStudData' 
	--SET @QueryAliasWhere = CHAR(10) + 'WHERE'
	SET @QueryGroup += CHAR(10) + 'GROUP BY' + CHAR(0)	
	SET @QueryOrder += CHAR(10) + 'ORDER BY' + CHAR(0)	

	--PRINT LEN(@QuerySelect)
	--PRINT LEN(@QueryGroup)
	--PRINT LEN(@QueryOrder)
	--PRINT LEN(@QueryAliasWhere)

	IF((@ParamStudName = 'true' OR @ParamStudName = 'false') OR @ParamGender = 'true' OR @ParamLanguage = 'true' OR @ParamRace = 'true' )
	BEGIN
		IF(@ParamStudName = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				SET @QuerySelect += @QuerySeparator + CHAR(10) +'ST.StudentPersonalId, (ST.LastName+'',''+ST.FirstName) AS StudName' 				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudName, StudentPersonalId' END ELSE BEGIN SET @QueryGroup += 'StudName, StudentPersonalId' END
				IF (LEN(@QueryOrder) > 10) BEGIN SET @QueryOrder += @QuerySeparator + CHAR(0) + 'StudName' END ELSE BEGIN SET @QueryOrder += 'StudName' END
			END
			ELSE
			BEGIN
				SET @QuerySelect += CHAR(10) +'ST.StudentPersonalId, (ST.LastName+'',''+ST.FirstName) AS StudName'						
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudName, StudentPersonalId' END ELSE BEGIN SET @QueryGroup += 'StudName, StudentPersonalId' END
				IF (LEN(@QueryOrder) > 10) BEGIN SET @QueryOrder += @QuerySeparator + CHAR(0) + 'StudName' END ELSE BEGIN SET @QueryOrder += 'StudName' END
			END
		END
		ELSE
		BEGIN
			IF(@ParamStudName = 'false' AND @ParamGender = 'false' AND @ParamLanguage = 'false' AND @ParamRace = 'false' AND @ParamLocation = 'false'  AND @ParamProgram = 'false' AND @ParamPlacement = 'false' AND @ParamDepartment = 'false' AND @ParamActive = 'false' AND @ParamCity = 'false' AND @ParamState = 'false')
			BEGIN
				IF (LEN(@QuerySelect) > 6) 
				BEGIN
					SET @QuerySelect += @QuerySeparator + CHAR(10) +'ST.StudentPersonalId' 					
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudentPersonalId' END ELSE BEGIN SET @QueryGroup += 'StudentPersonalId' END
				END
				ELSE
				BEGIN
					SET @QuerySelect += CHAR(10) +'ST.StudentPersonalId'							
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudentPersonalId' END ELSE BEGIN SET @QueryGroup += 'StudentPersonalId' END
				END
			END
		END


		IF(@ParamGender = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				SET @QuerySelect += @QuerySeparator + CHAR(10) +'(CASE WHEN ST.Gender = 1 THEN ''Male'' ELSE ''Female'' END) AS Gender'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'Gender' END ELSE BEGIN SET @QueryGroup += 'Gender' END				
			END
			ELSE
			BEGIN
				SET @QuerySelect +=  CHAR(10) +'(CASE WHEN ST.Gender = 1 THEN ''Male'' ELSE ''Female'' END) AS Gender'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'Gender' END ELSE BEGIN SET @QueryGroup += 'Gender' END						
			END
		END

		IF(@ParamLanguage = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				SET @QuerySelect += @QuerySeparator + CHAR(10) +'ST.PrimaryLanguage AS StudLanguage'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudLanguage' END ELSE BEGIN SET @QueryGroup += 'StudLanguage' END 
			END
			ELSE
			BEGIN
				SET @QuerySelect +=  CHAR(10) +'ST.PrimaryLanguage AS StudLanguage'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudLanguage' END ELSE BEGIN SET @QueryGroup += 'StudLanguage' END 
			END
		END

		IF(@ParamRace = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				SET @QuerySelect += @QuerySeparator + CHAR(10) +'ST.RaceId, (SELECT LookupName FROM LookUp WHERE LookupId = ST.RaceId) AS RaceName'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'RaceId, RaceName' END ELSE BEGIN SET @QueryGroup += 'RaceId, RaceName' END  
			END
			ELSE
			BEGIN
				SET @QuerySelect +=  CHAR(10) +'ST.RaceId, (SELECT LookupName FROM LookUp WHERE LookupId = ST.RaceId) AS RaceName'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'RaceId, RaceName' END ELSE BEGIN SET @QueryGroup += 'RaceId, RaceName' END  
			END
		END
	END

	IF(@ParamCity = 'true' OR @ParamState = 'true')
	BEGIN
		IF(@ParamCity = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				--SET @QuerySelect += @QuerySeparator + CHAR(10) + 'ADL.City'
				SET @QuerySelect += @QuerySeparator + CHAR(10) +'(select top 1 city from AddressList al INNER JOIN StudentAddresRel spa on al.AddressId=spa.AddressId where spa.ContactPersonalId in(select ContactPersonalid from ContactPersonal where Status=1 and StudentPersonalId=SAL.StudentPersonalId and IsEmergency=1 and IsEmergencyP=1) and  spa.StudentPersonalId=SAL.StudentPersonalId)AS City'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'City' END ELSE BEGIN SET @QueryGroup += 'City' END
			END
			ELSE
			BEGIN
				--SET @QuerySelect += CHAR(10) + 'ADL.City'
				SET @QuerySelect += CHAR(10) +'(select top 1 city from AddressList al INNER JOIN StudentAddresRel spa on al.AddressId=spa.AddressId where spa.ContactPersonalId in(select ContactPersonalid from ContactPersonal where Status=1 and StudentPersonalId=SAL.StudentPersonalId and IsEmergency=1 and IsEmergencyP=1) and  spa.StudentPersonalId=SAL.StudentPersonalId)AS City'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'City' END ELSE BEGIN SET @QueryGroup += 'City' END
			END
		END

		IF(@ParamState = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				--SET @QuerySelect += @QuerySeparator + CHAR(10) + '(SELECT LookUpName FROM Lookup WHERE Lookupid = ADL.StateProvince AND LookupType =''State'') AS StudState'
				SET @QuerySelect += @QuerySeparator + CHAR(10) +'(SELECT LookUpName FROM Lookup WHERE Lookupid = (select top 1 StateProvince from AddressList al INNER JOIN StudentAddresRel spa on al.AddressId=spa.AddressId where spa.ContactPersonalId in(select ContactPersonalid from ContactPersonal where Status=1 and StudentPersonalId=SAL.StudentPersonalId and IsEmergency=1 and IsEmergencyP=1) and  spa.StudentPersonalId=SAL.StudentPersonalId) AND LookupType =''State'')AS StudState'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudState' END ELSE BEGIN SET @QueryGroup += 'StudState' END
			END
			ELSE
			BEGIN
				--SET @QuerySelect += CHAR(10) + '(SELECT LookUpName FROM Lookup WHERE Lookupid = ADL.StateProvince AND LookupType =''State'') AS StudState'
				SET @QuerySelect += CHAR(10) +'(SELECT LookUpName FROM Lookup WHERE Lookupid = (SELECT LookUpName FROM Lookup WHERE Lookupid = (select top 1 StateProvince from AddressList al INNER JOIN StudentAddresRel spa on al.AddressId=spa.AddressId where spa.ContactPersonalId in(select ContactPersonalid from ContactPersonal where Status=1 and StudentPersonalId=SAL.StudentPersonalId and IsEmergency=1 and IsEmergencyP=1) and  spa.StudentPersonalId=SAL.StudentPersonalId) AND LookupType =''State'')AS StudState'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudState' END ELSE BEGIN SET @QueryGroup += 'StudState' END
			END
		END
	END

	IF(@ParamLocation = 'true'  OR @ParamProgram = 'true' OR @ParamPlacement = 'true' OR @ParamDepartment = 'true' OR @ParamActive = 'true')
	BEGIN
		IF(@ParamLocation = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				--SET @QuerySelect += @QuerySeparator + CHAR(10) + ' PLC.Location AS LocationID, CLS.ClassName'		
				SET @QuerySelect += @QuerySeparator + CHAR(10) + '(SELECT STUFF((SELECT '', '' + CAST(Location AS VARCHAR(10)) FROM Placement WHERE StudentPersonalId = PLC.StudentPersonalId and status=1 
				and  PlacementId IN(SELECT PlacementId
FROM Placement p join StudentPersonal sp on sp.StudentPersonalId=p.StudentPersonalId
WHERE  
        sp.PlacementStatus <> ''A''
        OR (
            sp.PlacementStatus = ''A'' AND (
               NOT  EXISTS (
                    SELECT 1
                    FROM Placement AS sub
                    WHERE sub.StudentPersonalId = PLC.studentpersonalId
                      AND sp.PlacementStatus = ''A''
					  and sub.Status=1
                      AND (sub.EndDate IS NULL OR sub.EndDate >= CAST(GETDATE() AS DATE))
                )
            )
			)
			OR (sp.PlacementStatus = ''A'' AND (p.EndDate IS NULL OR p.EndDate >= CAST(GETDATE() AS DATE)))
        )
         FOR XML PATH('''')), 1, 2, '''')) AS LocationID,(SELECT STUFF(( SELECT '', '' + CONCAT(LookUpName, '' : '', ClassNameList)
                FROM (
                    SELECT DISTINCT pl.PlacementType, (
                        SELECT STUFF((
                                SELECT '', '' + cl.ClassName
                                FROM Class cl
                                INNER JOIN Placement pl2 ON pl2.Location = cl.ClassId
                                WHERE pl2.StudentPersonalId = PLC.StudentPersonalId and pl2.status=1
								and  PlacementId IN(SELECT PlacementId
FROM Placement p join StudentPersonal sp on sp.StudentPersonalId=p.StudentPersonalId
WHERE  
        sp.PlacementStatus <> ''A''
        OR (
            sp.PlacementStatus = ''A'' AND (
               NOT  EXISTS (
                    SELECT 1
                    FROM Placement AS sub
                    WHERE sub.StudentPersonalId = PLC.studentpersonalId
                      AND sp.PlacementStatus = ''A''
					  and sub.Status=1
                      AND (sub.EndDate IS NULL OR sub.EndDate >= CAST(GETDATE() AS DATE))
                )
            )
			)
			OR (sp.PlacementStatus = ''A'' AND (p.EndDate IS NULL OR p.EndDate >= CAST(GETDATE() AS DATE)))
        )
                                    AND pl2.PlacementType = pl.PlacementType
                                FOR XML PATH('''')), 1, 2, ''''
                            )
                        ) AS ClassNameList
                    FROM Placement pl
                    WHERE pl.StudentPersonalId = PLC.StudentPersonalId and pl.status=1
					and  PlacementId IN(SELECT PlacementId
FROM Placement p join StudentPersonal sp on sp.StudentPersonalId=p.StudentPersonalId
WHERE  
        sp.PlacementStatus <> ''A''
        OR (
            sp.PlacementStatus = ''A'' AND (
               NOT  EXISTS (
                    SELECT 1
                    FROM Placement AS sub
                    WHERE sub.StudentPersonalId = PLC.studentpersonalId
                      AND sp.PlacementStatus = ''A''
					  and sub.Status=1
                      AND (sub.EndDate IS NULL OR sub.EndDate >= CAST(GETDATE() AS DATE))
                )
            )
			)
			OR (sp.PlacementStatus = ''A'' AND (p.EndDate IS NULL OR p.EndDate >= CAST(GETDATE() AS DATE)))
        )
                ) AS Subquery
                INNER JOIN LookUp ON LookUp.lookupId = Subquery.PlacementType
                FOR XML PATH('''')
            ), 1, 2, ''''
        )) AS ClassName'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'LocationID, ClassName' END ELSE BEGIN SET @QueryGroup += 'LocationID, ClassName' END  			
			END
			ELSE
			BEGIN
				SET @QuerySelect += CHAR(10) + '(SELECT STUFF((SELECT '', '' + CAST(Location AS VARCHAR(10)) FROM Placement WHERE StudentPersonalId = PLC.StudentPersonalId and status=1
				and  PlacementId IN(SELECT PlacementId
FROM Placement p join StudentPersonal sp on sp.StudentPersonalId=p.StudentPersonalId
WHERE  
        sp.PlacementStatus <> ''A''
        OR (
            sp.PlacementStatus = ''A'' AND (
               NOT  EXISTS (
                    SELECT 1
                    FROM Placement AS sub
                    WHERE sub.StudentPersonalId = PLC.studentpersonalId
                      AND sp.PlacementStatus = ''A''
					  and sub.Status=1
                      AND (sub.EndDate IS NULL OR sub.EndDate >= CAST(GETDATE() AS DATE))
                )
            )
			)
			OR (sp.PlacementStatus = ''A'' AND (p.EndDate IS NULL OR p.EndDate >= CAST(GETDATE() AS DATE)))
        )
         FOR XML PATH('''')), 1, 2, '''')) AS LocationID,(SELECT STUFF(( SELECT '', '' + CONCAT(LookUpName, '' : '', ClassNameList)
                FROM (
                    SELECT DISTINCT pl.PlacementType, (
                        SELECT STUFF((
                                SELECT '', '' + cl.ClassName
                                FROM Class cl
                                INNER JOIN Placement pl2 ON pl2.Location = cl.ClassId
                                WHERE pl2.StudentPersonalId = PLC.StudentPersonalId and pl2.status=1
								and  PlacementId IN(SELECT PlacementId
FROM Placement p join StudentPersonal sp on sp.StudentPersonalId=p.StudentPersonalId
WHERE  
        sp.PlacementStatus <> ''A''
        OR (
            sp.PlacementStatus = ''A'' AND (
               NOT  EXISTS (
                    SELECT 1
                    FROM Placement AS sub
                    WHERE sub.StudentPersonalId = PLC.studentpersonalId
                      AND sp.PlacementStatus = ''A''
					  and sub.Status=1
                      AND (sub.EndDate IS NULL OR sub.EndDate >= CAST(GETDATE() AS DATE))
                )
            )
			)
			OR (sp.PlacementStatus = ''A'' AND (p.EndDate IS NULL OR p.EndDate >= CAST(GETDATE() AS DATE)))
        )
                                    AND pl2.PlacementType = pl.PlacementType
                                FOR XML PATH('''')), 1, 2, ''''
                            )
                        ) AS ClassNameList
                    FROM Placement pl
                    WHERE pl.StudentPersonalId = PLC.StudentPersonalId and and pl.status=1
					and  PlacementId IN(SELECT PlacementId
FROM Placement p join StudentPersonal sp on sp.StudentPersonalId=p.StudentPersonalId
WHERE  
        sp.PlacementStatus <> ''A''
        OR (
            sp.PlacementStatus = ''A'' AND (
               NOT  EXISTS (
                    SELECT 1
                    FROM Placement AS sub
                    WHERE sub.StudentPersonalId = PLC.studentpersonalId
                      AND sp.PlacementStatus = ''A''
					  and sub.Status=1
                      AND (sub.EndDate IS NULL OR sub.EndDate >= CAST(GETDATE() AS DATE))
                )
            )
			)
			OR (sp.PlacementStatus = ''A'' AND (p.EndDate IS NULL OR p.EndDate >= CAST(GETDATE() AS DATE)))
        )
                ) AS Subquery
                INNER JOIN LookUp ON LookUp.lookupId = Subquery.PlacementType
                FOR XML PATH('''')
            ), 1, 2, ''''
        )) AS ClassName'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'LocationID, ClassName' END ELSE BEGIN SET @QueryGroup += 'LocationID, ClassName' END  		
			END	
		END

	
		IF(@ParamProgram = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				--SET @QuerySelect += @QuerySeparator + CHAR(10) + 'PLC.Department AS Pgm, (SELECT LookupName FROM LookUp WHERE LookupId = PLC.Department) AS Program'
				SET @QuerySelect += @QuerySeparator + CHAR(10) + '
    (SELECT STUFF(
        (SELECT '', '' + CAST(Department AS VARCHAR(10))
         FROM Placement PLMT INNER JOIN LookUp LKP ON LKP.LookUpId = PLMT.Department
         WHERE StudentPersonalId = PLC.StudentPersonalId AND LKP.LookupType = ''Department''
         FOR XML PATH('''')), 1, 2, '''')) AS Pgm,
    (SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(LookupName AS VARCHAR(100))
         FROM LookUp look INNER JOIN Placement pl ON pl.Department = look.LookupId
         WHERE pl.StudentPersonalId = PLC.StudentPersonalId AND look.LookupType = ''Department''
         FOR XML PATH('''')), 1, 2, '''')) AS Program'				
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'Pgm, Program' END ELSE BEGIN SET @QueryGroup += 'Pgm, Program' END  
			END
			ELSE
			BEGIN
				SET @QuerySelect += CHAR(10) + '
    (SELECT STUFF(
        (SELECT '', '' + CAST(Department AS VARCHAR(10))
         FROM Placement PLMT INNER JOIN LookUp LKP ON LKP.LookUpId = PLMT.Department
         WHERE StudentPersonalId = PLC.StudentPersonalId AND PLMT.LookUpType = ''Department''
         FOR XML PATH('''')), 1, 2, '''')) AS Pgm,
    (SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(LookupName AS VARCHAR(100))
         FROM LookUp look INNER JOIN Placement pl ON pl.Department = look.LookupId
         WHERE pl.StudentPersonalId = PLC.StudentPersonalId AND look.LookupType = ''Department''
         FOR XML PATH('''')), 1, 2, '''')) AS Program'							
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'Pgm, Program' END ELSE BEGIN SET @QueryGroup += 'Pgm, Program' END  
			END	
		END

		IF(@ParamPlacement = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				--SET @QuerySelect += @QuerySeparator + CHAR(10) + 'PLC.PlacementType AS PlacementTypeId, (SELECT LookupName FROM LookUp WHERE LookupId = PLC.PlacementType) AS Placement_Type'	
				SET @QuerySelect += @QuerySeparator + CHAR(10) +
    '(SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(PlacementType AS VARCHAR(10))
         FROM Placement
         WHERE StudentPersonalId = PLC.StudentPersonalId
         FOR XML PATH('''')), 1, 2, '''')) AS PlacementTypeId,
    (SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(LookupName AS VARCHAR(100))
         FROM LookUp look INNER JOIN Placement pl ON pl.PlacementType = look.LookupId
         WHERE pl.StudentPersonalId = PLC.StudentPersonalId 
         FOR XML PATH('''')), 1, 2, '''')) AS Placement_Type'						
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'PlacementTypeId, Placement_Type' END ELSE BEGIN SET @QueryGroup += 'PlacementTypeId, Placement_Type' END  
			END
			ELSE
			BEGIN
				--SET @QuerySelect += CHAR(10) + 'PLC.PlacementType AS PlacementTypeId, (SELECT LookupName FROM LookUp WHERE LookupId = PLC.PlacementType) AS Placement_Type'		
						SET @QuerySelect += CHAR(10) +'(SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(PlacementType AS VARCHAR(10))
         FROM Placement
         WHERE StudentPersonalId = PLC.StudentPersonalId
         FOR XML PATH('''')), 1, 2, '''')) AS PlacementTypeId,
    (SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(LookupName AS VARCHAR(100))
         FROM LookUp look INNER JOIN Placement pl ON pl.PlacementType = look.LookupId
         WHERE pl.StudentPersonalId = PLC.StudentPersonalId 
         FOR XML PATH('''')), 1, 2, '''')) AS Placement_Type'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'PlacementTypeId, Placement_Type' END ELSE BEGIN SET @QueryGroup += 'PlacementTypeId, Placement_Type' END  
			END	
		END

		IF(@ParamDepartment = 'true')
		BEGIN
			IF (LEN(@QuerySelect) > 6) 
			BEGIN
				--SET @QuerySelect += @QuerySeparator + CHAR(10) + 'PLC.PlacementDepartment AS Departmt, (SELECT LookupName FROM LookUp WHERE LookupId = PLC.PlacementDepartment) AS DepartmentName'
				SET @QuerySelect += @QuerySeparator + CHAR(10) + '(SELECT STUFF(
        (SELECT '', '' + CAST(PlacementDepartment AS VARCHAR(10))
         FROM Placement
         WHERE StudentPersonalId = PLC.StudentPersonalId
         FOR XML PATH('''')), 1, 2, '''')) AS Departmt,
    (SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(LookupName AS VARCHAR(100))
         FROM LookUp look INNER JOIN Placement pl ON pl.PlacementDepartment = look.LookupId
         WHERE pl.StudentPersonalId = PLC.StudentPersonalId 
         FOR XML PATH('''')), 1, 2, '''')) AS DepartmentName'	
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'Departmt, DepartmentName' END ELSE BEGIN SET @QueryGroup += 'Departmt, DepartmentName' END  
			END
			ELSE
			BEGIN
				--SET @QuerySelect += CHAR(10) + 'PLC.PlacementDepartment AS Departmt, (SELECT LookupName FROM LookUp WHERE LookupId = PLC.PlacementDepartment) AS DepartmentName'				
				SET @QuerySelect += CHAR(10) +'(SELECT STUFF(
        (SELECT '', '' + CAST(PlacementDepartment AS VARCHAR(10))
         FROM Placement
         WHERE StudentPersonalId = PLC.StudentPersonalId
         FOR XML PATH('''')), 1, 2, '''')) AS Departmt,
    (SELECT DISTINCT STUFF(
        (SELECT DISTINCT '', '' + CAST(LookupName AS VARCHAR(100))
         FROM LookUp look INNER JOIN Placement pl ON pl.PlacementDepartment = look.LookupId
         WHERE pl.StudentPersonalId = PLC.StudentPersonalId 
         FOR XML PATH('''')), 1, 2, '''')) AS DepartmentName'
				IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'Departmt, DepartmentName' END ELSE BEGIN SET @QueryGroup += 'Departmt, DepartmentName' END  
			END	
		END

		IF(@ParamActive = 'true')
		BEGIN
			--IF(@GetActiveID ='A,I,D')
			--BEGIN
			--	IF (LEN(@QuerySelect) > 6) 
			--	BEGIN
			--		SET @ActiveQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
			--		IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END
			--	ELSE
			--	BEGIN
			--		SET @ActiveQuerySelect = @QuerySelect+ CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
			--		IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END

			--	--IF (LEN(@QuerySelect) > 6) 
			--	--BEGIN
			--	--	SET @InactiveQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''I'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
			--	--	--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	--END
			--	--ELSE
			--	--BEGIN
			--	--	SET @InactiveQuerySelect = @QuerySelect+ CHAR(10) + '''I'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
			--	--	--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	--END

			--	IF (LEN(@QuerySelect) > 6) 
			--	BEGIN
			--		SET @DischargeQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
			--		--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END
			--	ELSE
			--	BEGIN
			--		SET @DischargeQuerySelect = @QuerySelect+ CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
			--		--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END
			--END
			--IF(@GetActiveID ='A,I')
			--BEGIN
			--	IF (LEN(@QuerySelect) > 6) 
			--	BEGIN
			--		SET @ActiveQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
			--		IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END
			--	ELSE
			--	BEGIN
			--		SET @ActiveQuerySelect = @QuerySelect+ CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
			--		IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END

			--	--IF (LEN(@QuerySelect) > 6) 
			--	--BEGIN
			--	--	SET @InactiveQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''I'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
			--	--	--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	--END
			--	--ELSE
			--	--BEGIN
			--	--	SET @InactiveQuerySelect = @QuerySelect+ CHAR(10) + '''I'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
			--	--	--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	--END
			--END
			IF(@GetActiveID ='A,D')
			BEGIN
				IF (LEN(@QuerySelect) > 6) 
				BEGIN
					SET @ActiveQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
				ELSE
				BEGIN
					SET @ActiveQuerySelect = @QuerySelect+ CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END

				IF (LEN(@QuerySelect) > 6) 
				BEGIN
					SET @DischargeQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
					--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
				ELSE
				BEGIN
					SET @DischargeQuerySelect = @QuerySelect+ CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
					--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
			END
			--IF(@GetActiveID ='I,D')
			--BEGIN
				--IF (LEN(@QuerySelect) > 6) 
				--BEGIN
				--	SET @InactiveQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''I'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
				--	IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				--END
				--ELSE
				--BEGIN
				--	SET @InactiveQuerySelect = @QuerySelect+ CHAR(10) + '''I'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
				--	IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				--END

			--	IF (LEN(@QuerySelect) > 6) 
			--	BEGIN
			--		SET @DischargeQuerySelect = @QuerySelect+ @QuerySeparator + CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
			--		--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END
			--	ELSE
			--	BEGIN
			--		SET @DischargeQuerySelect = @QuerySelect+ CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
			--		--IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
			--	END
			--END

			ELSE IF(@GetActiveID ='A')
			BEGIN
				IF (LEN(@QuerySelect) > 6) 
				BEGIN
					SET @QuerySelect += @QuerySeparator + CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
				ELSE
				BEGIN
					SET @QuerySelect += CHAR(10) + '''A'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
			END
			ELSE
			BEGIN
				IF (LEN(@QuerySelect) > 6) 
				BEGIN
					SET @QuerySelect += @QuerySeparator + CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'				
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
				ELSE
				BEGIN
					SET @QuerySelect += CHAR(10) + '''D'' AS StudStatus' --'(CASE WHEN PLC.EndDate IS NULL THEN ''A'' ELSE ''D'' END) AS StudStatus'
					IF (LEN(@QueryGroup) > 10) BEGIN SET @QueryGroup += @QuerySeparator + CHAR(0) + 'StudStatus' END ELSE BEGIN SET @QueryGroup += 'StudStatus' END
				END
			END	
		END	
	END

	SET @QueryOption += CHAR(10) + 'OPTION (MAXRECURSION 5000)' + CHAR(10) + CHAR(10)

	--=================

	--### [Temp Section] ###

	
	DECLARE @StudData VARCHAR(MAX)	

	SET @StudData = ''	
	SET @StudData = CHAR(10) + 'SELECT * FROM #TEMPTEST'+ CHAR(10) + CHAR(10)

	--IF(@ParamStudRow = 'true')
	--BEGIN
	--	SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(StudentPersonalId) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	--END

	IF(@ParamStudRow = 'true' AND @ParamStudName = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(DISTINCT StudentPersonalId) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamGender = 'true')
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(Gender) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamLanguage = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(StudLanguage) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamRace = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(RaceId) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamLocation = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(LocationID) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamProgram = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(Pgm) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamPlacement = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(PlacementTypeId) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamDepartment = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(Departmt) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamActive = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(StudStatus) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamCity = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(City) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamState = 'true') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT COUNT(StudState) FROM #TEMPTEST) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END
	ELSE IF(@ParamStudRow = 'true' AND @ParamStudName = 'false' AND @ParamGender = 'false' AND @ParamLanguage = 'false' AND @ParamRace = 'false' AND @ParamLocation = 'false'  AND @ParamProgram = 'false' AND @ParamPlacement = 'false' AND @ParamDepartment = 'false' AND @ParamActive = 'false' AND @ParamCity = 'false' AND @ParamState = 'false') 
	BEGIN
		SET @StudData = CHAR(10) + 'SELECT * , ' + CHAR(10) + '(SELECT 0) AS StudRowCount FROM #TEMPTEST'+ CHAR(10) + CHAR(10)
	END

	--=================

	IF (LEN(@QueryOrder) > 10 AND @ParamStudName = 'true') 
	BEGIN
		IF(@GetActiveID ='A,D')
		BEGIN
			SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		END
		--ELSE IF(@GetActiveID ='A,I')
		--BEGIN
		--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		--END
		--ELSE IF(@GetActiveID ='I,D')
		--BEGIN
		--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		--END
		--ELSE IF(@GetActiveID ='A,I,D')
		--BEGIN
		--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		--END
		ELSE
		BEGIN
			SET @FinalQuery = CONCAT(@QuerySelectAlias,@QuerySelect,@QueryFrom,@QueryJoin,@QueryWhere,@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		END
	END
	ELSE
	BEGIN
		IF(@GetActiveID ='A,D')
		BEGIN
			SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOption,@StudData)
		END
		--ELSE IF(@GetActiveID ='A,I')
		--BEGIN
		--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		--END
		--ELSE IF(@GetActiveID ='I,D')
		--BEGIN
		--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		--END
		--ELSE IF(@GetActiveID ='A,I,D')
		--BEGIN
		--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
		--END
		ELSE
		BEGIN
			SET @FinalQuery = CONCAT(@QuerySelectAlias,@QuerySelect,@QueryFrom,@QueryJoin,@QueryWhere,@QueryAlias,@QueryGroup,@QueryOption,@StudData)
		END
	END

	--FIlter Conditions Section
	IF((@GetStudID IS NOT NULL AND @ParamStudName = 'true') OR (@GetLocationID IS NOT NULL AND @ParamLocation = 'true') OR (@GetRaceID IS NOT NULL AND @ParamRace = 'true') OR (@GetActiveID IS NOT NULL AND @ParamActive = 'true'))
	BEGIN
		--IF(@ParamStudName = 'true' OR @ParamRace = 'true' OR @ParamLocation = 'true' OR @ParamActive = 'true' )
		--BEGIN
			SET @QueryAliasWhere = CHAR(10) + 'WHERE'
		--END

		IF(@GetStudID IS NOT NULL AND @ParamStudName = 'true')
		BEGIN
			IF (LEN(@QueryAliasWhere) > 6) 
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'AND StudentPersonalId IN(SELECT * FROM Split('''+@GetStudID+''','',''))'
			END
			ELSE
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'StudentPersonalId IN(SELECT * FROM Split('''+@GetStudID+''','',''))'
			END
		END

		IF(@GetLocationID IS NOT NULL AND @ParamLocation = 'true')
		BEGIN
			IF (LEN(@QueryAliasWhere) > 6) 
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'AND LocationID IN(SELECT * FROM Split('''+@GetLocationID+''','',''))'
			END
			ELSE
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'LocationID IN(SELECT * FROM Split('''+@GetLocationID+''','',''))'
			END	
		END

		IF(@GetRaceID IS NOT NULL AND @ParamRace = 'true')
		BEGIN
			IF (LEN(@QueryAliasWhere) > 6) 
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'AND RaceId IN(SELECT * FROM Split('''+@GetRaceID+''','',''))'
			END
			ELSE
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'RaceId IN(SELECT * FROM Split('''+@GetRaceID+''','','')) '
			END
		END

		IF(@GetActiveID IS NOT NULL AND @ParamActive = 'true')
		BEGIN
			IF (LEN(@QueryAliasWhere) > 6) 
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'AND StudStatus IN(SELECT * FROM Split('''+@GetActiveID+''','',''))'
			END
			ELSE
			BEGIN
				SET @QueryAliasWhere += CHAR(0) + 'StudStatus IN(SELECT * FROM Split('''+@GetActiveID+''','',''))'
			END
		END

		--SET @FinalQuery = CONCAT(@QuerySelectAlias,@QuerySelect,@QueryFrom,@QueryJoin,@QueryWhere,@QueryAlias,@QueryAliasWhere,@QueryGroup,@QueryOrder,@QueryOption,@StudData)

		IF (LEN(@QueryOrder) > 10 AND @ParamStudName = 'true') 
		BEGIN
			IF(@GetActiveID ='A,D')
			BEGIN
				SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryAliasWhere,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			END
			--ELSE IF(@GetActiveID ='A,I')
			--BEGIN
			--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			--END
			--	ELSE IF(@GetActiveID ='I,D')
			--BEGIN
			--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			--END
			--ELSE IF(@GetActiveID ='A,I,D')
			--BEGIN
			--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			--END
			ELSE
			BEGIN
				SET @FinalQuery = CONCAT(@QuerySelectAlias,@QuerySelect,@QueryFrom,@QueryJoin,@QueryWhere,@QueryAlias,@QueryAliasWhere,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			END

		END
		ELSE
		BEGIN
			IF(@GetActiveID ='A,D')
			BEGIN
				SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,' )UNION( ',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryAliasWhere,@QueryGroup,@QueryOption,@StudData)
			END
			--ELSE IF(@GetActiveID ='A,I')
			--BEGIN
			--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			--END
			--ELSE IF(@GetActiveID ='I,D')
			--BEGIN
			--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere,') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			--END
			--ELSE IF(@GetActiveID ='A,I,D')
			--BEGIN
			--	SET @FinalQuery = CONCAT(@QuerySelectAlias,'('+@ActiveQuerySelect,@QueryFrom,@QueryJoin,@ActiveQueryWhere,') UNION (',@InactiveQuerySelect,@QueryFrom,@QueryJoin,@InactiveQueryWhere+') UNION (',@DischargeQuerySelect,@QueryFrom,@QueryJoin,@DischargeQueryWhere+')',@QueryAlias,@QueryGroup,@QueryOrder,@QueryOption,@StudData)
			--END
			ELSE
			BEGIN
				SET @FinalQuery = CONCAT(@QuerySelectAlias,@QuerySelect,@QueryFrom,@QueryJoin,@QueryWhere,@QueryAlias,@QueryAliasWhere,@QueryGroup,@QueryOption,@StudData)
			END
		END

	END

	--PRINT @QuerySelect
	--PRINT @QueryFrom
	--PRINT @QueryJoin
	--PRINT @QueryWhere
	--PRINT @QueryGroup
	--PRINT @QueryOrder
	PRINT @FinalQuery

	EXECUTE SP_EXECUTESQL @FinalQuery

END


GO
