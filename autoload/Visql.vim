" below 2 lines are excerpted from
" [clighter](https://github.com/bbchung/clighter)

let s:script_folder_path = escape( expand( '<sfile>:p:h' ), '\' )
exe 'python sys.path = sys.path + ["' . s:script_folder_path . '"]'
exe 'python config_path = "' . s:script_folder_path . '/db_connection.conf"'

function! Vconnect()
    py connect_to_db()
endfunction

function! Vclose()
    py close_db_connection()
endfunction

function! VRunSQL() range
    py run_sql()
endfunction " end of RunSQL()

function! VFormatSQL() range
    py sql = get_buf_content()
    py format_sql(sql)
endfunction " end of FormatSQL()

python << endPython

import db_helper
import vim
import MySQLdb
import time
    
db_conn = None
run_cnt = 1
connection_offset = None
conn_infos = None

def connect_to_db():

    global db_conn
    global conn_infos
    global connection_offset
    
    if confirm_to_close_if_already_connected() == False:
        return
    
    conn_infos = db_helper.get_db_conn_infos(config_path)
    if (conn_infos is None):
        # config error
        return

    connection_offset = get_connection_offset()
    conn_info = conn_infos[connection_offset]
    
    print " \nTrying to connect...."

    try:
        db_conn = MySQLdb.connect(host    = conn_info.host,
                                  port    = int(conn_info.port),
                                  user    = conn_info.user,
                                  passwd  = conn_info.password,
                                  db      = conn_info.db_name,
                                  connect_timeout = conn_info.connect_timeout)

        print_hl_msg("Connected ...")

    except MySQLdb.Error, e:
        print_hl_msg("Can't connect: Error %d: %s" % (e.args[0], e.args[1]))
        connection_offset = None
        db_conn = None

def confirm_to_close_if_already_connected():
    global connection_offset
    global conn_infos
    global db_conn

    if db_conn is None:
        return
    
    conn_info = conn_infos[connection_offset]
    
    print_hl_msg("Already connected at [{0}] {1}@{2}:{3}".format(conn_info.description, conn_info.user, conn_info.host, conn_info.port))

    input = vim.eval('confirm("&Close and Open new connection\n&Stay there", 1)')
    
    if input == 1:
        return True
    else:
        return False

def get_connection_offset():
    global conn_infos

    cnt = 1

    for conn_info in conn_infos:
        print "{0}: [{1}] {2}@{3}:{4}".format(cnt, conn_info.connection_name, conn_info.user, conn_info.host, conn_info.port)
        cnt += 1
    
    cnt -= 1
    user_input = 0
    
    while user_input <= 0 or user_input > cnt:
        user_input = vim.eval('input("Which one do you want to connnect [1~{0}]: ", "")'.format(cnt))
        
        try:
            user_input = int(user_input)
        except ValueError:
            user_input = 0 

        if user_input <= 0 or user_input > cnt:
            if cnt == 1:
                print_hl_msg(" please insert 1")
            else:
                print_hl_msg(" please insert between 1 and {0}".format(cnt))

    return user_input - 1 

def close_db_connection():
    global db_conn

    if db_conn is None:
        print_hl_msg("Not yet connected")
        return

    db_conn.close()

    print "Closed"

    db_conn = None
    db_connection_offset = None

def get_buf_content():

    lines = vim.current.buffer

    return '\n'.join(lines)

def get_visual_selection():
    # This codes are from https://github.com/JarrodCTaylor/vim-plugin-starter-kit/wiki/Interactions-with-the-buffer
    buf = vim.current.buffer
    (starting_line_num, col1) = buf.mark('<')
    (ending_line_num, col2) = buf.mark('>')

    lines = vim.eval('getline({}, {})'.format(starting_line_num, ending_line_num))
    lines[0] = lines[0][col1:]
    lines[-1] = lines[-1][:col2 + 1]
    # return lines, starting_line_num, ending_line_num, col1, col2
    return "\n".join(lines)

def run_sql():

    global run_cnt
    global db_conn

    if (db_conn is None):
        print_hl_msg("Not connected. run :Vconnect before run")
        return None

    sql = get_buf_content()
    
    print "Running SQL..."

    (description, rows) = db_helper.run_sql_at_db(sql, db_conn)

    if (description is None):
    # An error occurred during execution
    # rows has an MySQL.Error
        print_hl_msg("Error ({0}): {1}".format(rows.args[0], rows.args[1]))
        return

    if rows is None:
        return
    
    # create new window
    vim.command(":sp");
    
    num_of_windows = len(vim.windows)

    # go to the newly created window (second window)
    vim.command(":wincmd j")
    vim.command("e " + str(run_cnt) + ".txt")

    vim.command("set modifiable")
    
    # Header 출력
    header = "|"
    seperator = "|"
    
    col_lens = []

    # Print column header
    for col_info in description:
        # col_info[0] = column name
        # col_info[1] = ??
        # col_info[2] = max data size

        col_name = col_info[0]
        max_data_size = col_info[2]

        col_len = max(len(col_name), max_data_size)

        col_lens.append(col_len)
        header += (" %-" + str(col_len) + "s |") % (col_name)
        seperator += "" + "-" * (col_len + 2) + "|"

    vim.current.buffer[0] = header
    vim.current.buffer.append(seperator)
    
    # print Data
    for row in rows:
        line = "|"
        cnt = 0
        for col in row:
            line += (" %" + str(col_lens[cnt]) + "s |") % (str(col))
            cnt += 1

        vim.current.buffer.append(line.replace('\n', '\\n'))
    
    vim.command("set nomodifiable")
    vim.command(":wincmd k") # go to editor window

    run_cnt += 1
   
def format_sql(sql):
    import sqlparse
    import vim
    
    arr = ['a', 'b']
    formatted = sqlparse.format(sql, reindent = True, keyword_case = 'upper')
    
    del vim.current.buffer[:]
    vim.current.buffer.append(formatted.split("\n"))
    del vim.current.buffer[0] # 젤 첫 줄에 empty line 삭제

def print_hl_msg(msg):
    vim.command("echohl WildMenu")
    vim.command('echo "{0}"'.format(str(msg).replace('"', "'")))
    vim.command("echohl None")

endPython

command! Vconnect call Vconnect()
command! Vclose call Vclose()
command! Vformat call VFormatSQL()
command! Vrun call VRunSQL()
