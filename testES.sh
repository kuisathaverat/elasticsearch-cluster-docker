#create index
curl -XPUT '192.168.99.100:9200/customer?pretty&pretty'
curl -XGET '192.168.99.100:9200/_cat/indices?v&pretty'

#inser document
curl -XPUT '192.168.99.100:9200/customer/external/1?pretty&pretty' -d'
{
  "name": "John Doe"
}'

curl -XPUT '192.168.99.100:9200/customer/external/2?pretty&pretty' -d'
{
  "name": "Nicola Tesla"
}'

#retrieve document
curl -XGET '192.168.99.100:9200/customer/external/1?pretty&pretty'

curl -XGET '192.168.99.100:9200/customer/external/2?pretty&pretty'

#replace document
curl -XPUT '192.168.99.100:9200/customer/external/2?pretty&pretty' -d'
{
  "name": "Nicola Tesla",
  "occupation": "scientist"
}'

curl -XGET '192.168.99.100:9200/customer/external/2?pretty&pretty'

#update data
curl -XPOST '192.168.99.100:9200/customer/external/2/_update?pretty&pretty' -d'
{
  "doc": { "occupation": "inventor" }
}'

curl -XGET '192.168.99.100:9200/customer/external/1?pretty&pretty'

#delete document
curl -XDELETE '192.168.99.100:9200/customer/external/2?pretty&pretty'

#delete index
curl -XDELETE '192.168.99.100:9200/customer?pretty&pretty'
curl -XGET '192.168.99.100:9200/_cat/indices?v&pretty'

#load data from a file
curl -L -o accounts.json https://github.com/elastic/elasticsearch/blob/master/docs/src/test/resources/accounts.json?raw=true
curl -XPOST '192.168.99.100:9200/bank/account/_bulk?pretty&refresh' --data-binary "@accounts.json"
curl 'localhost:9200/_cat/indices?v'

#search API
#search *
curl -XGET '192.168.99.100:9200/bank/_search?q=*&sort=account_number:asc&pretty'
#search all sorted by account_number
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}'
#search Burns
curl -XGET '192.168.99.100:9200/bank/_search?q=Burns&sort=account_number:asc&pretty'
#list 10 documents from 10th document
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 10
}'
#search documents which address contains mill
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": { "match": { "address": "mill" } }
}'
#search documents which address equals mill or lane
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": { "match": { "address": "mill lane" } }
}'
#search documents which address contains "mill lane"
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": { "match_phrase": { "address": "mill lane" } }
}'
#search documents which address contains mill and lane
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}'
#search documents which address contains mill or lane
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": {
    "bool": {
      "should": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}'
#search documents which address does not contains mill and lane
curl -XGET '192.168.99.100:9200/bank/_search?pretty' -d'
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}'
#return all accounts with balances between 20000 and 30000
curl -XPOST '192.168.99.100:9200/bank/_search?pretty' -d '
{
  "query": {
    "filtered": {
      "query": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}'
#calculates the average account balance by state
curl -XPOST '192.168.99.100:9200/bank/_search?pretty' -d '
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state"
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}'

#Cluster Health
curl -XGET '192.168.99.100:9200/_cluster/health?pretty'
#node info
curl -XGET "192.168.99.100:9200/_cat/nodes?v&h=h,i,n,l,u,m,hc,hp,hm,rc,rp,rm,d,fm,qcm,rcm" 
curl -XGET 'http://localhost:92001/_nodes'
#indices info
curl -XGET "192.168.99.100:9200/_cat/indices?v" 
#shards info
curl -XGET "192.168.99.100:9200/_cat/shards?v"
#shards allocation information
curl -XGET "192.168.99.100:9200/_cat/allocation?v"
#nodes stats
curl -XGET "192.168.99.100:9200/_nodes/stats/os?pretty" 
curl -XGET "192.168.99.100:9200/_nodes/stats/os,process?pretty" 
curl -XGET "192.168.99.100:9200/_nodes/stats/process?pretty" 
#heap memory is used by fielddata
curl -XGET "192.168.99.100:9200/_cat/fielddata?v?pretty"


#make backup repository
#folder path should be into the path.repo ES setting
curl -XPUT 'http://192.168.99.100:9200/_snapshot/my_backup?pretty&pretty' -d '{ "type": "fs", "settings": { "compress": "true", "location": "/tmp"}}'
curl -XGET 'http://192.168.99.100:9200/_snapshot/my_backup?pretty&pretty'
#get all backup repositories
curl -XGET 'http://192.168.99.100:9200/_snapshot/_all?pretty&pretty'
#make snapshot
curl -XPUT 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true&pretty'
curl -XPUT 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_2?wait_for_completion=true&pretty'
#get snapshot_1
curl -XGET 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1?pretty'
#get all snapshot on my_backup
curl -XGET 'http://192.168.99.100:9200/_snapshot/my_backup/_all?pretty'
#delete snapshot_1 from my_backup
curl -XDELETE 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1?pretty'
#restore snapshot_1
INDICES=$(curl -XGET 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1?pretty' | grep indices | cut -d ":" -f 2 | sed -e 's/,//g' -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/  //g')
for i in $INDICES
do
    curl -XPOST "http://192.168.99.100:9200/$i/_close?pretty"
done
curl -XPOST 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1/_restore?pretty' -d '{"partial":"true"}'
INDICES=$(curl -XGET 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1?pretty' | grep indices | cut -d ":" -f 2 | sed -e 's/,//g' -e 's/"//g' -e 's/\[//g' -e 's/\]//g' -e 's/  //g')
for i in $INDICES
do
    curl -XPOST "http://192.168.99.100:9200/$i/_open?pretty"
done
#get the status of restore
curl -XGET "http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1?pretty"
curl -XGET 'http://192.168.99.100:9200/_snapshot/my_backup/snapshot_1/_status?pretty'

#get pending task
curl -XGET 'http://192.168.99.100:9200/_cluster/pending_tasks"
