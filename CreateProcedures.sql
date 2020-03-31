
--procedure for getting Crew objects
CREATE OR ALTER PROCEDURE sp_getCrew
AS

SELECT * FROM Crew
FOR JSON PATH, ROOT('Crew')

GO

--procedure for getting Activity objects
CREATE OR ALTER PROCEDURE sp_getActivities
AS

SELECT * FROM Activity
FOR JSON PATH, ROOT('Activity')

GO

--procedure for getting Bulletin objects
CREATE OR ALTER PROCEDURE sp_getBulletins
as 
SELECT * FROM Bulletin
FOR JSON PATH, ROOT('Bulletins')

GO

--get all of the roles
CREATE OR ALTER PROCEDURE sp_getRoles
as 
SELECT * FROM Role
FOR JSON PATH, ROOT('Roles')

GO

--get all of the Sites
CREATE OR ALTER PROCEDURE sp_getSites
as 
SELECT * FROM Site
FOR JSON PATH, ROOT('Sites')

GO

--get all requirements
CREATE OR ALTER PROCEDURE sp_getRequirements
as 
SELECT * FROM Requirement
FOR JSON PATH, ROOT('Requirements')

GO

--get Users Logs
CREATE OR ALTER PROCEDURE sp_getAllLogsForUser
@CrewId INT
as 
select l.*,
    (select * 
    from Activity a
    where a.ID = l.ActivityId 
    FOR JSON PATH) as [Activity],
    (select * 
    from Crew c
    where c.ID = l.CrewId
    FOR JSON PATH) as [Crew],
    (select *,
        (select *,
            (select * 
            from Site s 
            where s.ID = m.SiteId
            FOR JSON PATH) as [Site]
        from Mission m
        where m.ID = f.MissionId
        FOR JSON PATH) as [Mission],
        (select * 
        from Role r
        where r.ID = f.RoleID
        FOR JSON PATH) as [Role]
    from FlightLog f
    where f.ID = l.Id
    FOR JSON PATH) as [FlightLog]
from [Log] l
Where l.CrewID = @CrewId
FOR JSON PATH, ROOT('Logs')

GO

--get log for ID
CREATE OR ALTER PROCEDURE sp_getLogForId
@Id INT
AS 

select l.*,
    (select * 
    from Activity a
    where a.ID = l.ActivityId 
    FOR JSON PATH) as [Activity],
    (select * 
    from Crew c
    where c.ID = l.CrewId
    FOR JSON PATH) as [Crew],
    (select *,
        (select *,
            (select * 
            from Site s 
            where s.ID = m.SiteId
            FOR JSON PATH) as [Site]
        from Mission m
        where m.ID = f.MissionId
        FOR JSON PATH) as [Mission],
        (select * 
        from Role r
        where r.ID = f.RoleID
        FOR JSON PATH) as [Role]
    from FlightLog f
    where f.ID = l.Id
    FOR JSON PATH) as [FlightLog]
from [Log] l
WHERE l.ID = @Id
FOR JSON PATH, ROOT('Log')

GO



--get the unacknowledged bulletins of a particular user
CREATE OR ALTER PROCEDURE sp_getUnacknowlegedBulletins
@CrewId INT
AS
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

Go

--gets the current roles for a Crew Member
CREATE OR ALTER PROCEDURE sp_getRolesForCrew
@CrewId INT 
AS
SELECT cr.*,
    (SELECT c.* 
    FROM Crew c 
    WHERE c.ID = cr.CrewId
    FOR JSON PATH) as [Crew],
    (SELECT r.* 
    FROM Role r 
    WHERE r.ID = cr.RoleID
    FOR JSON PATH) as [Role]
FROM CrewRoles cr
WHERE cr.CrewId = @CrewId
FOR JSON PATH, Root('CrewRole')

Go

--gets the roles, the requirements associated with them and the activities that satisfy
--the requirement, used for the admin page to set up roles/requirement/activity relationships

CREATE OR ALTER PROCEDURE sp_getRoleRequirementsActivities
AS

SELECT rr.*,
    (SELECT *
    FROM Role r
    where r.ID = rr.RoleID
    FOR JSON PATH) as [Role],
    (Select r.*,
        (select fr.*
        FROM FlightRequirement fr
        where fr.ID = r.Id
        FOR JSON PATH) as [FlightRequirement],
        (select ra.*,
            (select * 
            from Activity a
            WHERE a.ID = ra.ActivityId
            FOR JSON PATH) as [Activity]
        FROM RequirementActivities ra
        where ra.RequirementId = r.ID
        FOR JSON PATH) as [RequirementActivities]
    from Requirement r
    where r.Id = rr.RequirementID
    FOR JSON PATH) as [Requirement]
FROM RoleRequirements rr
FOR JSON PATH, ROOT('RoleRequirementsActivities')

Go

--gets a mission for a mission ID and all of the logs associated with it
CREATE OR ALTER PROCEDURE sp_getMission
@MissionId INT
AS

Select m.*,
    (SELECT * 
    FROM Site s
    WHERE s.ID = m.siteId
    FOR JSON PATH) as [Site],
    (SELECT f.*,
        (Select l.*,
            (select * 
            from Activity a
            where a.ID = l.ActivityId 
            FOR JSON PATH) as [Activity],
            (select * 
            from Crew c
            where c.ID = l.CrewId
            FOR JSON PATH) as [Crew]
        FROM [Log] l
        WHERE l.ID = f.ID
        FOR JSON PATH) as [Log],
        (select * 
        from Role r
        where r.ID = f.RoleID
        FOR JSON PATH) as [Role]
    from FlightLog f
    WHERE f.missionId = m.ID
    FOR JSON PATH) as [FlightLogs]
FROM Mission m
where m.ID = @MissionId
FOR JSON PATH, ROOT('Mission')

GO