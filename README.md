# RageDB Benchmarks

## Results:

Results as of October 16, 2022, on LDBC SNB SF01:

4 Concurrent Threads:

| Query |   Total |      OK | KO  |   q/s | min | 99th | max | mean |
|-------|--------:|--------:|-----|------:|----:|-----:|----:|-----:|
| IQ01  |   32305 |   32305 | 0   |   529 |   0 |   16 |  26 |    7 |
| IQ02  |    1570 |    1570 | 0   |    25 |   6 |  217 | 253 |  153 |
| IQ13  | 2428469 | 2428469 | 0   | 39810 |   0 |    1 |  23 |    0 |
| IS01  | 1904541 | 1904541 | 0   | 31221 |   0 |    1 |  92 |    0 |
| IS02  |  120150 |  120150 | 0   |  1969 |   0 |    7 |  20 |    2 |
| IS03  |  129330 |  129330 | 0   |  2120 |   0 |   10 |  24 |    2 |
| IS04  | 2823326 | 2823326 | 0   | 46284 |   0 |    1 |  24 |    0 |
| IS05  | 2593434 | 2593434 | 0   | 42515 |   0 |    1 |  33 |    0 |
| IS06  | 1897311 | 1897311 | 0   | 31103 |   0 |    1 |  21 |    0 |
| IS07  | 1259833 | 1259833 | 0   | 20653 |   0 |    1 |  21 |    0 |


8 Concurrent Threads:

| Query |   Total |      OK | KO  |   q/s | min | 99th | max | mean |
|-------|--------:|--------:|-----|------:|----:|-----:|----:|-----:|
| IQ01  |   31724 |   31724 | 0   |   520 |   0 |   27 |  43 |   15 |
| IQ02  |    1547 |    1547 | 0   |    25 |  48 |  414 | 439 |  311 |
| IQ13  | 2852937 | 2852937 | 0   | 46769 |   0 |    1 |  24 |    0 |
| IS01  | 2111351 | 2111351 | 0   | 34612 |   0 |    1 |  27 |    0 |
| IS02  |  116536 |  116536 | 0   |  1910 |   0 |   12 |  26 |    4 |
| IS03  |  129718 |  129718 | 0   |  2126 |   0 |   15 |  35 |    4 |
| IS04  | 3275303 | 3275303 | 0   | 53693 |   0 |    1 |  16 |    0 |
| IS05  | 3010022 | 3010022 | 0   | 49344 |   0 |    1 |  36 |    0 |
| IS06  | 2068098 | 2068098 | 0   | 33903 |   0 |    1 |  22 |    0 |
| IS07  | 1343896 | 1343896 | 0   | 22031 |   0 |    2 |  24 |    0 |

64 Concurrent Threads: 

| Query |   Total |      OK | KO  |   q/s | min | 99th |  max | mean |
|-------|--------:|--------:|-----|------:|----:|-----:|-----:|-----:|
| IQ01  |   33805 |   33805 | 0   |   554 |  11 |  144 |  175 |  114 |
| IQ02  |    1558 |    1558 | 0   |    24 |  16 | 2908 | 2954 | 2516 |
| IQ13  |  326378 |  326378 | 0   |  5350 |   1 |   16 |   53 |   12 |
| IS01  | 2233624 | 2233624 | 0   | 36616 |   0 |    3 |   83 |    2 |
| IS02  |  118420 |  118420 | 0   |  1994 |   7 |   47 |  123 |   32 |
| IS03  |  144700 |  144700 | 0   |  2387 |   7 |   48 |   78 |   26 |
| IS04  | 3728883 | 3728883 | 0   | 61129 |   0 |    2 |   54 |    1 |
| IS05  | 3286854 | 3286854 | 0   | 53882 |   0 |    3 |   47 |    1 |
| IS06  | 2189160 | 2189160 | 0   | 35887 |   0 |    3 |   52 |    2 |
| IS07  | 1422425 | 1422425 | 0   | 23318 |   0 |    5 |   62 |    3 |

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


export SF=1
export LDBC_SNB_DATAGEN_MAX_MEM=32G
export LDBC_SNB_DATAGEN_JAR=$(sbt -batch -error 'print assembly / assemblyOutputPath')    

rm -rf out-sf${SF}/{factors,graphs/parquet/raw}
tools/run.py \
--cores $(nproc) \
--memory ${LDBC_SNB_DATAGEN_MAX_MEM} \
-- \
--format parquet \
--scale-factor ${SF} \
--mode raw \
--output-dir out-sf${SF} \
--generate-factors

./tools/run.py -- --format csv --scale-factor 0.003 --mode bi --generate-factors --conf 
