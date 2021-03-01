// =====================================
//          C O N S T A N T S
// =====================================
{ Database plugins enumeration
  for the DB_Open() function   }
Const DB_Plugin_ODBC       = 1;
Const DB_Plugin_SQLite     = 2;
Const DB_Plugin_PostgreSQL = 3;

{ Database column types enumeration 
  for the DB_ColumnType() function  }
Const DB_Type_Double = 1;
Const DB_Type_Float  = 2;
Const DB_Type_Long   = 3;
Const DB_Type_String = 4;

// =====================================
//        D E C L A R A T I O N S
// =====================================
Procedure DB_Close(DatabaseID: Integer);
External 'DB_Close@libdb.so cdecl';

Function DB_ColumnName(DatabaseID, Column: Integer): PChar;
External 'DB_ColumnName@libdb.so cdecl';

Function DB_ColumnSize(DatabaseID, Column: Integer): Integer;
External 'DB_ColumnSize@libdb.so cdecl';

Function DB_ColumnType(DatabaseID, Column: Integer): Integer;
External 'DB_ColumnType@libdb.so cdecl';

Function DB_Columns(DatabaseID: Integer): Integer;
External 'DB_Columns@libdb.so cdecl';

Function DB_Error(): PChar;
External 'DB_Error@libdb.so cdecl';

Function DB_Query(DatabaseID: Integer; Query: PChar): Integer;
External 'DB_Query@libdb.so cdecl';

Function DB_Update(DatabaseID: Integer; Query: PChar): Integer;
External 'DB_Update@libdb.so cdecl';

Procedure DB_FinishQuery(DatabaseID: Integer);
External 'DB_FinishQuery@libdb.so cdecl';

Function DB_FirstRow(DatabaseID: Integer): Integer;
External 'DB_FirstRow@libdb.so cdecl';

Function DB_GetDouble(DatabaseID, Column: Integer): Double;
External 'DB_GetDouble@libdb.so cdecl';

Function DB_GetFloat(DatabaseID, Column: Integer): Single;
External 'DB_GetFloat@libdb.so cdecl';

Function DB_GetLong(DatabaseID, Column: Integer): LongInt;
External 'DB_GetLong@libdb.so cdecl';

Function DB_GetString(DatabaseID, Column: Integer): PChar;
External 'DB_GetString@libdb.so cdecl';

Function DB_IsDatabase(DatabaseID: Integer): Integer;
External 'DB_IsDatabase@libdb.so cdecl';

Function DB_NextRow(DatabaseID: Integer): Integer;
External 'DB_NextRow@libdb.so cdecl';

Function DB_Open(DatabaseID: Integer; DatabaseName, User, Password: PChar; Plugin: Integer): Integer;
External 'DB_Open@libdb.so cdecl';

Function DB_ExamineDrivers(): Integer;
External 'DB_ExamineDrivers@libdb.so cdecl';

Function DB_NextDriver(): Integer;
External 'DB_NextDriver@libdb.so cdecl';

Function DB_DriverDescription(): PChar;
External 'DB_DriverDescription@libdb.so cdecl';

Function DB_DriverName(): PChar;
External 'DB_DriverName@libdb.so cdecl';

// =====================================
//            E X A M P L E S
// =====================================
function CheckDatabaseUpdate(Database: Integer; Query: PChar): Integer;
var
	Check: Integer;
begin
	WriteLn('>'+Query); //debug output
	Check:= DB_Update(Database, Query);
	
	if Check = 0 then
		WriteLn(DB_Error());
	
	Result:= Check;
end;


procedure create_db1();
var
  db_path: String;
begin
	db_path:= 'test.db';
	//creating a new file if not exists
	if Not FileExists(db_path) then
		if WriteFile(db_path,'') then
			WriteLn('File "'+db_path+'" created...');
	
	if DB_Open(0, db_path, '', '', DB_Plugin_SQLite) <> 0 then
	begin
		WriteLn('Database "'+db_path+'" opened...');
		CheckDatabaseUpdate(0, 'CREATE TABLE IF NOT EXISTS test(id INTEGER PRIMARY KEY, name STRING, value INTEGER);');
		CheckDatabaseUpdate(0, 'INSERT INTO test(name, value) VALUES("name1", 5);');
		CheckDatabaseUpdate(0, 'INSERT INTO test(name, value) VALUES("name2", 10);');
		CheckDatabaseUpdate(0, 'INSERT INTO test(name, value) VALUES(''name3'', 15);');
		WriteLn('Values inserted...');
		DB_Close(0);
		writeln('Database "'+db_path+'" closed...');
	end;
end;


procedure create_db2();
var
  db_path: String;
  query: String;
  db, i: Integer;
begin
	db_path:= 'test.db';
	//creating a new file if not exists
	if (Not FileExists(db_path)) then
		if (WriteFile(db_path,'')) then
			WriteLn('File "'+db_path+'" created...');
	
	db:= 0;
	if DB_Open(db, db_path, '', '', DB_Plugin_SQLite) <> 0 then
	begin
		WriteLn('Database "'+db_path+'" opened...');
		query:= 'CREATE TABLE IF NOT EXISTS test(';
		query:= query+'id INTEGER PRIMARY KEY, ';
		query:= query+'name TEXT NOT NULL, ';
		query:= query+'value INTEGER, ';
		query:= query+'UNIQUE(name) ON CONFLICT IGNORE);';
		if CheckDatabaseUpdate(db, query) <> 0 then
		begin
			DB_Update(db, 'BEGIN;');
			for i:= 1 to 20 do
				CheckDatabaseUpdate(db, 'INSERT INTO test(name, value) VALUES("name'+IntToStr(i)+'", '+IntToStr(i)+');');

			DB_Update(db, 'COMMIT;');
			WriteLn('Values inserted...');
		end;
		DB_Close(db);
		WriteLn('Database "'+db_path+'" closed...');
	end;
end;


procedure query_db(param: Integer);
var
  db_path, query, result_srt: String;
  i, columns: Integer;
begin
	db_path:= 'test.db';
	if DB_Open(0, db_path, '', '', DB_Plugin_SQLite) <> 0 then
	begin
		WriteLn('Database "'+db_path+'" opened...');
		query:= 'SELECT * FROM test WHERE value > '+IntToStr(param)+';';
		if DB_Query(0, query) <> 0 then
		begin
			WriteLn('>'+query); //debug output
			columns:= DB_Columns(0);
			while DB_NextRow(0) <> 0 do
			begin
				result_srt:='';
				for i:= 0 to columns - 1 do
					result_srt:= result_srt +DB_ColumnName(0, i)+': '+DB_GetString(0, i)+'; ';
				
				WriteLn(result_srt);
			end;
			
			DB_FinishQuery(0);
		end;
	
		DB_Close(0);
		WriteLn('Database "'+db_path+'" closed...');
	end
	else
		WriteLn('Can not open database "'+db_path+'"!');
end;


procedure drivers();
begin
	if DB_ExamineDrivers() <> 0 then
	begin
		WriteLn('ODBC drivers installed:');
		while DB_NextDriver() <> 0 do
		begin
			WriteLn('Name - '+DB_DriverName());
			WriteLn('Desc - '+DB_DriverDescription());
			WriteLn('* * * * *');
		end;
	end
	else
		WriteLn('No ODBC drivers installed!');
end;


procedure OnAdminMessage(IP, Msg: String);
begin
	case LowerCase(Msg) of
	'/create1' : create_db1();
	'/create2' : create_db2();
	'/query1'  : query_db(7);
	'/query2'  : query_db(14);
	'/drivers' : drivers();
	end;
end;
