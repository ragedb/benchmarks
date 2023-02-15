# RageDB Benchmarks for LDBC SNB

This repository contains queries, test data and Gatling tests for the [LDBC](https://ldbcouncil.org/) [Social Network Benchmark](https://ldbcouncil.org/benchmarks/snb/).
Watch ths [video](https://www.youtube.com/watch?v=q26DHnQFw54) for more information about the LDBC and their benchmarks.

Currently only queries used in the "Interactive Workload" have been written. 
You can read a paper on and get [the latest reference](https://ldbcouncil.org/ldbc_snb_docs/ldbc-snb-specification.pdf)

The data model and queries presented here are based on version [2.2.2-SNAPSHOT, commit b2ee1ca](https://github.com/ldbc/ldbc_snb_docs).

*IMPORTANT NOTE*: This is **NOT** an official LDBC Benchmark result.

## Implementation Notes:

The LDBC SNB data model is a logical data model and implementers are able to make tweaks to their physical data models.
We will follow along with TuGraph and make the following changes:

- Some relationships are further refined according to the connecting Node types:
    - `HAS_TAG`: `FORUM_HAS_TAG`, `POST_HAS_TAG`, `COMMENT_HAS_TAG`
    - `HAS_CREATOR`: `POST_HAS_CREATOR`, `COMMENT_HAS_CREATOR`
    - `IS_LOCATED_IN`: `PERSON_IS_LOCATED_IN`, `ORGANISATION_IS_LOCATED_IN`, `POST_IS_LOCATED_IN`, `COMMENT_IS_LOCATED_IN`
- There are two precomputed edge properties (similar to materialized views):
    - `HAS_MEMBER.numPosts` which maintains the number of posts the given person posted in the given forum and used in Complex Read 5
    - `KNOWS.weight` which maintains the weight between the pair of given persons, calculated using the formula in Complex Read 14

## Running the Benchmark:

- Get the data (more instructions TBD)
- Install RageDB (more instructions TBD)
- Run the schema.lua file
- Run the import-sf01.lua file
- Run the pre-process-sf01.lua file
- Run the interactive-short-sf01.lua file to create the "stored" procedures for the short queries
- Run the interactive-sf01.lua file to create the "stored" procedures for the complex queries
- Run Gatling and select the test you wish to run


## Results:

Results as of February 2, 2023, on LDBC SNB SF01:

4 Concurrent Threads:

| Query |   Total |      OK | KO  |   q/s | min | 99th |  max | mean |
|-------|--------:|--------:|-----|------:|----:|-----:|-----:|-----:|
| IQ01  |    6946 |    6946 | 0   |   114 |   0 |   95 |  154 |   34 |
| IQ02  |   23666 |   23666 | 0   |   388 |   0 |   14 |   31 |   10 |
| IQ03  |   49588 |   49588 | 0   |   812 |   2 |    7 |   26 |    5 |
| IQ04  |   11247 |   11247 | 0   |   184 |   0 |   54 |   91 |   21 |
| IQ05  |      88 |      88 | 0   |   1.4 | 421 | 5731 | 6370 | 2780 |
| IQ06  |   22294 |   22294 | 0   |   365 |   0 |   21 |   71 |   11 |
| IQ07  |   15600 |   15600 | 0   |   256 |   1 |   36 |   51 |   15 |
| IQ08  |  194115 |  194115 | 0   |  3182 |   0 |    3 |   49 |    1 |
| IQ09  |     190 |     190 | 0   |   3.1 | 421 | 2232 | 2271 | 1279 |
| IQ11  |   59676 |   59676 | 0   |   978 |   1 |    7 |   23 |    4 |
| IQ12  |   27417 |   27417 | 0   |   449 |   2 |   17 |   53 |    9 |
| IQ13  | 2391009 | 2391009 | 0   | 39197 |   0 |    1 |   19 |    0 |
| IS01  | 1988391 | 1988391 | 0   | 32597 |   0 |    1 |   46 |    0 |
| IS02  |  123875 |  123875 | 0   |  2030 |   0 |    6 |   21 |    2 |
| IS03  |  142017 |  142017 | 0   |  2328 |   0 |    9 |   24 |    2 |
| IS04  | 2956709 | 2956709 | 0   | 48471 |   0 |    1 |   18 |    0 |
| IS05  | 2745297 | 2745297 | 0   | 45005 |   0 |    1 |   23 |    0 |
| IS06  | 2022301 | 2022301 | 0   | 33152 |   0 |    1 |   23 |    0 |
| IS07  | 1330813 | 1330813 | 0   | 21816 |   0 |    1 |   25 |    0 |


8 Concurrent Threads:

| Query |   Total |      OK | KO  |   q/s | min |  99th |   max | mean |
|-------|--------:|--------:|-----|------:|----:|------:|------:|-----:|
| IQ01  |    6709 |    6709 | 0   |   110 |   4 |   156 |   208 |   71 |
| IQ02  |   23434 |   23434 | 0   |   384 |   3 |    27 |    51 |   20 |
| IQ03  |   50098 |   50098 | 0   |   821 |   3 |    15 |    33 |   10 |
| IQ04  |   11232 |   11232 | 0   |   184 |   0 |    89 |   117 |   43 |
| IQ05  |      91 |      91 | 0   |   1.4 | 831 | 10104 | 10269 | 5494 |
| IQ06  |   22091 |   22091 | 0   |   362 |   4 |    35 |   124 |   22 |
| IQ07  |   17810 |   17810 | 0   |   292 |   1 |    57 |    82 |   27 |
| IQ08  |  191486 |  191486 | 0   |  3139 |   0 |     6 |    29 |    2 |
| IQ09  |     185 |     185 | 0   |   2.9 | 799 |  3838 |  3937 | 2650 |
| IQ11  |   59577 |   59577 | 0   |   977 |   2 |    13 |    47 |    8 |
| IQ12  |   27321 |   27321 | 0   |   448 |   6 |    29 |    57 |   17 |
| IQ13  | 2876903 | 2876903 | 0   | 47162 |   0 |     1 |    22 |    0 |
| IS01  | 2111351 | 2111351 | 0   | 34612 |   0 |     1 |    27 |    0 |
| IS02  |  116536 |  116536 | 0   |  1910 |   0 |    12 |    26 |    4 |
| IS03  |  129718 |  129718 | 0   |  2126 |   0 |    15 |    35 |    4 |
| IS04  | 3275303 | 3275303 | 0   | 53693 |   0 |     1 |    16 |    0 |
| IS05  | 3010022 | 3010022 | 0   | 49344 |   0 |     1 |    36 |    0 |
| IS06  | 2068098 | 2068098 | 0   | 33903 |   0 |     1 |    22 |    0 |
| IS07  | 1343896 | 1343896 | 0   | 22031 |   0 |     2 |    24 |    0 |

64 Concurrent Threads: 

| Query |   Total |      OK | KO  |   q/s |  min |  99th |   max |  mean |
|-------|--------:|--------:|-----|------:|-----:|------:|------:|------:|
| IQ01  |    6957 |    6957 | 0   |   114 |   35 |   782 |   952 |   554 |
| IQ02  |   23671 |   23671 | 0   |   388 |   19 |   177 |   210 |   162 |
| IQ03  |   51318 |   51318 | 0   |   841 |   15 |    85 |   113 |    75 |
| IQ04  |   11376 |   11376 | 0   |   186 |   18 |   443 |   509 |   338 |
| IQ05  |     151 |     151 | 0   |   1.4 | 1674 | 54785 | 56583 | 35155 |
| IQ06  |   22324 |   22324 | 0   |   366 |   16 |   221 |   409 |   172 |
| IQ07  |   17734 |   17734 | 0   |   291 |   20 |   319 |   399 |   217 |
| IQ08  |  191254 |  191254 | 0   |  3135 |    0 |    32 |    70 |    20 |
| IQ09  |     245 |     245 | 0   |   3.0 |  854 | 23487 | 24033 | 18530 |
| IQ11  |   61314 |   61314 | 0   |  1005 |   10 |    76 |   100 |    63 |
| IQ12  |   27668 |   27668 | 0   |   454 |   18 |   169 |   206 |   139 |
| IQ13  | 2863559 | 2863559 | 0   | 43944 |    0 |     4 |    44 |     1 |
| IS01  | 2302277 | 2302277 | 0   | 37742 |    0 |     3 |    51 |     2 |
| IS02  |  122953 |  122953 | 0   |  2015 |    8 |    47 |    87 |    31 |
| IS03  |  142882 |  142882 | 0   |  2342 |    9 |    50 |   155 |    27 |
| IS04  | 3728883 | 3728883 | 0   | 61129 |    0 |     2 |    54 |     1 |
| IS05  | 3286854 | 3286854 | 0   | 53882 |    0 |     3 |    47 |     1 |
| IS06  | 2189160 | 2189160 | 0   | 35887 |    0 |     3 |    52 |     2 |
| IS07  | 1422425 | 1422425 | 0   | 23318 |    0 |     5 |    62 |     3 |

Benchmark Parameters:

    userCount: 4,8, 64      // Concurrent requests
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

See the top level ldbc folder for details.

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
