CREATE LOGIN StajyerAnalizci WITH PASSWORD = 'AnalizSifre123!';

USE BLM4522;
CREATE USER StajyerUser FOR LOGIN StajyerAnalizci;

ALTER ROLE db_datareader ADD MEMBER StajyerUser;

ALTER ROLE db_datawriter ADD MEMBER StajyerUser;