#!/usr/bin/env python

import ConfigParser
import os.path

class DBConnInfo:
    connection_name = ""
    host = ""
    port = 0
    user = ""
    password = ""
    db_name = ""

    var_names = ["host", "port", "user", "password", "db_name"]

    def __init__(self, section_name, config):
        for var_name in self.var_names:
            try:
                exec ("self." + var_name + " = config.get('" + section_name + "', '" + var_name + "')")
    
                self.connection_name = section_name
            except ConfigParser.NoOptionError, e:
                print ("config parse error: '%s' not found in [%s]") % (var_name, section_name)
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
