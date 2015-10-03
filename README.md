Introduction
============

Navisql is a Vim Plugin developed with Python 2. Using Navisql, you can edit SQL, run SQL, view results in Vim.

Navisql은 Python 2로 개발된 Vim plugin입니다. Navisql을 이용하여 Vim 안에서 SQL을 편집하고, 실행한 뒤 결과를 확인할 수 있습니다.

Installation
============

Prerequisite
------------

Navisql requires Vim 7.4. Navisql uses two python libraries, [`MySQLdb`][1] and [`sqlparse`][2].

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

Installing Navisql
------------------

Installing Navisql depends on your Vim package manager.

Configuring DB connection information
===================================

How to use & Available Commands
=====================

Windows Layouts
---------------

- 그림 필요
- Editor window, Result Windows

:VConnect
---------

:VFormat
--------

:VRunHorizontal
---------------

:VRunVertical
-------------

:VRunBatch
----------

:VClose
-------

:VCloseResultWindow
-------------------

:VCloseAllResultWindows
-----------------------

:VGoToEditorWindow
------------------

:VQuit
------

- Close an Editor window
- and close all result windows
- and finally exit Vim

Known Issues
============

[1]: http://mysql-python.sourceforge.net/MySQLdb.html
[2]: https://github.com/andialbrecht/sqlparse
[3]: http://mysql-python.blogspot.kr/2012/11/is-mysqldb-hard-to-install.html
[4]: http://zetawiki.com/wiki/MySQL-python_%EB%AA%A8%EB%93%88_%EC%84%A4%EC%B9%98
