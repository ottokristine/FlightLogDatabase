USE CurrencyTracker

Go

CREATE OR ALTER PROCEDURE sp_addCrew 
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

CREATE OR ALTER PROCEDURE sp_addActivity
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

CREATE OR ALTER PROCEDURE sp_addBulletin
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

CREATE OR ALTER PROCEDURE sp_addNewRole
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

CREATE OR ALTER PROCEDURE sp_addSite
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

CREATE OR ALTER PROCEDURE sp_addRequirement
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

CREATE OR ALTER PROCEDURE sp_addCrewRole
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

CREATE OR ALTER PROCEDURE sp_addRoleRequirement
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

CREATE OR ALTER PROCEDURE sp_addRequirementActivity
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

CREATE OR ALTER PROCEDURE sp_AcknowledgeBulletin
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

CREATE OR ALTER PROCEDURE sp_addMission
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


CREATE OR ALTER PROCEDURE sp_addLog
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

        PRINT @FlightLogJson

        INSERT INTO @FlightLogTemp
        SELECT MissionID INT, MissionTime INT, Launch INT, [Recovery] INT, NumberOfLowPasses INT, RoleId INT
        FROM OPENJSON(@FlightLogJson)
        WITH (
            MissionID INT, 
            MissionTime INT, 
            Launch INT, 
            [Recovery] INT, 
            NumberOfLowPasses INT, 
            RoleID INT
        )
        IF @FlightLogId IS NULL OR @Id = 0
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

        SELECT (Select l.*,
        JSON_QUERY((SELECT * from FlightLog
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) as [FlightLog]  
        from [Log] l
        WHERE ID = @Id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json

    END
    ELSE 
    BEGIN
        SELECT (Select * from [Log] 
        WHERE ID = @Id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
    END
END TRY
BEGIN CATCH
    SELECT(Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json
END CATCH 

GO