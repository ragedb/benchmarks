# RageDB Benchmarks

## Results:

Results as of September 6, 2022 on LDBC SNB SF01:

| Query |   Total |      OK | KO  |   q/s | min | 99th |  max | mean |
|-------|--------:|--------:|-----|------:|----:|-----:|-----:|-----:|
| IQ01  |   33805 |   33805 | 0   |   554 |  11 |  144 |  175 |  114 |
| IQ02  |     874 |     868 | 6   |    13 | 249 | 5381 | 5499 | 4582 |
| IQ13  |  326378 |  326378 | 0   |  5350 |   1 |   16 |   53 |   12 |
| IS01  | 2176262 | 2176262 | 0   | 35676 |   0 |    3 |   47 |    2 |
| IS02  |  119327 |  119312 | 15  |  1956 |  16 |   48 |   88 |   32 |
| IS03  |  115656 |  115656 | 0   |  1896 |   5 |   81 |  158 |   33 |
| IS04  | 3336573 | 3336573 | 0   | 54697 |   0 |    2 |   42 |    1 |
| IS05  | 3255946 | 3255946 | 0   | 51681 |   0 |    2 |   73 |    1 |
| IS06  | 2146561 | 2146561 | 0   | 35189 |   0 |    3 |   72 |    2 |
| IS07  | 1243283 | 1243282 | 1   | 20381 |   0 |    6 |   43 |    3 |

Benchmark Parameters:

    userCount: 64           // Concurrent requests
    duration:  60 seconds   // Test duration
    ragedb -c4              // This limits RageDB to 4 (out of the 8) cores

Physical Server:

    NZXT, Inc MS-7D07
    Intel® Core™ i7-10700K CPU @ 3.80GHz × 8
    64 GB RAM
    Ubuntu 22.04.1 LTS

### Pre-Requisites for LDBC SNB Tests

1. Create the schema
2. Import the data
3. Create the stored procedures

See https://github.com/ragedb/example-queries for details

### Pre-Requisites for generic queries

- Create a "Node" node type with a name String property.
- Create an "Address" node type with these properties: uuid, street_address, city, state, zip_code
- Create 10 relationship types TYPE_1, TYPE_2, ... TYPE_10 


    NodeTypeInsert("Node")
    NodePropertyTypeAdd("Node", "name", "string")
    
    NodeTypeInsert("Address")
    NodePropertyTypeAdd("Address", "uuid", "integer")
    NodePropertyTypeAdd("Address", "street_address", "string")
    NodePropertyTypeAdd("Address", "city", "string")
    NodePropertyTypeAdd("Address", "state", "string")
    NodePropertyTypeAdd("Address", "title", "zip_code")
    
    RelationshipTypeInsert("TYPE_1")
    RelationshipTypeInsert("TYPE_2")
    RelationshipTypeInsert("TYPE_3")
    RelationshipTypeInsert("TYPE_4")
    RelationshipTypeInsert("TYPE_5")
    RelationshipTypeInsert("TYPE_6")
    RelationshipTypeInsert("TYPE_7")
    RelationshipTypeInsert("TYPE_8")
    RelationshipTypeInsert("TYPE_9")
    RelationshipTypeInsert("TYPE_10")





Command Line Instructions
-------------------------

Assuming you have an ec2 instance in the same vpc and subnet as your RageDB Server
and your cluster has an additional security group that allows incoming TCP 7243 from
the security group your ec2 instance belongs to.

You can either edit src/test/scala/rage/TestParameters and change the default parameters:

    getProperty("RAGE_URL", "http://127.0.0.1:7243")

to your RageDB server endpoint, then run:

    mvn gatling:test

To run specific tests:

    mvn gatling:test -Dgatling.simulationClass=rage.CreateNodeUniformNoProperties

You can pass in test parameters for the simulation

    mvn gatling:test -DUSERS=8 -DDURATION=30 -RAGE_URL="http://127.0.0.1:7243" -DRAGE_DB=rage -Dgatling.simulationClass=rage.CreateNodeUniformNoProperties

    