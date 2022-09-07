package ldbc

import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import io.gatling.http.Predef._
import io.gatling.http.protocol.HttpProtocolBuilder
import io.gatling.http.request.builder.HttpRequestBuilder
import rage.TestParameters

class Interactive13 extends Simulation {
  val params = new TestParameters

  before {
    println(s"Rage URL: ${params.rageURL} Rage DB: ${params.rageDB}")
    println(s"Running test with ${params.userCount} users")
    println(s"Total test duration ${params.testDuration} seconds")
  }

  val csvFeeder: Iterator[Map[String, Any]] = csv("snb-iq13-params.csv").random()

  val httpProtocol: HttpProtocolBuilder =
    http
      .baseUrl(params.rageURL)
      .acceptHeader("application/json")
      .maxConnectionsPerHost(1)

  def request: HttpRequestBuilder = {
    http("LDBC SNB IQ 13")
      .post("/db/" + params.rageDB + "/lua")
      .body(StringBody("""ldbc_snb_iq13("#{person1Id}","#{person2Id}")""".stripMargin))
      //.asJson
      .check(status.is(200))
  }

  val scn: ScenarioBuilder = scenario("rage.ldbc.snb.iq13")
    .during(params.testDuration) {
      feed(csvFeeder)
        .exec(request)
    }

  setUp(scn.inject(atOnceUsers(params.userCount))).protocols(httpProtocol).disablePauses
}
