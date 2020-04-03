USE [CurrencyTracker]
GO

--procedure for getting Crew objects
CREATE OR ALTER PROCEDURE sp_getCrew
AS
BEGIN TRY
    SELECT * FROM Crew
    FOR JSON PATH, ROOT('Crew')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 
GO

--procedure for getting Activity objects
CREATE OR ALTER PROCEDURE sp_getActivities
AS
BEGIN TRY
    SELECT * FROM Activity
    FOR JSON PATH, ROOT('Activity')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO

--procedure for getting Bulletin objects
CREATE OR ALTER PROCEDURE sp_getBulletins
as 
BEGIN TRY
    SELECT * FROM Bulletin
    FOR JSON PATH, ROOT('Bulletins')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO

--get all of the roles
CREATE OR ALTER PROCEDURE sp_getRoles
as 
BEGIN TRY
    SELECT * FROM Role
    FOR JSON PATH, ROOT('Roles')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO

--get all of the Sites
CREATE OR ALTER PROCEDURE sp_getSites
as 
BEGIN TRY
    SELECT * FROM Site
    FOR JSON PATH, ROOT('Sites')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO

--get all requirements
CREATE OR ALTER PROCEDURE sp_getRequirements
as 
BEGIN TRY
    SELECT * FROM Requirement
    FOR JSON PATH, ROOT('Requirements')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO

--get Users Logs
CREATE OR ALTER PROCEDURE sp_getAllLogsForUser
@CrewId INT
as 
BEGIN TRY
    select l.*,
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
    FOR JSON PATH, ROOT('Logs')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO

--get log for ID
CREATE OR ALTER PROCEDURE sp_getLogForId
@Id INT
AS 
BEGIN TRY
    select JSON_QUERY((SELECT TOP 1 l.*,
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
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 
GO



--get the unacknowledged bulletins of a particular user
CREATE OR ALTER PROCEDURE sp_getUnacknowlegedBulletins
@CrewId INT
AS
BEGIN TRY
    SELECT * 
    FROM Bulletin b
    LEFT JOIN (
        SELECT b.*
        FROM Bulletin b 
        JOIN Acknowledges a on b.ID = a.BulletinId
        WHERE a.CrewId = @CrewId
    ) AS acknowledgedBulletins on acknowledgedBulletins.id = b.Id
    where acknowledgedBulletins.ID is null
    FOR JSON PATH, ROOT('UnacknowledgedBulletins')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

Go

--gets the current roles for a Crew Member
CREATE OR ALTER PROCEDURE sp_getRolesForCrew
@CrewId INT 
AS
BEGIN TRY
    SELECT c.*,
        (SELECT * 
        FROM CrewRoles cr
        JOIN Role r ON cr.RoleId = r.ID
        WHERE cr.CrewId = c.ID
        FOR JSON PATH) as [Roles]
    FROM Crew c 
    FOR JSON PATH, ROOT('CrewRoles')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

Go

--gets the roles, the requirements associated with them and the activities that satisfy
--the requirement, used for the admin page to set up roles/requirement/activity relationships

CREATE OR ALTER PROCEDURE sp_getRoleRequirementsActivities
AS
BEGIN TRY
    SELECT R.*,
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
    FOR JSON PATH, ROOT('RoleRequirementsActivities')
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

Go

--gets a mission for a mission ID and all of the logs associated with it
CREATE OR ALTER PROCEDURE sp_getMission
@MissionId INT
AS
BEGIN TRY
    select JSON_QUERY((Select m.*,
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
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
END TRY
BEGIN CATCH
    Select ERROR_NUMBER() As ErrorNumber,
    ERROR_MESSAGE() As ErrorMessage
    FOR JSON PATH, ROOT('Error')
END CATCH 

GO