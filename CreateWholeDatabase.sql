CREATE DATABASE CurrencyTracker

GO

USE [master]

CREATE LOGIN [user] WITH PASSWORD = 'password123', CHECK_POLICY = OFF;

USE [CurrencyTracker]
create user [user] for login [user]
EXEC sp_addrolemember N'db_owner', N'user'

GO

EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
GO

Use [CurrencyTracker]


CREATE TABLE Bulletin (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255)
)

CREATE TABLE Crew (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email Varchar(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    AdminFlag Int NOT NULL,
    Constraint ckCrewAdminFlag check (AdminFlag in (0,1)),
)

CREATE TABLE [Site] (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    Prefix VARCHAR(255) NOT NULL UNIQUE
)

CREATE TABLE Acknowledges (
    CrewId INT FOREIGN KEY REFERENCES Crew(ID) ON DELETE CASCADE NOT NULL,
    BulletinId INT FOREIGN KEY REFERENCES Bulletin(ID) ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (CrewID,BulletinId)
)

CREATE TABLE Requirement (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    DaysValid INT,
    NeverExpiresFlag INT NOT NULL,
    Constraint requirementNeverExpires check (NeverExpiresFlag in (0,1))
)

CREATE TABLE FlightRequirement (
    ID INT PRIMARY KEY FOREIGN KEY References Requirement(ID) ON DELETE CASCADE,
    RequiredLaunches INT NOT NULL,
    RequiredRecoveries INT NOT NULL,
    RequiredLowPass INT NOT NULL,
    RequiredMissionTime DECIMAL NOT NULL
)

CREATE TABLE Activity (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(155) NOT NULL UNIQUE,
    FlightActivityFlag INT NOT NULL
)

CREATE TABLE RequirementActivities (
    RequirementId INT FOREIGN KEY REFERENCES Requirement(ID) ON DELETE CASCADE,
    ActivityId Int FOREIGN KEY REFERENCES Activity(ID) ON DELETE CASCADE,
    PRIMARY KEY(RequirementId, ActivityId),
    CONSTRAINT ra_unique UNIQUE (RequirementId, ActivityId)
)

CREATE TABLE [Role] (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
)

CREATE TABLE RoleRequirements (
    RequirementID INT FOREIGN KEY REFERENCES Requirement(Id) ON DELETE CASCADE,
    RoleID INT FOREIGN KEY REFERENCES Role(Id) ON DELETE CASCADE,
    PRIMARY KEY(RequirementId, RoleID),
    CONSTRAINT rr_unique UNIQUE (RequirementId, RoleID)
)

CREATE TABLE Mission (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    SiteId INT NOT NULL FOREIGN KEY REFERENCES Site(ID) ON DELETE CASCADE,
    Date DATETIME NOT NULL,
    LaunchNumber INT NOT NULL,
    AVTailNumber INT NOT NULL
)

CREATE TABLE [Log] (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME NOT NULL, 
    ActivityId INT NOT NULL FOREIGN KEY REFERENCES Activity(ID) ON DELETE CASCADE,
    CrewID INT NOT NULL FOREIGN KEY REFERENCES Crew(ID) ON DELETE CASCADE
)

CREATE TABLE FlightLog (
    ID INT NOT NULL FOREIGN KEY REFERENCES Log(ID) ON DELETE CASCADE PRIMARY KEY,
    MissionID INT NOT NULL FOREIGN KEY REFERENCES Mission(Id),
    MissionTime DECIMAL NOT NULL,
    Launch INT NOT NULL,
    Recovery INT NOT NULL,
    NumberOfLowPasses INT NOT NULL,
    RoleID INT NOT NULL FOREIGN KEY REFERENCES Role(ID) ON DELETE CASCADE
)

CREATE TABLE CrewRoles (
    CrewId INT NOT NULL FOREIGN KEY REFERENCES Crew(ID) ON DELETE CASCADE,
    RoleId INT NOT NULL FOREIGN KEY REFERENCES Role(ID) ON DELETE CASCADE,
    PRIMARY KEY(CrewId, RoleId),
    CONSTRAINT cr_unique UNIQUE (CrewId, RoleId)
)

GO

USE [CurrencyTracker]
GO

--procedure for getting Crew objects
CREATE PROCEDURE sp_getCrew
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

--procedure for getting Event Activity objects
CREATE PROCEDURE sp_getEventActivities
AS
BEGIN TRY
    SELECT (SELECT * 
    FROM Activity
    WHERE FlightActivityFlag = 0
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--procedure for getting Flight Activity objects
CREATE PROCEDURE sp_getAllActivities
AS
BEGIN TRY
    SELECT (SELECT * 
    FROM Activity
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--procedure for getting Flight Activity objects
CREATE PROCEDURE sp_getFlightActivities
AS
BEGIN TRY
    SELECT (SELECT * 
    FROM Activity
    WHERE FlightActivityFlag = 1
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

--procedure for getting Bulletin objects
CREATE PROCEDURE sp_getBulletins
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
CREATE PROCEDURE sp_getRoles
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
CREATE PROCEDURE sp_getSites
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
CREATE PROCEDURE sp_getRequirements
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
CREATE PROCEDURE sp_getAllLogsForUser
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
CREATE PROCEDURE sp_getLogForId
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
CREATE PROCEDURE sp_getUnacknowlegedBulletins
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
CREATE PROCEDURE sp_getRolesForCrew
@CrewId INT 
AS
BEGIN TRY
    SELECT (SELECT r.* 
    FROM CrewRoles cr
    JOIN Role r ON cr.RoleId = r.ID
    WHERE cr.CrewId = @CrewId
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

CREATE PROCEDURE sp_getRoleRequirementsActivities
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

--gets all of the requirements for a role
CREATE PROCEDURE sp_getRequirementsForRole
@RoleId INT
AS
BEGIN TRY
    SELECT (SELECT r.*
    FROM RoleRequirements rr
    JOIN Requirement r ON r.ID = rr.RequirementID
    WHERE rr.RoleID = @RoleId
    FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

Go

CREATE PROCEDURE sp_getActivitiesForRequirement
@RequirementId INT
AS
BEGIN TRY
    SELECT (SELECT a.*
        FROM RequirementActivities ra
        JOIN Activity a ON a.ID = ra.ActivityId
        WHERE ra.RequirementId = @RequirementId
        FOR JSON PATH) as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

Go

--gets a mission for a mission ID and all of the logs associated with it
CREATE PROCEDURE sp_getMission
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

--gets all the flight logs associated with a mission
CREATE PROCEDURE sp_getFlightLogsForMission
@MissionId INT
AS
BEGIN TRY
        SELECT (SELECT f.*,
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
        WHERE f.missionId = @MissionId
        FOR JSON PATH)  as json
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO


CREATE PROCEDURE sp_getCurrency
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
                AND (ISNULL((Select TOP 1 LowPasses from @TotalsTable),0) >= @RequiredLowPass)
                AND (ISNULL((Select TOP 1 MissionTime from @TotalsTable),0) >= @RequiredMissionTime)
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

CREATE PROCEDURE sp_authenticateUser
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



USE CurrencyTracker

Go

CREATE PROCEDURE sp_addCrew 
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))
    DECLARE @TempCrew TABLE(FirstName VARCHAR(255),LastName VARCHAR(255),Email VARCHAR(255),Password VARCHAR(255),AdminFlag INT)

    INSERT INTO @TempCrew
    SELECT FirstName, LastName, Email, Password, AdminFlag
    FROM OPENJSON(@json)
    WITH (
        FirstName VARCHAR(255),
        LastName VARCHAR(255),
        Email VARCHAR(255),
        Password VARCHAR(255),
        AdminFlag INT
    )

    IF @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Crew
        SELECT * FROM @TempCrew

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE 
    BEGIN 
        UPDATE Crew
        SET FirstName = (Select FirstName from @TempCrew),
        LastName = (Select LastName from @TempCrew),
        Email = (Select Email from @TempCrew),
        [Password] = (Select [Password] from @TempCrew),
        AdminFlag = (select AdminFlag from @TempCrew)
        WHERE Id = @Id

    END

    Select (SELECT *
    FROM Crew 
    WHERE Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addActivity
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempActivity TABLE(Name VARCHAR(255), FlightActivityFlag INT)
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))

    INSERT INTO @TempActivity
    SELECT Name, FlightActivityFlag
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255),
        FlightActivityFlag INT
    )
    
    If @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Activity
        Select * from @TempActivity

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE Activity
        Set Name = (Select Name from @TempActivity),
        FlightActivityFlag = (Select FlightActivityFlag from @TempActivity)
        Where Id = @Id
    END

    Select (Select * 
    FROM Activity 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addBulletin
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempBulletin TABLE(Name VARCHAR(255))
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))

    INSERT INTO @TempBulletin
    SELECT Name
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255)
    )

    If @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Bulletin
        Select * from @TempBulletin

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE Bulletin
        Set Name = (Select Name from @TempBulletin)
        Where Id = @Id
    END

    SELECT (Select * 
    FROM Bulletin 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addNewRole
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempRole TABLE(Name VARCHAR(255))
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))

    INSERT INTO @TempRole
    SELECT Name
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255)
    )

    If @Id IS NULL OR @Id = 0
    BEGIN
    PRINT 'NEW ROLE'
        INSERT INTO [CurrencyTracker].dbo.Role
        Select * from @TempRole

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE [CurrencyTracker].dbo.Role
        Set Name = (Select Name from @TempRole)
        Where Id = @Id
    END

    SELECT (Select * 
    FROM [CurrencyTracker].dbo.Role 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addSite
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempSite TABLE(Name VARCHAR(255), Prefix VARCHAR(255))
    DECLARE @Id INT = (Select Id
    From OPENJSON(@json)
    WITH (
        Id INT
    ))

    INSERT INTO @TempSite
    SELECT Name, Prefix
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255),
        Prefix VARCHAR(255)
    )

    If @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Site
        Select * from @TempSite

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE Site
        Set Name = (Select Name from @TempSite),
        Prefix = (Select Prefix from @TempSite)
        Where Id = @Id
    END

    SELECT (Select * 
    FROM Site 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addRequirement
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempRequirement TABLE(Name VARCHAR(255), DaysValid INT, NeverExpiresFlag INT)
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))

    INSERT INTO @TempRequirement
    SELECT Name, DaysValid, NeverExpiresFlag
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255),
        DaysValid INT,
        NeverExpiresFlag INT
    )

    If @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Requirement
        Select * from @TempRequirement

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE Requirement
        Set Name = (Select Name from @TempRequirement),
        DaysValid = (Select DaysValid from @TempRequirement),
        NeverExpiresFlag = (Select NeverExpiresFlag from @TempRequirement)
        WHERE Id = @Id
    END

    SELECT (Select * 
    FROM Requirement 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addCrewRole
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(CrewId INT, RoleId INT)
    DECLARE @CrewId INT

    INSERT INTO @temp
    SELECT CrewId, RoleId
    FROM OPENJSON(@json)
    WITH (
        CrewId INT,
        RoleId INT
    )

    SET @CrewId = (Select CrewId from @temp)

    INSERT INTO CrewRoles
    SELECT * FROM @temp

    exec sp_getRolesForCrew @CrewId
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addRoleRequirement
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(RequirementId INT, RoleId INT)
    DECLARE @RoleId INT

    INSERT INTO @temp
    SELECT RequirementId, RoleId
    FROM OPENJSON(@json)
    WITH (
        RequirementId INT,
        RoleId INT
    )

    SET @RoleId = (select RoleId from @temp)

    INSERT INTO RoleRequirements
    SELECT * FROM @temp

    exec sp_getRequirementsForRole @RoleId
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addRequirementActivity
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(RequirementId INT, ActivityId INT)
    DECLARE @RequirementId INT

    INSERT INTO @temp
    SELECT RequirementId, ActivityId
    FROM OPENJSON(@json)
    WITH (
        RequirementId INT,
        ActivityId INT
    )

    SET @RequirementId = (select RequirementId from @temp)

    INSERT INTO RequirementActivities
    SELECT * FROM @temp

    exec sp_getActivitiesForRequirement @RequirementId
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_AcknowledgeBulletin
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(CrewId INT, BulletinId INT)
    DECLARE @CrewId INT

    INSERT INTO @temp
    SELECT CrewId, BulletinId
    FROM OPENJSON(@json)
    WITH (
        CrewId INT,
        BulletinId INT
    )

    INSERT INTO Acknowledges
    SELECT * from @temp

    SET @CrewId = (select CrewId from @temp)

    exec sp_getUnacknowlegedBulletins @CrewId
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addMission
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(SiteId INT, missionDate Date, LaunchNumber INT, AVTailNumber INT)
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))

    INSERT INTO @temp
    SELECT SiteId, [Date], LaunchNumber, AVTailNumber
    FROM OPENJSON(@json)
    WITH (
        SiteId Int,
        [Date] Date,
        LaunchNumber Int,
        AVTailNumber Int
    )

    IF @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Mission
        Select * from @temp

        SET @ID = SCOPE_IDENTITY()
    END
    ELSE 
    BEGIN
        UPDATE Mission
        SET SiteId = (select SiteId from @temp),
        [Date] = (SELECT missionDate from @temp),
        LaunchNumber = (SELECT LaunchNumber from @temp),
        AVTailNumber = (SELECT AVTailNumber from @temp)
        Where ID = @Id
    END

    exec sp_getMission @Id
    
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_addLog
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @LogTemp TABLE([Date] Date, ActivityId INT, CrewId INT)
    DECLARE @FlightLogTemp TABLE(MissionId INT, MissionTime INT, Launch INT, [Recovery] INT, NumberOfPasses INT, RoleId INT)
    DECLARE @Id INT = (Select ID
    From OPENJSON(@json)
    WITH (
        ID INT
    ))
    DECLARE @FlightLogId INT

    DECLARE @FlightLogJson NVARCHAR(MAX) = 
    (SELECT FlightLog
    FROM OPENJSON(@json)
    WITH (
        FlightLog NVARCHAR(MAX) as JSON
    ))

    INSERT INTO @LogTemp
    SELECT [Date], ActivityId, CrewID
    FROM OPENJSON(@json)
    WITH (
        [Date] Date, 
        ActivityId INT, 
        CrewID INT
    )

    IF @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO [Log]
        SELECT * from @LogTemp

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE 
    BEGIN
        UPDATE [Log]
        SET [Date] = (SELECT [Date] from @LogTemp),
        ActivityId = (SELECT ActivityId from @LogTemp),
        CrewID = (SELECT CrewID from @LogTemp)
        Where ID = @Id
    END

    IF @FlightLogJson IS NOT NULL
    BEGIN 
        SET @FlightLogId = (Select ID
        From OPENJSON(@FlightLogJson)
        WITH (
        ID INT
        ))

        INSERT INTO @FlightLogTemp
        SELECT MissionID INT, MissionTime INT, Launch INT, [Recovery] INT, NumberOfLowPasses INT, RoleID INT
        FROM OPENJSON(@FlightLogJson)
        WITH (
            MissionID INT, 
            MissionTime INT, 
            Launch INT, 
            [Recovery] INT, 
            NumberOfLowPasses INT, 
            RoleID INT
        )

        IF @FlightLogId IS NULL OR @FlightLogId = 0
        BEGIN 
            INSERT INTO FlightLog
            SELECT
            @Id,
            MissionID, 
            MissionTime, 
            Launch, 
            [Recovery], 
            NumberOfPasses, 
            RoleID
            FROM @FlightLogTemp
        END
        ELSE 
        BEGIN 
            UPDATE FlightLog
            SET MissionId = (select MissionId from @FlightLogTemp), 
            MissionTime= (select MissionTime from @FlightLogTemp), 
            Launch = (select Launch from @FlightLogTemp), 
            [Recovery] = (select [Recovery] from @FlightLogTemp), 
            NumberOfLowPasses = (select NumberOfPasses from @FlightLogTemp), 
            RoleId = (select RoleID from @FlightLogTemp)
            WHERE ID = @Id
        END

        exec sp_getLogForId @Id

    END
    ELSE 
    BEGIN
        exec sp_getLogForId @Id
    END
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

USE CurrencyTracker

Go

CREATE PROCEDURE sp_deleteCrewRole
@CrewId INT,
@RoleId INT
AS
BEGIN TRY 
    DELETE FROM CrewRoles
    WHERE CrewId = @CrewId
    AND RoleId = @RoleId

    EXEC sp_getRolesForCrew @CrewId
END TRY 
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_deleteRequirementActivity
@RequirementId INT,
@ActivityId INT
AS
BEGIN TRY 
    DELETE FROM RequirementActivities
    WHERE RequirementId = @RequirementId
    AND ActivityId = @ActivityId

    EXEC sp_getActivitiesForRequirement @RequirementId
END TRY 
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_deleteRoleRequirement
@RoleId INT,
@RequirementId INT
AS
BEGIN TRY 
    DELETE FROM RoleRequirements
    WHERE RequirementId = @RequirementId
    AND RoleID = @RoleId

    EXEC sp_getRequirementsForRole @RoleId
END TRY 
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_deleteLog
@LogId INT
AS
BEGIN TRY 
    DECLARE @CrewId INT
    DECLARE @MissionId INT

    IF (Select Id from FlightLog WHERE ID = @LogId) IS NULL
    BEGIN
        SET @MissionId = (Select MissionID from FlightLog WHERE ID = @LogId)

        DELETE FROM FlightLog
        WHERE ID = @LogId

        IF (SELECT TOP 1 ID from FlightLog Where MissionID = @MissionId) IS NULL
        BEGIN
            DELETE FROM Mission
            WHERE ID = @MissionId
        END
        
    END

    SET @CrewId = (SELECT CrewId from Log where Id = @LogId)

    DELETE FROM [Log]
    WHERE ID = @LogId

    EXEC sp_getLogForId @CrewId
END TRY 
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO

CREATE PROCEDURE sp_deleteBulletin
@BulletinId INT
AS
BEGIN TRY 
    DELETE FROM Bulletin
    WHERE ID = @BulletinId

    EXEC sp_getBulletins
END TRY 
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO



Use [CurrencyTracker]

--insert Crew into the Crew table
INSERT INTO Crew VALUES ('Kristine','Otto','ottokristine@gmail.com','test',0)
INSERT INTO Crew VALUES ('User','Test','user@test.com','test',1)
INSERT INTO Crew VALUES ('Ian', 'Eberly','ieberly@fake.com','test',1)
INSERT INTO Crew VALUES ('Ian','Wood','iwood@fake.com','test',0)

--populate bulletings
INSERT INTO Bulletin VALUES ('Switch out Engine on all -25 builds')
INSERT INTO Bulletin VALUES ('New GPS sofware available for download')

--populate sites
INSERT INTO Site VALUES ('DRAGONFLY 1', 'DRG')
INSERT INTO Site VALUES ('RIBBIT', 'RBT')

--populate activities
INSERT INTO Activity VALUES ('Flight', 1)
INSERT INTO Activity VALUES ('Sim', 1)
INSERT INTO Activity VALUES ('Quiz', 0)
INSERT INTO Activity VALUES ('Background Check', 0)

--populate roles
INSERT INTO Role VALUES ('Basic Operator')
INSERT INTO Role VALUES ('Mechanic')
INSERT INTO Role VALUES ('Flight Instructor')

--populate requirements
INSERT INTO Requirement VALUES ('Background Check',null,1)
INSERT INTO Requirement VALUES ('30 Day Quiz', 30, 0)
INSERT INTO Requirement VALUES ('90 Day Flight Check',90,0)
INSERT INTO FlightRequirement VALUES ((select ID from Requirement where name = '90 Day Flight Check'), 1,1,0,10)
INSERT INTO Requirement VALUES ('30 Day Instructor Check',30,0)
INSERT INTO FlightRequirement VALUES ((select ID from Requirement where name = '30 Day Instructor Check'), 1,1,0,1)

--assign requirements to roles
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = '90 Day Flight Check'),(select ID from Role where name = 'Basic Operator'))
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = '90 Day Flight Check'),(select ID from Role where name = 'Flight Instructor'))
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = '30 Day Instructor Check'),(select ID from Role where name = 'Flight Instructor'))
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = 'Background Check'),(select ID from Role where name = 'Flight Instructor'))
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = 'Background Check'),(select ID from Role where name = 'Basic Operator'))
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = 'Background Check'),(select ID from Role where name = 'Mechanic'))
INSERT INTO RoleRequirements VALUES ((select ID from Requirement where name = '30 Day Quiz'),(select ID from Role where name = 'Mechanic'))

--assign activities to fulfill certain requirements
Insert into RequirementActivities VALUES ((select ID from Requirement where name = '90 Day Flight Check'),(select ID from activity where name='Flight'))
Insert into RequirementActivities VALUES ((select ID from Requirement where name = '90 Day Flight Check'),(select ID from activity where name='Sim'))
Insert into RequirementActivities VALUES ((select ID from Requirement where name = '30 Day Instructor Check'),(select ID from activity where name='Flight'))
Insert into RequirementActivities VALUES ((select ID from Requirement where name = '30 Day Instructor Check'),(select ID from activity where name='Sim'))
Insert into RequirementActivities VALUES ((select ID from Requirement where name = 'Background Check'),(select ID from activity where name='Background Check'))
Insert into RequirementActivities VALUES ((select ID from Requirement where name = '30 Day Quiz'),(select ID from activity where name='Quiz'))

--create a few flight logs
INSERT INTO MISSION VALUES ((select Id from Site where Prefix = 'DRG'),SYSDATETIME(),2,223)
DECLARE @MissionId INT = SCOPE_IDENTITY();
INSERT INTO Log VALUES(sysdatetime(),(select ID from Activity where name='Flight'),(select Id from Crew where FirstName = 'User'))
DECLARE @LogId INT = SCOPE_IDENTITY()
Insert INTO FlightLog VALUES (@LogId,@MissionId,5,1,1,0,(select ID from Role where name = 'Basic Operator'))

INSERT INTO MISSION VALUES ((select Id from Site where Prefix = 'DRG'),SYSDATETIME(),3,224)
SET @MissionId = SCOPE_IDENTITY()
INSERT INTO Log VALUES(sysdatetime(),(select ID from Activity where name='Sim'),(select Id from Crew where FirstName = 'User'))
SET @LogId = SCOPE_IDENTITY()
Insert INTO FlightLog VALUES (@LogId,@MissionId,4,2,1,0,(select ID from Role where name = 'Basic Operator'))

--create an event log
INSERT INTO LOG VALUES(SYSDATETIME(),(select ID from Activity where name='Background Check'),(select Id from Crew where FirstName = 'User'))

--assign a role to a user
INSERT INTO CrewRoles VALUES ((select Id from Crew where FirstName = 'User'),(select ID from Role where name = 'Basic Operator'))

--add an acknoweledgement to an FSB
INSERT INTO Acknowledges VALUES ((select Id from Crew where FirstName = 'User'), (select ID from Bulletin where Name = 'Switch out Engine on all -25 builds'))
INSERT INTO Acknowledges VALUES ((select Id from Crew where FirstName = 'Kristine'), (select ID from Bulletin where Name = 'New GPS sofware available for download'))
INSERT INTO Acknowledges VALUES ((select Id from Crew where FirstName = 'Kristine'), (select ID from Bulletin where Name = 'Switch out Engine on all -25 builds'))

