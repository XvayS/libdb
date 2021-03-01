<div align="center">
    <img src="https://apps.soldat2d.com/projects/libdb/logo/48x48.png">
</div>

# libdb

## About

**libdb** is an external library for [Soldat](https://github.com/Soldat/soldat) dedicated servers (Windows and Linux) to access SQLite, MySQL/MariaDB, PostgreSQL or any database type (Oracle, Access, etc) via ODBC.

## Usage

An attached archive from the releases section has the following structure:

    libdb-0.3.dll
    libdb-0.3.so
    libmariadb.dll
    libmariadb.so
    scripts
    ├── libdb
    │   ├── database.pas
    │   └── libdb.pas
    └── libdb_test
        ├── config.ini
        └── main.pas

Where `libdb.pas` is a unit with external functions bindings, `database.pas` is a unit with some helper functions and `libdb_test` folder contains an example script that demonstrates the use of `libdb` with SQLite, MySQL/MariaDB and PostgreSQL.

You should extract an archive into the root directory of your Soldat server. Thus `*.dll` and `*.so` files will be placed near to `soldatserver.exe` (Windows) or `soldatserver` (Linux) executables and the rest of the files will be copied into the `./scripts` directory of your server.

Make sure you have `AllowDlls` enabled in the [server.ini](https://wiki.soldat.pl/index.php/SC3_Config_File).

## Notes

### Windows

Everything should work out of the box.

### Linux

`libdb-0.3` depends on `unixODBC`.
For Debian-based distros you could use the following command to install dependencies:

```bash
sudo apt install libodbc1:i386 libltdl7:i386
```

There could be a need to add soldatserver's directory into the `LD_LIBRARY_PATH` environment variable to use external library functions with Soldat server. There are a lot ways of doing it, so here are few of simple ones:

-
    ```bash
    LD_LIBRARY_PATH="$PWD" ./soldatserver
    ```

    this will set current directory (for this particular run) as `LD_LIBRARY_PATH` and run the `soldatserver`

-
    ```bash
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/soldatserver && ./soldatserver
    ```

    this will add current directory to `LD_LIBRARY_PATH` and run the `soldatserver`

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Discussion

See the post on [forums.soldat.pl](https://forums.soldat.pl/index.php?topic=42012.0).
