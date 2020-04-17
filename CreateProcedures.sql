USE [CurrencyTracker]
GO

--procedure for getting Crew objects
CREATE OR ALTER PROCEDURE sp_getCrew
AS
BEGIN TRY
    SELECT (SELECT * FROM Crew
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 
GO

--procedure for getting Activity objects
CREATE OR ALTER PROCEDURE sp_getActivities
AS
BEGIN TRY
    SELECT (SELECT * FROM Activity
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--procedure for getting Bulletin objects
CREATE OR ALTER PROCEDURE sp_getBulletins
as 
BEGIN TRY
    SELECT (SELECT * FROM Bulletin
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--get all of the roles
CREATE OR ALTER PROCEDURE sp_getRoles
as 
BEGIN TRY
    SELECT (SELECT * FROM Role
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--get all of the Sites
CREATE OR ALTER PROCEDURE sp_getSites
as 
BEGIN TRY
    SELECT (SELECT * FROM Site
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--get all requirements
CREATE OR ALTER PROCEDURE sp_getRequirements
as 
BEGIN TRY
    SELECT (SELECT * FROM Requirement
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--get Users Logs
CREATE OR ALTER PROCEDURE sp_getAllLogsForUser
@CrewId INT
as 
BEGIN TRY
    SELECT (select l.*,
        JSON_QUERY((select TOP 1 * 
        from Activity a
        where a.ID = l.ActivityId 
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Activity],
        JSON_QUERY((select TOP 1 * 
        from Crew c
        where c.ID = l.CrewId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Crew],
        JSON_QUERY((select TOP 1 *,
            JSON_QUERY((select TOP 1 *,
                JSON_QUERY((select TOP 1* 
                from Site s 
                where s.ID = m.SiteId
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Site]
            from Mission m
            where m.ID = f.MissionId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Mission],
            JSON_QUERY((select TOP 1 * 
            from Role r
            where r.ID = f.RoleID
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Role]
        from FlightLog f
        where f.ID = l.Id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [FlightLog]
    from [Log] l
    Where l.CrewID = @CrewId
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--get log for ID
CREATE OR ALTER PROCEDURE sp_getLogForId
@Id INT
AS 
BEGIN TRY
    SELECT (select JSON_QUERY((SELECT TOP 1 l.*,
        JSON_QUERY((select TOP 1 * 
        from Activity a
        where a.ID = l.ActivityId 
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Activity],
        JSON_QUERY((select TOP 1 * 
        from Crew c
        where c.ID = l.CrewId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Crew],
        JSON_QUERY((select TOP 1 *,
            JSON_QUERY((select TOP 1 *,
                JSON_QUERY((select TOP 1* 
                from Site s 
                where s.ID = m.SiteId
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Site]
            from Mission m
            where m.ID = f.MissionId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Mission],
            JSON_QUERY((select TOP 1 * 
            from Role r
            where r.ID = f.RoleID
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Role]
        from FlightLog f
        where f.ID = l.Id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [FlightLog]
    from [Log] l
    WHERE l.ID = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 
GO



--get the unacknowledged bulletins of a particular user
CREATE OR ALTER PROCEDURE sp_getUnacknowlegedBulletins
@CrewId INT
AS
BEGIN TRY
    SELECT (SELECT b.* 
    FROM Bulletin b
    LEFT JOIN (
        SELECT b.*
        FROM Bulletin b 
        JOIN Acknowledges a on b.ID = a.BulletinId
        WHERE a.CrewId = @CrewId
    ) AS acknowledgedBulletins on acknowledgedBulletins.id = b.Id
    where acknowledgedBulletins.ID is null
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

Go

--gets the current roles for a Crew Member
CREATE OR ALTER PROCEDURE sp_getRolesForCrew
@CrewId INT 
AS
BEGIN TRY
    SELECT (SELECT c.*,
        (SELECT * 
        FROM CrewRoles cr
        JOIN Role r ON cr.RoleId = r.ID
        WHERE cr.CrewId = c.ID
        FOR JSON PATH) as [Roles]
    FROM Crew c 
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

Go

--gets the roles, the requirements associated with them and the activities that satisfy
--the requirement, used for the admin page to set up roles/requirement/activity relationships

CREATE OR ALTER PROCEDURE sp_getRoleRequirementsActivities
AS
BEGIN TRY
    SELECT (SELECT R.*,
        (SELECT re.* 
            ,(SELECT distinct a.*
            FROM RequirementActivities ra
            JOIN Activity a ON a.ID = ra.ActivityId
            WHERE RR.RequirementId = ra.RequirementId
            FOR JSON PATH) as [Activities]
        FROM RoleRequirements rr
        JOIN Requirement re on re.ID = rr.RequirementID
        WHERE RR.RoleID = R.ID
        FOR JSON PATH) as [Requirements]
    FROM ROLE R
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

Go

--gets a mission for a mission ID and all of the logs associated with it
CREATE OR ALTER PROCEDURE sp_getMission
@MissionId INT
AS
BEGIN TRY
    SELECT( select JSON_QUERY((Select m.*,
        JSON_QUERY((SELECT TOP 1 * 
        FROM Site s
        WHERE s.ID = m.siteId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Site],
        (SELECT f.*,
            JSON_QUERY((Select TOP 1 l.*,
                JSON_QUERY((select TOP 1 * 
                from Activity a
                where a.ID = l.ActivityId 
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Activity],
                JSON_QUERY((select TOP 1* 
                from Crew c
                where c.ID = l.CrewId
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Crew]
            FROM [Log] l
            WHERE l.ID = f.ID
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Log],
            JSON_QUERY((select TOP 1 * 
            from Role r
            where r.ID = f.RoleID
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [Role]
        from FlightLog f
        WHERE f.missionId = m.ID
        FOR JSON PATH) as [FlightLogs]
    FROM Mission m
    where m.ID = @MissionId
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_getCurrency
@CrewId INT
AS 
BEGIN TRY
    DECLARE @RequirementTable TABLE (requirementID INT, DaysValid INT, NeverExpiresFlag INT)
    DECLARE @CurrencyTable TABLE (RequirementName VARCHAR(255), CurrentBool INT, ExpireDate Date)
    DECLARE @TotalsTable TABLE (Launches INT, Recoveries INT, LowPasses INT, MissionTime INT)
    DECLARE @RequirementId INT, @DaysValid INT, @NeverExpiresFlag INT, @Test INT
    DECLARE @NumberOfRequiredLaunches INT, @NumberOfRequiredRecoveries INT, @RequiredLowPass INT, @RequiredMissionTime INT
    DECLARE @MaxDate DATE

    --get the requirements requirement by the user
    INSERT INTO @RequirementTable
    SELECT DISTINCT re.Id, re.DaysValid, re.NeverExpiresFlag
    FROM Crew c
    JOIN CrewRoles cr on Cr.CrewId = c.ID
    JOIN [Role] r on r.ID = cr.RoleId
    JOIN RoleRequirements rr on r.ID = rr.RoleID
    JOIN Requirement re on re.ID = rr.RequirementID
    Where c.Id = @CrewId

    WHILE (Select Count(*) FROM @RequirementTable) > 0
    BEGIN
        SELECT TOP 1 @RequirementId = requirementId From @RequirementTable
        SELECT TOP 1 @DaysValid = DaysValid From @RequirementTable
        SELECT TOP 1 @NeverExpiresFlag = NeverExpiresFlag From @RequirementTable

        --deal with the requirements that never expire
        IF @NeverExpiresFlag = 1
        BEGIN
            SELECT @Test = ra.RequirementId
            FROM RequirementActivities ra
            JOIN Activity a
            ON a.ID = ra.ActivityId
            JOIN [Log] l 
            ON l.CrewID = @CrewId AND l.ActivityId = a.ID
            WHERE ra.RequirementId = @RequirementId

            IF @Test IS NOT NULL
            BEGIN
                INSERT INTO @CurrencyTable VALUES((select name from Requirement where ID = @RequirementId), 1, NULL)
            END
            ELSE 
            BEGIN
                INSERT INTO @CurrencyTable VALUES((select name from Requirement where ID = @RequirementId), 0, NULL)
            END
        END
        ELSE 
        BEGIN
            Select @Test = fr.ID
            from FlightRequirement fr
            WHERE fr.ID = @RequirementId

            --calculate if the crew member has fulfilled the summed requirements for flight logs
            IF @TEST IS NOT NULL
            BEGIN 
                SELECT TOP 1 @NumberOfRequiredLaunches = RequiredLaunches FROM FlightRequirement WHERE ID = @RequirementId
                SELECT TOP 1 @NumberOfRequiredRecoveries = RequiredRecoveries FROM FlightRequirement WHERE ID = @RequirementId
                SELECT TOP 1 @RequiredLowPass = RequiredLowPass FROM FlightRequirement WHERE ID = @RequirementId
                SELECT TOP 1 @RequiredMissionTime = RequiredMissionTime FROM FlightRequirement WHERE ID = @RequirementId

                INSERT INTO @TotalsTable
                SELECT SUM(ISNULL(f.Launch,0)), SUM(ISNULL(f.[Recovery],0)), SUM(ISNULL(f.NumberOfLowPasses,0)), SUM(ISNULL(f.MissionTime,0))
                FROM RequirementActivities ra
                JOIN Activity a
                ON a.ID = ra.ActivityId
                JOIN [Log] l
                ON l.CrewID = @CrewId AND l.ActivityId = a.ID
                JOIN FlightLog f
                ON f.ID = l.ID
                WHERE l.Date >= DATEADD(DD, ((@DaysValid)*-1),SYSDATETIME())
                AND ra.RequirementId = @RequirementId

                SELECT @MaxDate = MAX(l.[Date])
                FROM RequirementActivities ra
                JOIN Activity a
                ON a.ID = ra.ActivityId
                JOIN [Log] l
                ON l.CrewID = @CrewId AND l.ActivityId = a.ID
                JOIN FlightLog f
                ON f.ID = l.ID
                WHERE ra.RequirementId = @RequirementId

                IF (ISNULL((Select TOP 1 Launches from @TotalsTable),0) >= @NumberOfRequiredLaunches) 
                AND (ISNULL((Select TOP 1 Recoveries from @TotalsTable),0) >= @NumberOfRequiredRecoveries) 
                AND (ISNULL((Select TOP 1 LowPasses from @TotalsTable),0) > @RequiredLowPass)
                AND (ISNULL((Select TOP 1 Recoveries from @TotalsTable),0) > @NumberOfRequiredRecoveries)
                BEGIN
                    INSERT INTO @CurrencyTable VALUES((select name from Requirement where ID = @RequirementId), 1, DATEADD(DD,@DaysValid,@MaxDate))
                END
                ELSE
                BEGIN
                    INSERT INTO @CurrencyTable VALUES((select name from Requirement where ID = @RequirementId), 0, @MaxDate)
                END
            END
            --calculate that event logs that expire have been completed once within the days valid
            ELSE
            BEGIN
                SELECT @MaxDate = MAX(l.[Date])
                FROM RequirementActivities ra
                JOIN Activity a
                ON a.ID = ra.ActivityId
                JOIN [Log] l
                ON l.CrewID = @CrewId AND l.ActivityId = a.ID
                JOIN FlightLog f
                ON f.ID = l.ID
                WHERE ra.RequirementId = @RequirementId

                IF @MaxDate >= DATEADD(DD, ((@DaysValid)*-1),SYSDATETIME())
                BEGIN
                    INSERT INTO @CurrencyTable VALUES((select name from Requirement where ID = @RequirementId), 1, DATEADD(DD,@DaysValid,@MaxDate))
                END
                ELSE
                BEGIN
                    INSERT INTO @CurrencyTable VALUES((select name from Requirement where ID = @RequirementId), 0, @MaxDate)
                END
            END
        END

        DELETE FROM @RequirementTable
        WHERE requirementID = @RequirementId
    END 

    SELECT (SELECT * 
    FROM @CurrencyTable
    FOR JSON PATH
    ) as json

END TRY
BEGIN CATCH
    SELECT( Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_authenticateUser
@Email VARCHAR(255),
@Password VARCHAR(255)
AS
BEGIN TRY
    If @Password = (Select password from Crew where Email = @Email)
    BEGIN
        SELECT(SELECT *
        FROM CREW 
        WHERE Email = @Email
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    END
    ELSE 
    BEGIN 
        SELECT (SELECT 403 as ErrorNumber, 
        'Authentication Failed' as ErrorMessage
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    END
END TRY
BEGIN CATCH
    SELECT( Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO