/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package rage

import java.util.Random
import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import io.gatling.http.Predef._
import io.gatling.http.protocol.HttpProtocolBuilder
import io.gatling.http.request.builder.HttpRequestBuilder

import java.util.concurrent.atomic.AtomicInteger

class CreateNodeFakeProperties extends Simulation {

  val params = new TestParameters

  before {
    println(s"Rage URL: ${params.rageURL} Rage DB: ${params.rageDB}")
    println(s"Running test with ${params.userCount} users")
    println(s"Total test duration ${params.testDuration} seconds")
  }

  import com.github.javafaker.Faker
  import java.util.Locale

  val usFaker = new Faker(new Locale("en-US"), new Random(1234))
  val id = new AtomicInteger(0)
  val fakeFeeder: Iterator[Map[String, Any]] = Iterator.continually(
    Map(
      "uuid" -> id.getAndIncrement(),
      "number" -> usFaker.number().numberBetween(1,100000),
      "street_address" -> usFaker.address.streetAddress(true),
      "zip_code" -> usFaker.address.zipCode(),
      "state" -> usFaker.address.stateAbbr,
      "city" -> String.format("%s%s", usFaker.address.cityPrefix, usFaker.address.citySuffix)
    )
  )

  val httpProtocol: HttpProtocolBuilder =
    http
      .baseUrl(params.rageURL)
      .acceptHeader("application/json")
      .maxConnectionsPerHost(1)

  def createPostRequest: HttpRequestBuilder = {
    http("CreateNodeFakeProperties")
      .post("/db/" + params.rageDB + "/node/Address/${uuid}")
      .body(StringBody(   """{ "number": ${number}, "street_address": "${street_address}", "city": "${city}","state": "${state}","zip_code": "${zip_code}" }"""))
      .asJson
      .check(status.is(201))
  }

  val scn: ScenarioBuilder = scenario("rage.CreateNodeFakeProperties")
    .repeat(100000) {
      feed(fakeFeeder)
        .exec(createPostRequest)
    }

  setUp(scn.inject(atOnceUsers(10))).protocols(httpProtocol).disablePauses

}