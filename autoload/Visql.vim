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
    
    if confirm_to_close_if_already_connected() == False:
        return
    
    conn_infos = db_helper.get_db_conn_infos(config_path)
    cnt = 1
    for conn_info in conn_infos:
        print "{0}: [{1}] {2}@{3}:{4}".format(cnt, conn_info.connection_name, conn_info.user, conn_info.host, conn_info.port)
        cnt += 1
    
    cnt -= 1
    vim.command("echohl WildMenu")
    
    input = 0
    
    while input <= 0 or input > cnt:
        input = vim.eval('input("Which one do you want to connnect [1~{0}]: ", "")'.format(cnt))
        
        try:
            input = int(input)
        except ValueError:
            input = 0 

        if input <= 0 or input > cnt:
            if cnt == 1:
                print " please insert 1"
            else:
                print " please insert between 1 and {0}".format(cnt)

    vim.command("echohl None")

def confirm_to_close_if_already_connected():
    global connection_offset
    global conn_infos
    global db_conn

    if db_conn is None:
        return
    
    conn_info = conn_infos[connection_offset]
    
    print "Already connected at [{0}] {1}@{2}:{3}".format(conn_info.description, conn_info.user, conn_info.host, conn_info.port)

    input = vim.eval('confirm("&Close and Open new connection\n&Stay there", 1)')
    
    if input == 1:
        return True
    else:
        return False

def close_db_connection():
    global db_conn

    if db_conn is None:
        print "Not yet connected"
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

    sql = get_buf_content()

    description, rows = run_sql_at_db(sql)

    if rows is None:
        return
    
    # create new window
    vim.command(":sp");
    
    num_of_windows = len(vim.windows)

    # go to the newly created window (second window)
    vim.command(":wincmd j")
    vim.command("e " + str(run_cnt) + ".txt")
    
    # Header 출력
    header = "|"
    seperator = "|"
    
    col_lens = []

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

    for row in rows:
        line = "|"
        cnt = 0
        for col in row:
            line += (" %" + str(col_lens[cnt]) + "s |") % (str(col))
            cnt += 1

        vim.current.buffer.append(line.replace('\n', '\\n'))
    
    vim.command("set nomodifiable")

    run_cnt += 1

def run_sql_at_db(sql):
    
    global db_conn
    global config_path
    global conn_infos

    # 기 연결된 connection이 끊긴 것도 확인해야 함
    try:
        if (db_conn is None):
            db_conn = MySQLdb.connect(host='127.0.0.1',
                                  port=3306,
                                  user='root',
                                  passwd='',
                                  db = 'jsheo')
        
        # db_conn.get_conn().ping(True)

        cursor = db_conn.cursor()

        cursor.execute(sql)
        return  [cursor.description, cursor.fetchall()]

    except MySQLdb.Error, e:
        print "Error %d: %s" % (e.args[0], e.args[1])
        return None
   
def format_sql(sql):
    import sqlparse
    import vim
    
    arr = ['a', 'b']
    formatted = sqlparse.format(sql, reindent = True, keyword_case = 'upper')
    
    del vim.current.buffer[:]
    vim.current.buffer.append(formatted.split("\n"))
    del vim.current.buffer[0] # 젤 첫 줄에 empty line 삭제

endPython

command! Vconnect call Vconnect()
command! Vclose call Vclose()
command! Vformat call VFormatSQL()
command! Vrun call VRunSQL()
