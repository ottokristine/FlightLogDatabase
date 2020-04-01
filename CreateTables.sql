--Create database CurrencyTracker

CREATE TABLE CurrencyTracker.dbo.Bulletin (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255)
)

CREATE TABLE CurrencyTracker.dbo.Crew (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email Varchar(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    AdminFlag Int NOT NULL,
    Constraint ckCrewAdminFlag check (AdminFlag in (0,1)),
)

CREATE TABLE CurrencyTracker.dbo.Site (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    Prefix VARCHAR(255) NOT NULL UNIQUE
)

CREATE TABLE CurrencyTracker.dbo.Acknowledges (
    CrewId INT FOREIGN KEY REFERENCES Crew(ID) ON DELETE CASCADE NOT NULL,
    BulletinId INT FOREIGN KEY REFERENCES Bulletin(ID) ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (CrewID,BulletinId)
)

CREATE TABLE CurrencyTracker.dbo.Requirement (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    DaysValid INT,
    NeverExpiresFlag INT NOT NULL,
    Constraint requirementNeverExpires check (NeverExpiresFlag in (0,1))
)

CREATE TABLE CurrencyTracker.dbo.FlightRequirement (
    ID INT PRIMARY KEY FOREIGN KEY References Requirement(ID) ON DELETE CASCADE,
    RequiredLaunches INT NOT NULL,
    RequiredRecoveries INT NOT NULL,
    RequiredLowPass INT NOT NULL,
    RequiredMissionTime DECIMAL NOT NULL
)

CREATE TABLE CurrencyTracker.dbo.Activity (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(155) NOT NULL UNIQUE
)

CREATE TABLE CurrencyTracker.dbo.RequirementActivities (
    RequirementId INT FOREIGN KEY REFERENCES Requirement(ID) ON DELETE CASCADE,
    ActivityId Int FOREIGN KEY REFERENCES Activity(ID) ON DELETE CASCADE,
    PRIMARY KEY(RequirementId, ActivityId)
)

CREATE TABLE CurrencyTracker.dbo.Role (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
)

CREATE TABLE CurrencyTracker.dbo.RoleRequirements (
    RequirementID INT FOREIGN KEY REFERENCES Requirement(Id) ON DELETE CASCADE,
    RoleID INT FOREIGN KEY REFERENCES Role(Id) ON DELETE CASCADE,
    PRIMARY KEY(RequirementId, RoleID)
)

CREATE TABLE CurrencyTracker.dbo.Mission (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    SiteId INT NOT NULL FOREIGN KEY REFERENCES Site(ID) ON DELETE CASCADE,
    Date DATETIME NOT NULL,
    LaunchNumber INT NOT NULL,
    AVTailNumber INT NOT NULL
)

CREATE TABLE CurrencyTracker.dbo.Log (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME NOT NULL, 
    ActivityId INT NOT NULL FOREIGN KEY REFERENCES Activity(ID) ON DELETE CASCADE,
    CrewID INT NOT NULL FOREIGN KEY REFERENCES Crew(ID) ON DELETE CASCADE
)

CREATE TABLE CurrencyTracker.dbo.FlightLog (
    ID INT NOT NULL FOREIGN KEY REFERENCES Log(ID) ON DELETE CASCADE PRIMARY KEY,
    MissionID INT NOT NULL FOREIGN KEY REFERENCES Mission(Id),
    MissionTime DECIMAL NOT NULL,
    Launch INT NOT NULL,
    Recovery INT NOT NULL,
    NumberOfLowPasses INT NOT NULL,
    RoleID INT NOT NULL FOREIGN KEY REFERENCES Role(ID) ON DELETE CASCADE
)

CREATE TABLE CurrencyTracker.dbo.CrewRoles (
    CrewId INT NOT NULL FOREIGN KEY REFERENCES Crew(ID) ON DELETE CASCADE,
    RoleId INT NOT NULL FOREIGN KEY REFERENCES Role(ID) ON DELETE CASCADE
)
