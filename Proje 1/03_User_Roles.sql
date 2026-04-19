CREATE LOGIN StajyerLogin WITH PASSWORD = '1234';

USE BLM4522;
CREATE USER Stajyer FOR LOGIN StajyerLogin;

ALTER ROLE db_datareader ADD MEMBER Stajyer;

ALTER ROLE db_datawriter ADD MEMBER Stajyer;