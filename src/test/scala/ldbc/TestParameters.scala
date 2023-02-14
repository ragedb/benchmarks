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

package ldbc

class TestParameters {
  def getProperty(propertyName: String, defaultValue: String): String = {
    Option(System.getenv(propertyName))
      .orElse(Option(System.getProperty(propertyName)))
      .getOrElse(defaultValue)
  }

  def rageURL: String = getProperty("RAGE_URL", "http://localhost:7243")
  def rageDB: String = getProperty("RAGE_DB", "rage")
  def userCount: Int = getProperty("USERS", "4").toInt
  def testDuration: Int = getProperty("DURATION", "60").toInt
  def fromId: Int = getProperty("FROM_ID", "0").toInt
  def toId: Int = getProperty("TO_ID", "3000000").toInt
}
