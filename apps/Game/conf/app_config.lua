
local config = {
    numOfJobWorkers = 0,
    websocketMessageFormat = "pbc",
    mysql = {
        --path = "/tmp/mysql.sock",
        path = "/var/run/mysqld/mysqld.sock",
        --host = "192.168.0.55",
        --port = 3306,
        database = "gameServer",
        --user = "funkii",
        --password = "12345678",
        user = "root",
        password = "qcfs_db20180628",
        max_packet_size = 1024 * 1024,
    },
}

return config
