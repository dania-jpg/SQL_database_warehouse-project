-- 1. Create the Database
CREATE DATABASE DataWarehouse;
GO

-- 2. Switch to the new Database
USE DataWarehouse;
GO

-- 3. Create the Medallion Architecture Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
