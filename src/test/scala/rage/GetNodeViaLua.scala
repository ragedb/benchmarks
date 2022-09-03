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

import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import io.gatling.http.Predef._
import io.gatling.http.protocol.HttpProtocolBuilder
import io.gatling.http.request.builder.HttpRequestBuilder

import java.util.UUID
import java.util.concurrent.atomic.AtomicLong

class GetNodeViaLua extends Simulation {

  val params = new TestParameters

  before {
    println(s"Rage URL: ${params.rageURL} Rage DB: ${params.rageDB}")
    println(s"Running test with ${params.userCount}")
    println(s"Total test duration ${params.testDuration} seconds")
  }

  def randomUuid: String = UUID.randomUUID().toString
  val randomFeeder: Iterator[Map[String, String]] = Iterator.continually(Map("uuid" -> randomUuid))

  val id = new AtomicLong(0)
  val incrementalFeeder: Iterator[Map[String, Long]] = Iterator.continually(Map("uuid" -> id.getAndIncrement()))

  val httpProtocol: HttpProtocolBuilder =
    http
      .baseUrl(params.rageURL)
      .acceptHeader("application/json")
      .maxConnectionsPerHost(1)

  def request: HttpRequestBuilder = {
    http("GetNodeViaLua")
      .post("/db/" + params.rageDB + "/lua")
      .body(StringBody("""NodeGet("Node","#{uuid}")""".stripMargin))
      //.asJson
      .check(status.is(200))
  }

  val scn: ScenarioBuilder = scenario("rage.GetNodeViaLua")
    .during(params.testDuration) {
      feed(incrementalFeeder)
        .exec(request)
    }

  setUp(scn.inject(atOnceUsers(params.userCount))).protocols(httpProtocol).disablePauses

}