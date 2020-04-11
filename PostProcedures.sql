USE CurrencyTracker

Go

CREATE OR ALTER PROCEDURE sp_addCrew 
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @Id INT = (Select Id
    From OPENJSON(@json)
    WITH (
        Id INT
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

    SELECT *
    FROM Crew 
    WHERE Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_addActivity
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempActivity TABLE(Name VARCHAR(255))
    DECLARE @Id INT = (Select Id
    From OPENJSON(@json)
    WITH (
        Id INT
    ))

    INSERT INTO @TempActivity
    SELECT Name
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255)
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
        Set Name = (Select Name from @TempActivity)
        Where Id = @Id
    END

    Select * 
    FROM Activity 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_addBulletin
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempBulletin TABLE(Name VARCHAR(255))
    DECLARE @Id INT = (Select Id
    From OPENJSON(@json)
    WITH (
        Id INT
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

    Select * 
    FROM Bulletin 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_addRole
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempRole TABLE(Name VARCHAR(255))
    DECLARE @Id INT = (Select Id
    From OPENJSON(@json)
    WITH (
        Id INT
    ))

    INSERT INTO @TempRole
    SELECT Name
    FROM OPENJSON(@json)
    WITH (
        Name VARCHAR(255)
    )

    If @Id IS NULL OR @Id = 0
    BEGIN
        INSERT INTO Role
        Select * from @TempRole

        SET @Id = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        UPDATE Bulletin
        Set Name = (Select Name from @TempRole)
        Where Id = @Id
    END

    Select * 
    FROM Role 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
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

    Select * 
    FROM Site 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_addRequirement
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @TempRequirement TABLE(Name VARCHAR(255), DaysValid INT, NeverExpiresFlag INT)
    DECLARE @Id INT = (Select Id
    From OPENJSON(@json)
    WITH (
        Id INT
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

    Select * 
    FROM Requirement 
    where Id = @Id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
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
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_addRoleRequirement
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(RequirementId INT, RoleId INT)

    INSERT INTO @temp
    SELECT RequirementId, RoleId
    FROM OPENJSON(@json)
    WITH (
        RequirementId INT,
        RoleId INT
    )

    INSERT INTO RoleRequirements
    SELECT * FROM @temp

    exec sp_getRoleRequirementsActivities
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO

CREATE OR ALTER PROCEDURE sp_addRequirementActivity
@json VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @temp TABLE(RequirementId INT, ActivityId INT)

    INSERT INTO @temp
    SELECT RequirementId, ActivityId
    FROM OPENJSON(@json)
    WITH (
        RequirementId INT,
        ActivityId INT
    )

    INSERT INTO RequirementActivities
    SELECT * FROM @temp

    exec sp_getRoleRequirementsActivities
    
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH
END CATCH 

GO