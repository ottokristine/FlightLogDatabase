USE CurrencyTracker

Go

CREATE OR ALTER PROCEDURE sp_deleteCrewRole
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

CREATE OR ALTER PROCEDURE sp_deleteRequirementActivity
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

CREATE OR ALTER PROCEDURE sp_deleteRoleRequirement
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

CREATE OR ALTER PROCEDURE sp_deleteLog
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

CREATE OR ALTER PROCEDURE sp_deleteBulletin
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
