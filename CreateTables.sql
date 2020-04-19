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
