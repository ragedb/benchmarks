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

Results as of February 23, 2023, on LDBC SNB SF01:

4 Concurrent Threads:

| Query |   Total |      OK | KO  |   q/s | min | 99th |  max | mean |
|-------|--------:|--------:|-----|------:|----:|-----:|-----:|-----:|
| IQ01  |    8228 |    8228 | 0   |   135 |   0 |   79 |  120 |   29 |
| IQ02  |   34772 |   34772 | 0   |   570 |   0 |    9 |   17 |    7 |
| IQ03  |   75386 |   75386 | 0   |  1236 |   1 |    4 |   20 |    3 |
| IQ04  |   84504 |   84504 | 0   |  1385 |   0 |    7 |   21 |    3 |
| IQ05  |      77 |      77 | 0   |  1.26 | 483 | 6338 | 6622 | 3144 |
| IQ06  |   55683 |   55683 | 0   |   913 |   1 |    7 |   20 |    4 |
| IQ07  |   22428 |   22428 | 0   |   368 |   1 |   25 |   41 |   11 |
| IQ08  |  210651 |  210651 | 0   |  3453 |   0 |    3 |   21 |    1 |
| IQ09  |     225 |     225 | 0   |   3.7 |   0 | 1909 | 2421 | 1077 |
| IQ11  |  147827 |  147827 | 0   |  2423 |   0 |    3 |   20 |    2 |
| IQ12  |   91886 |   91886 | 0   |  1506 |   0 |    5 |   17 |    3 |
| IQ13  |  234108 |  234108 | 0   |  3838 |   0 |    2 |   14 |    1 |
| IS01  | 1988391 | 1988391 | 0   | 32597 |   0 |    1 |   46 |    0 |
| IS02  |  123875 |  123875 | 0   |  2030 |   0 |    6 |   21 |    2 |
| IS03  |  142017 |  142017 | 0   |  2328 |   0 |    9 |   24 |    2 |
| IS04  | 2956709 | 2956709 | 0   | 48471 |   0 |    1 |   18 |    0 |
| IS05  | 2745297 | 2745297 | 0   | 45005 |   0 |    1 |   23 |    0 |
| IS06  | 2022301 | 2022301 | 0   | 33152 |   0 |    1 |   23 |    0 |
| IS07  | 1330813 | 1330813 | 0   | 21816 |   0 |    1 |   25 |    0 |


Benchmark Parameters:

    userCount: 4            // Concurrent requests
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

    mvn gatling:test -Dgatling.simulationClass=ldbc.Interactive01

You can pass in test parameters for the simulation

    mvn gatling:test -DUSERS=4 -DDURATION=30 -DRAGE_URL="http://127.0.0.1:7243" -DRAGE_DB=rage -Dgatling.simulationClass=ldbc.Interactive01


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
