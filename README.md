Disclaimer
==========

Please note that Vimsql is a premature plugin and it might have many bugs. Be careful when executing `INSERT`/`UPDATE`/`DELETE`/`ALTER` etc.

Vimsql은 아직 만들어진지 얼마 안 되는 plugin이며 버그가 있을 수 있습니다. `INSERT`/`UPDATE`/`DELETE`/`ALTER` 등의 쿼리를 수행할 때는 주의하세요.


Introduction
============

Vimsql is a Vim Plugin developed with Python 2. Using Vimsql, you can edit SQL, run SQL, view results in Vim. Currently, only MySQL is supported. You can pronounce `Vimsql` as `vims-kju-el` (not `Vim-es-kju-el`)

Vimsql은 Python 2로 개발된 Vim plugin입니다. Vimsql을 이용하여 Vim 안에서 SQL을 편집하고, 실행한 뒤 결과를 확인할 수 있습니다. 현재는 MySQL만 지원하고 있습니다. 발음은 `빔스큐엘`이라고 발음하시면 됩니다.

Screenshots
===========
[![Vimsql Screenshot](http://img.youtube.com/vi/6ovYivP-O0U/0.jpg)](http://www.youtube.com/watch?v=6ovYivP-O0U)

Click above image to play a youtube video.

Installation
============

Prerequisite
------------

Vimsql requires Vim 7.4. In addition, Vimsql uses two python libraries, [`MySQLdb`][1] and [`sqlparse`][2]. You should install these two libraries before use Vimsql.

### installing `MySQLdb`

```
$ pip install MySQL-python
```

If you have any problems when installing, visit [this web page][3]. MySQLdb is little bit difficult to install but, it is faster than MySQL Connector/Python.

설치가 잘 안 된다면 [MySQL-python 모듈 설치][4]에 잘 설명되어 있으니 읽어보세요. MySQLdb는 MySQL C API로 개발된 프로그램이라서 (속도가 빠르다는 장점이 있지만) 설치를 위해서는 MySQL client library도 필요합니다.

### installing `sqlparse`

```
$ pip install sqlparse
```

Installing Vimsql
------------------

Installing Vimsql depends on your vim package manager.

Vimsql을 설치하는 방법은 각자 사용하는 패키지 매니저에 따라 다릅니다. 초보자의 경우 [`Vundle`][6]이라는 것을 사용해보시길 추천합니다. Vim plugin을 만들면서 제일 고생했던 부분이 Package Manager에 대한 개념을 잡는 일이었습니다. KLDP에 [훌륭한 강좌][7]가 올라와 있으므로 꼭 읽어보시기 바랍니다.

### with `pathogen`

Actually, [`pathogen`][5] is not a vim package manager but the Runtime Path Manipulator. Anyway Vimsql can be installed like below if your are using `pathogen`

```
$ cd ~/.vim/bundle/
$ git clone https://github.com/mysqlguru/Vimsql.git
```

[`pathogen`][5]은 엄밀히 말하자면 패키지 매니저는 아니지만, Plugin 설치를 쉽게 도와줍니다. 이미 `pathogen`을 사용하는 분이라면 위의 방법으로 설치하면되지만, 가급적 아래에 있는 `Vundle`을 이용하기길 추천합니다.

### with `Vundle`

[`Vundle`][6] is a great vim package manager. Visit [Vundle's homepage][6] to get and install `Vundle`. After installing `Vundle`, Vimsql could be installed like this:

1. Add `mysqlguru/Vimsql` between `call vundle#begin()` and `call vundle#end()` in your `.vimrc`
1. Save `.vimrc`
1. open new vim
1. run `:PluginInstall`

To verify successfully installed, check `~/.vim/bundle/Vimsql/` exists.

### with other package managers

I don't know how to install vim plugins without `pathogen` or `Vundle`. Please read your package manager's manual.

How to use & Available Commands
===============================

Windows Layouts
---------------

- Editor Window
    - When you open vim, this windows is a Editor Window.
    - You can edit and run SQLs only in a Editor Window.
- Result Window
    - Every time you run queries one or more windows will be split.
    - These windows are called as Result Windows.
    - Queries' output will be written in Result Windows.
    - You cannot run queries in a Result Window.

Below image (after run `:VRunHorizontal`) describes the layout.

![windows_layout](https://cloud.githubusercontent.com/assets/7676291/10261772/18aaea42-69e2-11e5-9cf1-8c7ce217a046.png)

Configuring DB connection information
-------------------------------------

The first thing you need to do is configuring DB connection information. To do that, edit ~/.vim/bundle/plugin/db_connections.conf` like this:

```
$ cd ~/.vim/bundle/Vimsql/plugin/
$ cp db_connections.conf.example db_connections.conf
```

Some examples:

```
[test_server]
# Via TCP Socket

host = 127.0.0.1
port = 3306
# unix_socket = optional
user = root

# You will be asked for the password, if password is not given
password = 
db_name =  your_db_name
connect_timeout = 2

[real_server]
# Via Unix Socket

# host = not used
# port = not used
unix_socket = /tmp/mysql.sock
user = test_user
password = pass1234
db_name = 
connect_timeout = 0
```

Commands
--------

|Command|Explanation|
|-------|------------|
|`:VConnect`|Connect to MySQL Server|
|`:VFormat`|Pretty Printer|
|`:VRunHorizontal`|Run SQLs and print each result in horizontally split windows|
|`:VRunVertical`|Run SQLs and print each result in vertically split windows|
|`:VRunBatch`|Run SQLs and print all result in one windows|
|`:VCloseResultWindow`|Close current Result Window|
|`:VCloseAllResultWindows`|Close all Result Windows|
|`:VGoToEditorWindow`|Go to Editor Window|
|`:VClose`|Close MySQL Connection|
|`:VQuit`|Close all vim windows and exit Vim|

Navigating Windows
-------------------------

Result Windows are just a split windows. So you can move around any windows using vim's windows command. For example, execute \[C-w][C-w] so that you move to next split window.

Known Issues
============

- While Queries are executing, vim will be blocked. The only way to interrupt execution is killing vim (`$ kill -9 <pid>`). Please note that even though vim is killed, the executing query runs in MySQL server.
- If column has a new line, it will be replaced `\n` in the Result Window.

Related Works
=============

dbext
-----
[dbext][8] has been developed over 10 years ago.

### pros

It supports many exsting databases. dbext can executing queries in your programming codes. For example, if your program has following code:

```
string sql = "SELECT s.script, ts.event, t.name , s.script_language, sv.name 
             FROM ml_script s, ml_table_script ts, ml_table t,
                         ml_script_version sv 
             WHERE s.script_id   = " + script_version + " 
                 AND ts.version_id = " + obj.method() + " 
                 AND ts.table_id   = t.table_id"
```

when you execute above query, dbext will prompt you for `version_id` and `table_id`.  Yes, dbext is powerful!

dbext supports many programming languages including java, C++.

### cons

Assuming you are using MySQL. Each time you execute queries using dbext, `mysql` (MySQL's client program) is invoked and vim buffer is redirected to `mysql`. Finally `mysql`'s output is appended in vim. In this approach, a transaction is only affected each execution. Fortunately, you can use dbext with `Perl DBI`. But it was slower than Python's `MySQLdb`.
dbext is written in Perl. I'm new to both Perl and Python. Personally, Python was easy to read for me.

Compared to dbext, Vimsql only supports MySQL and static queries. Please note that Vimsql is a only 2 month old tool.

Future work
===========

If possible, I would like to implement:

1. Auto Completion
1. Edit your data in Vim's Result Window after SELECT as you do with GUIs (like Navicat or SQLYog.)

Please star this project in github if you want these features. I'm highly anticipating your contribution.


[1]: http://mysql-python.sourceforge.net/MySQLdb.html
[2]: https://github.com/andialbrecht/sqlparse
[3]: http://mysql-python.blogspot.kr/2012/11/is-mysqldb-hard-to-install.html
[4]: http://zetawiki.com/wiki/MySQL-python_%EB%AA%A8%EB%93%88_%EC%84%A4%EC%B9%98
[5]: https://github.com/tpope/vim-pathogen
[6]: https://github.com/VundleVim/Vundle.vim
[7]: https://kldp.org/node/125263
