package ldbc

import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import io.gatling.http.Predef._
import io.gatling.http.protocol.HttpProtocolBuilder
import io.gatling.http.request.builder.HttpRequestBuilder

class InteractiveShort01  extends Simulation {
  val params = new TestParameters

  before {
    println(s"Rage URL: ${params.rageURL} Rage DB: ${params.rageDB}")
    println(s"Running test with ${params.userCount} users")
    println(s"Total test duration ${params.testDuration} seconds")
  }

  val csvFeeder: Iterator[Map[String, Any]] = csv("snb-is01-persons.csv").random()

  val httpProtocol: HttpProtocolBuilder =
    http
      .baseUrl(params.rageURL)
      .acceptHeader("application/json")
      .maxConnectionsPerHost(1)

  def request: HttpRequestBuilder = {
    http("LDBC SNB IS 01")
      .post("/db/" + params.rageDB + "/lua")
      .body(StringBody("""ldbc_snb_is01("#{person_id}")""".stripMargin))
      //.asJson
      .check(status.is(200))
  }

  val scn: ScenarioBuilder = scenario("rage.ldbc.snb.is01")
    .during(params.testDuration) {
      feed(csvFeeder)
        .exec(request)
    }

  setUp(scn.inject(atOnceUsers(params.userCount))).protocols(httpProtocol).disablePauses
}
