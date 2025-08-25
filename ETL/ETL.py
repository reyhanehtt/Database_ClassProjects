import psycopg2

#connect to databases
source_con = psycopg2.connect(
    host = "localhost",
    database = "postgres",
    user = "postgres" ,
    password = ""
)
destination_con = psycopg2.connect(
    host = "localhost",
    database = "postgres",
    user = "postgres" ,
    password = ""
)

#get every table of the databases
source_cursor = source_con.cursor()
destination_cursor = destination_con.cursor()

select_query ="SELECT table_name" \
              "FROM information_schema.tables" \
              "WHERE table_type = 'BASE TABLE' " \
              "AND table_schema = 'public' "
source_cursor.execute(select_query)
source_list_name = source_cursor.fetchall()

destination_cursor.execute(select_query)
destination_list_name = destination_cursor.fetchall()

#for table in list_name:


#close connection
source_con.close()
destination_con.close()