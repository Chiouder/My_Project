CREATE TABLE Locations (
    iso_code TEXT PRIMARY KEY,
    location_name TEXT NOT NULL,
    populations INTEGER
);

CREATE TABLE Manufacturers (
    Mname TEXT PRIMARY KEY
);

CREATE TABLE Vaccine_Sources (
    iso_code TEXT,
    LOD DATE,
    source_name TEXT,
    source_link TEXT NOT NULL,
    PRIMARY KEY (iso_code, LOD),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code)
);

CREATE TABLE Population_Sources (
    iso_code TEXT,
    Year INTEGER,
    p_source_link TEXT NOT NULL,
    record_populations INTEGER,
    PRIMARY KEY (iso_code, Year),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code)
);

CREATE TABLE Daily_Records (
    iso_code TEXT,
    date DATE,
    total_vaccinations INTEGER,
    people_fully_vaccinated INTEGER,
    total_boosters INTEGER,
    daily_vaccinations INTEGER,
    daily_people_vaccinated INTEGER,
    PRIMARY KEY (iso_code, date),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code)
);

CREATE TABLE Daily_Records_By_Age_Group (
    iso_code TEXT,
    date DATE,
    age_group TEXT,
    people_vaccinated_per_hundred REAL,
    people_fully_vaccinated_per_hundred REAL,
    people_with_booster_per_hundred REAL,
    PRIMARY KEY (iso_code, date, age_group),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code)
);

CREATE TABLE Certain_Country_Records (
    iso_code TEXT,
    date DATE,
    total_vaccinations INTEGER,
    people_vaccinated INTEGER,
    people_fully_vaccinated INTEGER,
    total_boosters INTEGER,
    PRIMARY KEY (iso_code, date),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code)
);

CREATE TABLE Region_Records (
    iso_code TEXT,
    date DATE,
    region_name TEXT,
    total_vaccinations INTEGER,
    total_distributed INTEGER,
    people_vaccinated INTEGER,
    people_fully_vaccinated_per_hundred REAL,
    total_vaccinations_per_hundred REAL,
    people_fully_vaccinated INTEGER,
    people_vaccinated_per_hundred REAL,
    distributed_per_hundred REAL,
    daily_vaccinations INTEGER,
    daily_vaccinations_per_million REAL,
    share_doses_used REAL,
    total_boosters_per_hundred REAL,
    PRIMARY KEY (iso_code, date, region_name),
    FOREIGN KEY (iso_code, date) REFERENCES Certain_Country_Records(iso_code, date)
);

CREATE TABLE Provides_Vaccines (
    iso_code TEXT,
    Mname TEXT,
    Date DATE,
    Quantity INTEGER,
    PRIMARY KEY (iso_code, Mname, Date),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code),
    FOREIGN KEY (Mname) REFERENCES Manufacturers(Mname)
);

CREATE TABLE Suppliers (
    iso_code TEXT,
    Mname TEXT,
    PRIMARY KEY (iso_code, Mname),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code),
    FOREIGN KEY (Mname) REFERENCES Manufacturers(Mname)
);

CREATE TABLE Provides_Vaccines_Certain_Country (
    iso_code TEXT,
    Mname TEXT,
    Date DATE,
    PRIMARY KEY (iso_code, Mname, Date),
    FOREIGN KEY (iso_code) REFERENCES Locations(iso_code),
    FOREIGN KEY (Mname) REFERENCES Manufacturers(Mname)
);
