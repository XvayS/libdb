uses database;

procedure test_sqlite(FilePath: String);
var
    {$IFDEF INSERT}
    i: Integer;
    {$ENDIF}
    DBFile: TFileStream;
begin
    if File.CheckAccess(FilePath) then
        if File.Exists(FilePath) then begin
            WriteLn('[*] Found: '+FilePath)
        end else begin
            WriteLn('[!] Not found: '+FilePath);
            try
                DBFile := File.CreateFileStream;
                DBFile.SaveToFile(FilePath);
                DBFile.Free;
                WriteLn('[*] Created: '+FilePath);
            except
                WriteLn('Exception: '+ExceptionParam);
                exit;
            end;
        end
    else begin
        WriteLn('Access denied: '+FilePath);
        exit;
    end;

    if DatabaseOpen(DB_Any, FilePath, '', '', DB_Plugin_SQLite) then begin
        if DatabaseQuery(DatabaseID, 'SELECT sqlite_version()') and DB_NextRow(DatabaseID) then begin
            WriteLn('[SQLite v'+DB_GetString(DatabaseID, 0)+ ']');
            DB_FinishQuery(DatabaseID);
        end;

        if DatabaseUpdate(
            DatabaseID,
            'CREATE TABLE IF NOT EXISTS test( '+
                'id INTEGER PRIMARY KEY AUTOINCREMENT, '+
                'name TEXT, '+
                'number INTEGER, '+
                'ratio FLOAT '+
            ');'
        ) then begin
            {$IFDEF INSERT}
            DB_Update(DatabaseID, 'BEGIN;');

            for i := 1 to 3 do begin
                DB_SetString(DatabaseID, 0, '''Name''#'+IntToStr(i));
                DB_SetLong(DatabaseID, 1, i * 10);
                DB_SetFloat(DatabaseID, 2, i / 10.0);

                DatabaseUpdate(DatabaseID, 'INSERT INTO test(name, number, ratio) VALUES(?, ?, ?);');
            end;

            DB_Update(DatabaseID, 'COMMIT;');
            {$ENDIF}

            if DatabaseQuery(DatabaseID, 'SELECT * FROM test;') then begin
                DatabasePrintValues(DatabaseID);
                DB_FinishQuery(DatabaseID);
            end;
        end;

        DB_Close(DatabaseID);
    end;
end;

procedure test_mysql(ConnectionString, User, Password: String);
{$IFDEF INSERT}
var
    i: Integer;
{$ENDIF}
begin
    if DatabaseOpen(DB_Any, ConnectionString, User, Password, DB_Plugin_MySQL) then begin
        if DatabaseQuery(DatabaseID, 'SELECT @@version;') and DB_NextRow(DatabaseID) then begin
            WriteLn('[MySQL v'+DB_GetString(DatabaseID, 0)+ ']');
            DB_FinishQuery(DatabaseID);
        end;

        if DatabaseUpdate(
            DatabaseID,
            'CREATE TABLE IF NOT EXISTS test( '+
                'id INTEGER PRIMARY KEY AUTO_INCREMENT, '+
                'name VARCHAR(25), '+
                'number INTEGER, '+
                'ratio FLOAT '+
            ');'
        ) then begin
            {$IFDEF INSERT}
            DB_Update(DatabaseID, 'START TRANSACTION;');

            for i := 1 to 3 do begin
                DB_SetString(DatabaseID, 0, '''Name''#'+IntToStr(i));
                DB_SetLong(DatabaseID, 1, i * 10);
                DB_SetFloat(DatabaseID, 2, i / 10.0);

                DatabaseUpdate(DatabaseID, 'INSERT INTO test(name, number, ratio) VALUES(?, ?, ?);');
            end;

            DB_Update(DatabaseID, 'COMMIT;');
            {$ENDIF}

            if DatabaseQuery(DatabaseID, 'SELECT * FROM test;') then begin
                DatabasePrintValues(DatabaseID);
                DB_FinishQuery(DatabaseID);
            end;
        end;

        DB_Close(DatabaseID);
    end;
end;

procedure test_postgresql(ConnectionString, User, Password: String);
{$IFDEF INSERT}
var
    i: Integer;
{$ENDIF}
begin
    if DatabaseOpen(DB_Any, ConnectionString, User, Password, DB_Plugin_PostgreSQL) then begin
        if DatabaseQuery(DatabaseID, 'SHOW server_version;') and DB_NextRow(DatabaseID) then begin
            WriteLn('[PostgreSQL v'+DB_GetString(DatabaseID, 0)+ ']');
            DB_FinishQuery(DatabaseID);
        end;

        if DatabaseUpdate(
            DatabaseID,
            'CREATE TABLE IF NOT EXISTS test( '+
                'id SERIAL PRIMARY KEY, '+
                'name VARCHAR(25), '+
                'number INTEGER, '+
                'ratio FLOAT '+
            ');'
        ) then begin
            {$IFDEF INSERT}
            DB_Update(DatabaseID, 'BEGIN;');

            for i := 1 to 3 do begin
                DB_SetString(DatabaseID, 0, '''Name''#'+IntToStr(i));
                DB_SetLong(DatabaseID, 1, i * 10);
                DB_SetFloat(DatabaseID, 2, i / 10.0);

                DatabaseUpdate(DatabaseID, 'INSERT INTO test(name, number, ratio) VALUES($1, $2, $3);');
            end;

            DB_Update(DatabaseID, 'COMMIT;');
            {$ENDIF}

            if DatabaseQuery(DatabaseID, 'SELECT * FROM test;') then begin
                DatabasePrintValues(DatabaseID);
                DB_FinishQuery(DatabaseID);
            end;
        end;

        DB_Close(DatabaseID);
    end;
end;

begin
    test_sqlite('~/test.db');
    test_mysql('host=localhost port=3306 dbname=test', 'user', 'password');
    test_postgresql('host=localhost port=5432 dbname=test', 'user', 'password');
end.
