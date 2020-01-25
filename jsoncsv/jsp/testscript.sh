curl -X POST -H "Content-Type: text" -d @simple.json "http://localhost:8080/jsoncsv/?source=fromJson&log=INFO"
curl -X POST -H "COntent-Type: text" -d @simple.csv "http://localhost:8080/jsoncsv/?source=fromCSV&log=INFO"
