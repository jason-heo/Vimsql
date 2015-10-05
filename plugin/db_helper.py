#!/usr/bin/env python
#-*- coding: utf-8 -*-

import MySQLdb
import ConfigParser
import os.path

class DBConnInfo:
    connection_name = ""
    host            = ""
    port            = 0
    user            = ""
    password        = ""
    db_name         = ""
    unix_socket     = ""

    var_names = ["host", "unix_socket",
                 "port", "user", "password", "db_name", "connect_timeout"]

    def __init__(self, section_name, config):
        for var_name in self.var_names:
            try:
                exec ("self." + var_name + " = config.get('" + section_name + "', '" + var_name + "')")
    
                self.connection_name = section_name
            except ConfigParser.NoOptionError, e:
                if (var_name == "unix_socket" \
                    or var_name == "host" \
                    or var_name == "port"):
                # unix socket and tcp info are optional
                    continue

                print ("config parse error: '%s' not found in [%s]") \
                       % (var_name, section_name)
                return None
        
        # convert string into integer: Ex) "3306" => 3306
        try:
            self.port = int(self.port)
        except ValueError:
            print "Error: {0}.port {1} is not integer".format(self.connection_name, self.port)

            return None
        
        if (self.connect_timeout == ""):
            self.connect_timeout = 0
        else:
        # convert string into integer
            try:
                self.connect_timeout = int(self.connect_timeout)
            except ValueError:
                print "Error: {0}.port {1} is not integer".format(self.connection_name, self.connect_timeout)

            return None

    def __str__(self):
        return str(__repr__())

    def __repr__(self):
        ret_val = ""

        con_info = {}
        con_info['connection_name'] = self.connection_name
        for var_name in self.var_names:

            exec("con_info['" + var_name + "'] = self." + var_name)

        ret_val += str(con_info) + "\n"

        return ret_val

def get_db_conn_infos(conf_path):

    if os.path.isfile(conf_path) == False:
        print ("'%s' not exists") % (conf_path)
        return None

    config = ConfigParser.SafeConfigParser()
    config.read(conf_path)

    ret_val = []

    for section_name in config.sections():
        conn_info = (DBConnInfo(section_name, config))
        if (conn_info is None):
            return None
        ret_val.append(conn_info)

    return ret_val

def run_sql_at_db(sql, db_conn):

    try:
        if (db_conn is None):
            print "Not connected, run :Vconnect first"
            return

        db_conn.ping(True)

        cursor = db_conn.cursor()
        
        try:
            cursor.execute(sql)
        except MySQLdb.Error, e:
            print "Error %d: %s" % (e.args[0], e.args[1])
            return None
        
        return cursor

    except MySQLdb.Error, e:
        print "Error %d: %s" % (e.args[0], e.args[1])
        return None

