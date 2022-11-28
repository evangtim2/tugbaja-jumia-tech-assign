#!/bin/bash
DATABASE_PASS='admin123'

# starting & enabling postgresqldb-server
sudo service postgresql-14.2 initdb
sudo service postgresql-14.2 start
cd /tmp/
git clone https://github.com/Jumia/DevOps-Challenge.git
#restore the dump file for the application
sudo -u postgres psql;
psql CREATE DATABASE jumia_phone_validator;
psql CREATE USER jumia WITH ENCRYPTED PASSWORD "$DATABASE_PASS";
psql GRANT ALL PRIVILEGES ON DATABASE jumia_phone_validator TO jumia;
psql COPY sample.sql FROM '/tmp/jumia_phone_validator/database/sample.sql' TO jumia_phone_validator;

# Restart postgresqldb-server
sudo systemctl restart postgresql-14.service

#starting the firewall and allowing the postgresqldb to access from port no. 1337
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=1337/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart postgresql-14.service


#Terraform tmp provisioner for postgresql machine
provisioner "file" {
    source      = "postgresql.sh"
    destination = "/tmp/postgresql.sh"

    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = aws_db_instance.postgresql.address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/postgresql.sh",
      "/temp/postgresql.sh args",
    ]
  }
