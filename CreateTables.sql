--Create database CurrencyTracker;

CREATE TABLE Bulletin (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255)
)

CREATE TABLE Crew (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email Varchar(255),
    AdminFlag Int,
    SiteLeadFlag INT,
    Constraint ckCrewAdminFlag check (AdminFlag in (0,1)),
    Constraint ckSiteLeadFlag check (SiteLeadFlag in (0,1))
)

CREATE TABLE Acknowledges (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    CrewId INT FOREIGN KEY REFERENCES Crew(ID),
    BulletinId INT FOREIGN KEY REFERENCES Bulletin(ID)
)

CREATE TABLE Requirement (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255),
    DaysValid INT,
    NeverExpiresFlag INT,
    Constraint requirementNeverExpires check (NeverExpiresFlag in (0,1))
)

CREATE TABLE FlightRequirement (
    ID INT PRIMARY KEY FOREIGN KEY References Requirement(ID),
    RequiredLaunches INT,
    RequiredRecoveries INT,
    RequiredLowPass INT,
    RequiredMissionTime DECIMAL
)

CREATE TABLE Activity (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(155)
)

CREATE TABLE RequirementActivities (
    RequirementId INT FOREIGN KEY REFERENCES Requirement(ID),
    ActivityId Int FOREIGN KEY REFERENCES Activity(ID),
    PRIMARY KEY(RequirementId, ActivityId)
)

CREATE TABLE ROLE (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255),
)

CREATE TABLE RoleRequirements (
    RequirementID INT FOREIGN KEY REFERENCES Requirement(Id),
    RoleID INT FOREIGN KEY REFERENCES Role(Id),
    PRIMARY KEY(RequirementId, RoleID)
)

CREATE TABLE Mission (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Site VARCHAR(255),
    Date DATETIME,
    LaunchNumber INT,
    AVTailNumber INT
)

CREATE TABLE LOG (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME,
    ActivityId INT FOREIGN KEY REFERENCES Activity(ID),
    CrewID INT FOREIGN KEY REFERENCES Crew(ID)
)

CREATE TABLE FlightLog (
    ID INT FOREIGN KEY REFERENCES Log(ID) PRIMARY KEY,
    MissionTime DECIMAL,
    Launch INT,
    Recovery INT,
    NumberOfLowPasses INT,
    RoleID INT FOREIGN KEY REFERENCES Role(ID)
)
