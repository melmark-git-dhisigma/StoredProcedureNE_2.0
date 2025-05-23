USE [MelmarkNE]
GO
/****** Object:  StoredProcedure [dbo].[Coversheet_Academic_LessonDtls]    Script Date: 4/25/2025 1:12:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Coversheet_Academic_LessonDtls]
    @StartDate DATETIME,
    @ENDDate DATETIME,
    @Studentid INT,
    @SchoolId INT
AS
BEGIN
    SET nocount ON;

    DECLARE @SDate DATETIME,
            @EDate DATETIME,
            @SID INT,
            @School INT,
            @DATE14 DATETIME,
            @DATE15 DATETIME,
            @DATE28 DATETIME,
            @DATE29 DATETIME,
            @Date30 DATETIME,
            @DATE42 DATETIME,
            @DATE43 DATETIME,
            @DATE56 DATETIME,
            @Date57 DATETIME,
            @DATE70 DATETIME,
            @DATE71 DATETIME,
            @DATE84 DATETIME,
            @Date85 DATETIME,
            @DATE98 DATETIME


    SET @SDate = @StartDate
    SET @EDate = @ENDDate
    SET @SID = @Studentid
    SET @School = @SchoolId
    SET @DATE14 = DateADD(Day, 14, CONVERT(DATE, @SDate))
    SET @Date15 = DateADD(Day, 15, CONVERT(DATE, @SDate))
    SET @DATE28 = DateADD(Day, 28, CONVERT(DATE, @SDate))
    SET @DATE29 = DateADD(Day, 29, CONVERT(DATE, @SDate))
    SET @Date30 = DateADD(Day, 30, CONVERT(DATE, @SDate))
    SET @DATE42 = DateADD(Day, 42, CONVERT(DATE, @SDate))
    SET @DATE43 = DateADD(Day, 43, CONVERT(DATE, @SDate))
    SET @DATE56 = DateADD(Day, 56, CONVERT(DATE, @SDate))
    SET @DATE57 = DateADD(Day, 57, CONVERT(DATE, @SDate))
    SET @DATE70 = DateADD(Day, 70, CONVERT(DATE, @SDate))
    SET @DATE71 = DateADD(Day, 71, CONVERT(DATE, @SDate))
    SET @DATE84 = DateADD(Day, 84, CONVERT(DATE, @SDate))
    SET @DATE85 = DateADD(Day, 85, CONVERT(DATE, @SDate))
    SET @DATE98 = DateADD(Day, 98, CONVERT(DATE, @SDate))


    IF Object_id('tempdb..#temp_stdtsessionhdr') IS NOT NULL
        DROP TABLE #temp_stdtsessionhdr

    CREATE TABLE #temp_stdtsessionhdr
    (
        StdtSessionHdrId INT NULL,
        schoolid INT NULL,
        classid INT NULL,
        studentid INT NULL,
        ioaperc VARCHAR(100) NULL,
        endts DATETIME NULL,
        sessionstatuscd VARCHAR(1) NULL,
        lessonplanid INT NULL,
        ioaind VARCHAR(1) NULL,
        sessmisstrailstus VARCHAR(1) NULL,
        dstemphdrid INT NULL,
        createdon DATETIME NULL,
        currentpromptid INT NULL,
        currentsetid INT NULL,
        currentstepid INT NULL,
    ) ON [PRIMARY]
    CREATE INDEX dstemphdrid ON #temp_stdtsessionhdr (dstemphdrid);
    --CREATE INDEX createdon ON #temp_stdtsessionhdr(createdon);
    --CREATE INDEX startts ON #temp_stdtsessionhdr(startts);
    --CREATE INDEX lessonplanid ON #temp_stdtsessionhdr(lessonplanid);
    INSERT INTO #temp_stdtsessionhdr
    (
        StdtSessionHdrId,
        schoolid,
        studentid,
        classid,
        ioaperc,
        endts,
        sessionstatuscd,
        lessonplanid,
        ioaind,
        sessmisstrailstus,
        dstemphdrid,
        createdon,
        currentpromptid,
        currentsetid,
        currentstepid
    )
    SELECT StdtSessionHdrId,
           schoolid,
           studentid,
           StdtClassId,
           IOAPerc,
           EndTs,
           SessionStatusCd,
           LessonPlanId,
           IOAInd,
           SessMissTrailStus,
           dstemphdrid,
           createdon,
           currentpromptid,
           currentsetid,
           currentstepid
    FROM stdtsessionhdr
    WHERE CONVERT(DATE,EndTs)
          BETWEEN @SDate AND @EDate
          AND StudentId = @SID
          AND SchoolId = @School

    IF Object_id('tempdb..#temp_coversheet') IS NOT NULL
        DROP TABLE #temp_coversheet

    CREATE TABLE #temp_coversheet
    (
        dstemphdrid INT NULL,
        LessonPlanName VARCHAR(100) NULL,
        lessonplanid INT NULL,
        vernbr FLOAT NULL,
        lessonorder VARCHAR(100) NULL,
        GoalName VARCHAR(100) NULL,
        Objective3 VARCHAR(1) NULL,
        TypeOfInstruction VARCHAR(100) NULL,
        IOAPer1 VARCHAR(100) NULL,
        ProptLevel1 VARCHAR(100) NULL,
        set1 VARCHAR(MAX) NULL,
        IOAPer2 VARCHAR(100) NULL,
        ProptLevel2 VARCHAR(100) NULL,
        set2 VARCHAR(MAX) NULL,
        IOAPer3 VARCHAR(100) NULL,
        ProptLevel3 VARCHAR(100) NULL,
        set3 VARCHAR(MAX) NULL,
        IOAPer4 VARCHAR(100) NULL,
        ProptLevel4 VARCHAR(100) NULL,
        set4 VARCHAR(MAX) NULL,
        IOAPer5 VARCHAR(100) NULL,
        ProptLevel5 VARCHAR(100) NULL,
        set5 VARCHAR(MAX) NULL,
        IOAPer6 VARCHAR(100) NULL,
        ProptLevel6 VARCHAR(100) NULL,
        set6 VARCHAR(MAX) NULL,
        IOAPer7 VARCHAR(100) NULL,
        ProptLevel7 VARCHAR(100) NULL,
        set7 VARCHAR(MAX) NULL,
        NUM1 VARCHAR(100) NULL,
        MIS1 INT NULL,
        NUM2 VARCHAR(100) NULL,
        MIS2 INT NULL,
        MIS3 INT NULL,
        MIS4 INT NULL,
        MIS5 INT NULL,
        MIS6 INT NULL,
        Step1 VARCHAR(MAX) NULL,
        Step2 VARCHAR(MAX) NULL,
        Step3 VARCHAR(MAX) NULL,
        Step4 VARCHAR(MAX) NULL,
        Step5 VARCHAR(MAX) NULL,
        Step6 VARCHAR(MAX) NULL,
        Step7 VARCHAR(MAX) NULL,
        Stepid1 INT NULL,
        Stepid2 INT NULL,
        Stepid3 INT NULL,
        Stepid4 INT NULL,
        Stepid5 INT NULL,
        Stepid6 INT NULL,
        Stepid7 INT NULL,
        MIS7 INT NULL,
        NUM3 VARCHAR(100) NULL,
        NUM4 VARCHAR(100) NULL,
        NUM5 VARCHAR(100) NULL,
        NUM6 VARCHAR(100) NULL,
        NUM7 VARCHAR(100) NULL
    ) ON [PRIMARY]
    CREATE INDEX covdstemphdrid ON #temp_coversheet (dstemphdrid);
    CREATE INDEX createdon ON #temp_stdtsessionhdr (createdon);
    CREATE INDEX endts ON #temp_stdtsessionhdr (endts);
    CREATE INDEX lessonplanid ON #temp_stdtsessionhdr (lessonplanid);

    CREATE TABLE #StepData
    (
        dstemphdrid INT,
        endts DATETIME,
        currentsetid INT,
        currentstepid INT,
        StepName VARCHAR(MAX),
        dstempstepid INT
    );

    INSERT INTO #temp_coversheet
    (
        dstemphdrid,
        LessonPlanName,
        lessonplanid,
        vernbr,
        lessonorder,
        GoalName,
        Objective3,
        TypeOfInstruction,
        IOAPer1,
        ProptLevel1,
        set1,
        NUM1,
        MIS1
    )
    SELECT DISTINCT
        HDR.dstemphdrid,
        HDR.dstemplatename AS LessonPlanName,
        HDR.lessonplanid,
        HDR.vernbr,
        HDR.lessonorder,
        (Stuff(
         (
             SELECT ', ' + G.goalname
             FROM goal G
                 INNER JOIN goallprel GLP
                     ON GLP.goalid = G.goalid
             WHERE GLP.lessonplanid = HDR.lessonplanid
             FOR xml path('')
         ),
         1,
         2,
         ''
              )
        ) AS GoalName,
        (
            SELECT TOP 1
                objective3
            FROM stdtlessonplan
            WHERE goalid = GLP.goalid
                  AND lessonplanid = GLP.lessonplanid
                  AND studentid = @SID
            ORDER BY stdtiepid DESC
        ) AS Objective3,
        (
            SELECT lookupcode
            FROM lookup
            WHERE lookupid =
            (
                SELECT teachingprocid
                FROM dstemphdr
                WHERE dstemphdr.dstemphdrid = HDR.dstemphdrid
            )
        ) + '(' +
        (
            SELECT lookupname
            FROM lookup
            WHERE lookupid =
            (
                SELECT prompttypeid
                FROM dstemphdr
                WHERE dstemphdr.dstemphdrid = HDR.dstemphdrid
            )
        ) + ')' AS 'TypeOfInstruction',
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN CONVERT(DATE, @SDate) AND @DATE14
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ) AS 'IOAPer1',
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN CONVERT(DATE, @SDate) AND @DATE14
            ORDER BY endts DESC
        ) AS 'ProptLevel1',
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN CONVERT(DATE, @SDate) AND @DATE14
            ORDER BY endts DESC
        ) AS 'set1',
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE CONVERT(DATE, @SDate) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= @DATE14
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                     )
                            )
        ) AS NUM1,
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND CONVERT(DATE, @SDate) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE14)
							 AND studentid = @SID
                             AND schoolid = @School
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        ) MIS1
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )

    INSERT INTO #StepData
    SELECT s.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @SDate AND @Date14;


    UPDATE #temp_coversheet
    SET Step1 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid1 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    Update #temp_coversheet
    set IOAPer2 =
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE15 AND @DATE28
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ),
        ProptLevel2 =
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE15 AND @DATE28
            ORDER BY endts DESC
        ),
        set2 =
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE15 AND @DATE28
            ORDER BY endts DESC
        ),
        NUM2 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE CONVERT(DATE, @DATE15) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE28)
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                     )
                            )
        ),
        MIS2 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND CONVERT(DATE, @DATE15) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE28)
                             AND schoolid = @School
							  AND studentid = @SID
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    INSERT INTO #StepData
    SELECT H.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
        JOIN dstemphdr H
            ON S.dstemphdrid = H.dstemphdrid
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @DATE15 AND @Date28;


    UPDATE #temp_coversheet
    SET Step2 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid2 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    Update #temp_coversheet
    set IOAPer3 =
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @Date30 AND @DATE42
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ),
        ProptLevel3 =
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @Date30 AND @DATE42
            ORDER BY endts DESC
        ),
        set3 =
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @Date30 AND @DATE42
            ORDER BY endts DESC
        ),
        MIS3 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND @Date29 <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= @Date42
                             AND schoolid = @School
							  AND studentid = @SID
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        ),
        NUM3 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE @Date29 <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= @Date42
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                               AND HDR.DSTempHdrId = DSTempHdr.DSTempHdrId
                     )
                            )
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    INSERT INTO #StepData
    SELECT H.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
        JOIN dstemphdr H
            ON S.dstemphdrid = H.dstemphdrid
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @Date29 AND @Date42;


    UPDATE #temp_coversheet
    SET Step3 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid3 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    Update #temp_coversheet
    set IOAPer4 =
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE43 AND @DATE56
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ),
        ProptLevel4 =
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE43 AND @DATE56
            ORDER BY endts DESC
        ),
        set4 =
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE43 AND @DATE56
            ORDER BY endts DESC
        ),
        MIS4 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND CONVERT(DATE, @DATE43) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE56)
                             AND schoolid = @School
							  AND studentid = @SID
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        ),
        NUM4 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE CONVERT(DATE, @DATE43) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE56)
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                     )
                            )
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    INSERT INTO #StepData
    SELECT H.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
        JOIN dstemphdr H
            ON S.dstemphdrid = H.dstemphdrid
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @DATE43 AND @Date56;


    UPDATE #temp_coversheet
    SET Step4 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid4 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    Update #temp_coversheet
    set IOAPer5 =
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE57 AND @DATE70
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ),
        ProptLevel5 =
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE57 AND @DATE70
            ORDER BY endts DESC
        ),
        set5 =
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE57 AND @DATE70
            ORDER BY endts DESC
        ),
        MIS5 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND CONVERT(DATE, @DATE57) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE70)
                             AND schoolid = @School
							  AND studentid = @SID
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        ),
        NUM5 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE CONVERT(DATE, @DATE57) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE70)
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                     )
                            )
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    INSERT INTO #StepData
    SELECT H.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
        JOIN dstemphdr H
            ON S.dstemphdrid = H.dstemphdrid
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @DATE57 AND @Date70;


    UPDATE #temp_coversheet
    SET Step5 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid5 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    Update #temp_coversheet
    set IOAPer6 =
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE71 AND @DATE84
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ),
        ProptLevel6 =
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE71 AND @DATE84
            ORDER BY endts DESC
        ),
        set6 =
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE71 AND @DATE84
            ORDER BY endts DESC
        ),
        MIS6 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND CONVERT(DATE, @DATE71) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE84)
                             AND schoolid = @School
							  AND studentid = @SID
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        ),
        NUM6 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE CONVERT(DATE, @DATE71) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE84)
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                     )
                            )
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    INSERT INTO #StepData
    SELECT H.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
        JOIN dstemphdr H
            ON S.dstemphdrid = H.dstemphdrid
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @DATE71 AND @Date84;


    UPDATE #temp_coversheet
    SET Step6 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid6 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    Update #temp_coversheet
    set IOAPer7 =
        (
            SELECT TOP 1
                ioaperc
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE85 AND @DATE98
                  AND ioaperc IS NOT NULL
            ORDER BY endts DESC
        ),
        ProptLevel7 =
        (
            SELECT TOP 1
                (
                    SELECT lookupname FROM lookup WHERE lookupid = currentpromptid
                ) AS 'PromptLevel'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE85 AND @DATE98
            ORDER BY endts DESC
        ),
        set7 =
        (
            SELECT TOP 1
                (
                    SELECT setcd FROM dstempset WHERE dstempsetid = currentsetid
                ) AS 'SetName'
            FROM #temp_stdtsessionhdr
            WHERE #temp_stdtsessionhdr.dstemphdrid = HDR.dstemphdrid
                  AND CONVERT(DATE, endts)
                  BETWEEN @DATE85 AND @DATE98
            ORDER BY endts DESC
        ),
        MIS7 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE lessonplanid = HDR.lessonplanid
                             AND CONVERT(DATE, @DATE85) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE98)
                             AND schoolid = @School
							  AND studentid = @SID
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'Y'
                   )
                          )
        ),
        NUM7 =
        (
            SELECT CONVERT(   VARCHAR(100),
                   (
                       SELECT Count(*)
                       FROM #temp_stdtsessionhdr
                       WHERE CONVERT(DATE, @DATE85) <= CONVERT(DATE, endts)
                             AND CONVERT(DATE, endts) <= CONVERT(DATE, @DATE98)
                             AND studentid = @SID
                             AND schoolid = @School
                             AND lessonplanid = HDR.lessonplanid
                             AND sessionstatuscd = 'S'
                             AND ioaind = 'N'
                             AND sessmisstrailstus = 'N'
                   )
                          ) + '/'
                   + CONVERT(   VARCHAR(100),
                     (
                         SELECT TOP 1
                             nooftimestried
                         FROM dstemphdr
                         WHERE dstemphdr.lessonplanid = HDR.lessonplanid
                               AND statusid IN (
                                                   SELECT lookupid
                                                   FROM lookup
                                                   WHERE lookuptype = 'TemplateStatus'
                                                         AND lookupname IN ( 'Approved', 'Maintenance' )
                                               )
                               AND studentid = @SID
                     )
                            )
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    INSERT INTO #StepData
    SELECT H.dstemphdrid,
           S.endts,
           S.currentsetid,
           S.currentstepid,
           CASE
               WHEN D.stepcd IS NULL
                    OR D.stepcd = '' THEN
                   D.stepname
               ELSE
                   D.stepcd
           END AS StepName,
           D.dstempstepid
    FROM #temp_stdtsessionhdr S
        JOIN dstempstep D
            ON S.currentsetid = D.dstempsetid
               AND S.currentstepid = D.sortorder
        JOIN dstemphdr H
            ON S.dstemphdrid = H.dstemphdrid
    WHERE CONVERT(DATE, S.endts)
    BETWEEN @DATE85 AND @Date98;


    UPDATE #temp_coversheet
    SET Step7 =
        (
            SELECT TOP 1
                StepName
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        ),
        Stepid7 =
        (
            SELECT TOP 1
                dstempstepid
            FROM #StepData
            WHERE #StepData.dstemphdrid = HDR.dstemphdrid
        )
    FROM dstemphdr HDR
        INNER JOIN goallprel GLP
            ON HDR.lessonplanid = GLP.lessonplanid
        INNER JOIN goal G
            ON GLP.goalid = G.goalid
    WHERE HDR.studentid = @SID
          AND HDR.statusid IN (
                                  SELECT lookupid
                                  FROM lookup
                                  WHERE lookuptype = 'TemplateStatus'
                                        AND lookupname IN ( 'Approved', 'Maintenance' )
                              )
          AND #temp_coversheet.dstemphdrid = HDR.DSTempHdrId;


    TRUNCATE TABLE #StepData;

    select *
    from #temp_coversheet

    DROP INDEX covdstemphdrid ON #temp_coversheet;
    DROP INDEX createdon ON #temp_stdtsessionhdr;
    DROP INDEX endts ON #temp_stdtsessionhdr;
    DROP INDEX lessonplanid ON #temp_stdtsessionhdr;

    DROP TABLE #temp_stdtsessionhdr
    DROP TABLE #temp_coversheet
    DROP TABLE #StepData
END


GO
