Use [CurrencyTracker]

--insert Crew into the Crew table
INSERT INTO Crew VALUES ('Kristine','Otto','ottokristine@gmail.com','test',0)
INSERT INTO Crew VALUES ('Zachary','Lance','zalance@fake.com','test',1)
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
INSERT INTO Log VALUES(sysdatetime(),(select ID from Activity where name='Flight'),(select Id from Crew where FirstName = 'Zachary'))
DECLARE @LogId INT = SCOPE_IDENTITY()
Insert INTO FlightLog VALUES (@LogId,@MissionId,5,1,1,0,(select ID from Role where name = 'Basic Operator'))

INSERT INTO MISSION VALUES ((select Id from Site where Prefix = 'DRG'),SYSDATETIME(),3,224)
SET @MissionId = SCOPE_IDENTITY()
INSERT INTO Log VALUES(sysdatetime(),(select ID from Activity where name='Sim'),(select Id from Crew where FirstName = 'Zachary'))
SET @LogId = SCOPE_IDENTITY()
Insert INTO FlightLog VALUES (@LogId,@MissionId,4,2,1,0,(select ID from Role where name = 'Basic Operator'))

--create an event log
INSERT INTO LOG VALUES(SYSDATETIME(),(select ID from Activity where name='Background Check'),(select Id from Crew where FirstName = 'Zachary'))

--assign a role to a user
INSERT INTO CrewRoles VALUES ((select Id from Crew where FirstName = 'Zachary'),(select ID from Role where name = 'Basic Operator'))

--add an acknoweledgement to an FSB
INSERT INTO Acknowledges VALUES ((select Id from Crew where FirstName = 'Zachary'), (select ID from Bulletin where Name = 'Switch out Engine on all -25 builds'))
INSERT INTO Acknowledges VALUES ((select Id from Crew where FirstName = 'Kristine'), (select ID from Bulletin where Name = 'New GPS sofware available for download'))
INSERT INTO Acknowledges VALUES ((select Id from Crew where FirstName = 'Kristine'), (select ID from Bulletin where Name = 'Switch out Engine on all -25 builds'))

