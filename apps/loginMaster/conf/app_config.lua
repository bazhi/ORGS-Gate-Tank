
local config = {
    numOfJobWorkers = 0,
    
    mysql = {
        --path = "/tmp/mysql.sock",
        --"/var/run/mysqld/mysqld.sock",
        host = "192.168.0.55",
        port = 3306,
        database = "loginMaster",
        user = "funkii",
        password = "12345678",
        max_packet_size = 1024 * 1024,
    },
}

return config
