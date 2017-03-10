
image: lafenicecomua/php71-mysql-elasticsearch-pipelines:v1
pipelines:
  default:
    - step:
        script:
          - service mysql start
          - /usr/share/elasticsearch/bin/elasticsearch -Des.insecure.allow.root=true -d --default.path.conf=/etc/elasticsearch

