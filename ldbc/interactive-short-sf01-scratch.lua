
-- Interactive Short 2 - NodeGetNeighbors
ldbc_snb_is02 = function(person_id)

    local person = NodeGet("Person", person_id)
    local messages = NodeGetNeighbors(person:getId(), Direction.IN, "HAS_CREATOR")
    table.sort(messages, function(a, b)
        if a:getProperty("creationDate") > b:getProperty("creationDate") then
            return true
        elseif a:getProperty("creationDate") == b:getProperty("creationDate") then
            return a:getProperty("id") > b:getProperty("id")
        end
        end)
    local smaller = table.move(messages, 1, 10, 1, {})

    results = {}
    for i, message in pairs(smaller) do
        local properties = message:getProperties()

        local result = {
            ["message.id"] = properties["id"],
            ["message.creationDate"] = date(properties["creationDate"]):fmt("${iso}Z")
        }

        if (properties["content"] == '') then
            result["message.imageFile"] = properties["imageFile"]
        else
            result["message.content"] = properties["content"]
        end

        if (properties["type"] == "post") then
            result["post.id"] = properties["id"]
            result["originalPoster.id"] = person:getProperty("id")
            result["originalPoster.firstName"] = person:getProperty("firstName")
            result["originalPoster.lastName"] = person:getProperty("lastName")
        else
            local node_id = message:getId()
            local hasReply = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
            while (#hasReply > 0) do
                node_id = hasReply[1]:getNodeId()
                hasReply = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
            end
            local poster = NodeGetNeighbors(node_id, Direction.OUT, "HAS_CREATOR")[1]
            local post_id = NodeGetProperty(node_id, "id")
            result["post.id"] = post_id
            result["originalPoster.id"] = poster:getProperty("id")
            result["originalPoster.firstName"] = poster:getProperty("firstName")
            result["originalPoster.lastName"] = poster:getProperty("lastName")
        end
        table.insert(results, result)
    end

    return results
end

-- Interactive Short 2 - NodesGetProperties
ldbc_snb_is02 = function(person_id)
    local person = NodeGet("Person", person_id)
    local person_properties = person:getProperties()
    local message_ids = NodeGetNeighborIds(person:getId(), Direction.IN, "HAS_CREATOR")
    local messages = NodesGetProperties(message_ids)
    for i, properties in pairs(messages) do
        properties["node_id"] = message_ids[i]
    end

        table.sort(messages, function(a, b)
        local adate = a["creationDate"]
        local bdate = b["creationDate"]
        if adate > bdate then
            return true
        elseif adate == bdate then
            return a["id"] > b["id"]
        end
        end)
    local smaller = table.move(messages, 1, 10, 1, {})

   results = {}
    for i, properties in pairs(smaller) do

        local result = {
            ["message.id"] = properties["id"],
            ["message.creationDate"] = date(properties["creationDate"]):fmt("${iso}Z")
        }

        if (properties["content"] == '') then
            result["message.imageFile"] = properties["imageFile"]
        else
            result["message.content"] = properties["content"]
        end

        if (properties["type"] == "post") then
            result["post.id"] = properties["id"]
            result["originalPoster.id"] = person_properties["id"]
            result["originalPoster.firstName"] = person_properties["firstName"]
            result["originalPoster.lastName"] = person_properties["lastName"]
        else
            -- removing the chase gives me an extra 100 req/s
            local node_id = properties["node_id"]
            local hasReply = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
            while (#hasReply > 0) do
                node_id = hasReply[1]:getNodeId()
                hasReply = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
            end
            local poster = NodeGetNeighbors(node_id, Direction.OUT, "HAS_CREATOR")[1]
            local poster_properties = poster:getProperties()
            local post_id = NodeGetProperty(node_id, "id")
            result["post.id"] = post_id
            result["originalPoster.id"] = poster_properties["id"]
            result["originalPoster.firstName"] = poster_properties["firstName"]
            result["originalPoster.lastName"] = poster_properties["lastName"]
        end
        table.insert(results, result)
    end

    return results
end


-- Interactive Short 3
local person_id = "933"
local knows = NodeGetLinks("Person", person_id, "KNOWS")
local knows_dates = LinksGetRelationshipProperty(knows, "creationDate")
local friends = LinksGetNode(knows)

local friendships = {}
    for i, friend in pairs(friends) do
      local creation = 0
      for link, knows_date in pairs(knows_dates) do
          if (link:getNodeId() == friend:getId()) then
              creation = knows_date
              break
          end
     end

      friendship = {
        ["friend.id"] = friend:getProperty("id"),
        ["friend.firstName"] = friend:getProperty("firstName"),
        ["friend.lastName"] = friend:getProperty("lastName"),
        ["knows.creationDate"] = creation
      }
      table.insert(friendships, friendship)
    end

    table.sort(friendships, function(a, b)
      local adate = a["knows.creationDate"]
      local bdate = b["knows.creationDate"]
      if adate > bdate then
          return true
      end
      if (adate == bdate) then
         return (a["friend.id"] < b["friend.id"] )
      end
    end)

    for i = 1, #friendships do
      friendships[i]["knows.creationDate"] = date(friendships[i]["knows.creationDate"]):fmt("${iso}Z")
    end
friendships


LinksGetNeighbors




ldbc_snb_iq02_v2 = function(person_id, maxDate)

    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetLinks(node_id, "KNOWS")
    local friend_properties = LinksGetNodeProperties(friends)
    local messages = LinksGetNeighbors(friends, Direction.IN, "HAS_CREATOR")
    local results = {}
    local friend_properties_map = {}
    for link, properties in pairs(friend_properties) do
      friend_properties_map[tostring(link:getNodeId())] = properties
    end

    for link, user_messages in pairs(messages) do
         local properties = friend_properties_map[tostring(link:getNodeId())]
         for j, message in pairs(user_messages) do
           local msg_properties = message:getProperties()
           if (date(msg_properties["creationDate"]) < maxDate) then
              local result = {
                  ["friend.id"] = properties["id"],
                  ["friend.firstName"] = properties["firstName"],
                  ["friend.lastName"] = properties["lastName"]
              }
              result["message.id"] = msg_properties["id"]
              if (msg_properties["content"] == '') then
                  result["message.imageFile"] = msg_properties["imageFile"]
              else
                  result["message.content"] = msg_properties["content"]
              end
              result["message.creationDate"] = msg_properties["creationDate"]
              table.insert(results, result)
          end
        end
    end

      table.sort(results, function(a, b)
          local adate = a["message.creationDate"]
          local bdate = b["message.creationDate"]
          if adate > bdate then
              return true
          end
          if (adate == bdate) then
              return (a["message.id"] < b["message.id"] )
          end
      end)

        local smaller = table.move(results, 1, 20, 1, {})

          for i = 1, #smaller do
              smaller[i]["message.creationDate"] = DateToISO(smaller[i]["message.creationDate"])
          end

    return smaller
end




local maxDate = date("2012-09-12T18:55:55.595+0000Z")
local person_id = "1129"
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetLinks(node_id, "KNOWS")
    local friends2 = NodeGetNeighbors(node_id, "KNOWS")


    local friend_properties = LinksGetNodeProperties(friends)
    local messages = LinksGetNeighbors(friends, Direction.IN, "HAS_CREATOR")
    local results = {}
    local results2 = {}
    local friend_properties_map = {}
    for link, properties in pairs(friend_properties) do
      friend_properties_map[tostring(link:getNodeId())] = properties
    end

      for i, friend in pairs(friends2) do
          local properties = friend:getProperties()
          local messages = NodeGetNeighbors(friend:getId(), Direction.IN, "HAS_CREATOR")
       table.insert(results, #messages)
    end
    --[984, 2358, 1082, 162, 154, 146, 1588, 2042, 780, 2816, 113, 9936, 1272, 891]
    for link, user_messages in pairs(messages) do
         local properties = friend_properties_map[tostring(link:getNodeId())]
         local a = 0
         for j, message in pairs(user_messages) do
          a = a +1
         end
       table.insert(results2, a)
    end

results,results2
[[984, 2358, 1082, 162, 154, 146, 1588, 2042, 780, 2816, 113, 9936, 1272, 891],
 [250, 218, 37, 40, 2486, 307, 26, 224, 532, 711, 35, 405, 287, 526]]





 local maxDate = date("2012-09-12T18:55:55.595+0000Z")
 local person_id = "1129"
     local node_id = NodeGetId("Person", person_id)
     local friends = NodeGetLinks(node_id, "KNOWS")
     local friends2 = NodeGetNeighbors(node_id, "KNOWS")


     local friend_properties = LinksGetNodeProperties(friends)
     local messages = LinksGetNeighbors(friends, Direction.IN, "HAS_CREATOR")
     local results = {}
     local results2 = {}
     local f = {}
     local f2 = {}
     local friend_properties_map = {}
     for link, properties in pairs(friend_properties) do
       friend_properties_map[tostring(link:getNodeId())] = properties
     end

       for i, friend in pairs(friends2) do
           local properties = friend:getProperties()
           local messages2 = NodeGetNeighbors(friend:getId(), Direction.IN, "HAS_CREATOR")
        table.insert(results, #messages2)
        table.insert(f, friend:getId())

     end
     --[984, 2358, 1082, 162, 154, 146, 1588, 2042, 780, 2816, 113, 9936, 1272, 891]
     for link, user_messages in pairs(messages) do
          local properties = friend_properties_map[tostring(link:getNodeId())]
          local a = 0
          for j, message in pairs(user_messages) do
           a = a +1
          end
        table.insert(results2, a)
        table.insert(f2, link:getNodeId())
     end

 results, f, results2, f2












--ALL
ldbc_snb_iq02 = function(person_id, maxDate)

    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetLinks(node_id, "KNOWS")
    local friend_properties = LinksGetNodeProperties(friends)
    local messages = LinksGetLinks(friends, Direction.IN, "HAS_CREATOR")
    --local messages = LinksGetNeighbors(friends, Direction.IN, "HAS_CREATOR")
    local results = {}
    local friend_properties_map = {}
    for link, properties in pairs(friend_properties) do
      friend_properties_map[tostring(link:getNodeId())] = properties
    end

    for link, user_messages in pairs(messages) do
         local properties = friend_properties_map[tostring(link:getNodeId())]
         local messages_props = LinksGetNodeProperties(user_messages)

         for j, msg_properties in pairs(messages_props) do
           if (date(msg_properties["creationDate"]) < maxDate) then
              local result = {
                  ["friend.id"] = properties["id"],
                  ["friend.firstName"] = properties["firstName"],
                  ["friend.lastName"] = properties["lastName"]
              }
              result["message.id"] = msg_properties["id"]
              if (msg_properties["content"] == '') then
                  result["message.imageFile"] = msg_properties["imageFile"]
              else
                  result["message.content"] = msg_properties["content"]
              end
              result["message.creationDate"] = msg_properties["creationDate"]
              table.insert(results, result)
          end
        end
    end

      table.sort(results, function(a, b)
          local adate = a["message.creationDate"]
          local bdate = b["message.creationDate"]
          if adate > bdate then
              return true
          end
          if (adate == bdate) then
              return (a["message.id"] < b["message.id"] )
          end
      end)

        local smaller = table.move(results, 1, 20, 1, {})

          for i = 1, #smaller do
              smaller[i]["message.creationDate"] = DateToISO(smaller[i]["message.creationDate"])
          end

    return smaller
end


---------------------------------------Wrong values:
local maxDate = date("2022-05-20T18:55:55.595+0000Z")
local person_id = "1129"
 local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetLinks(node_id, "KNOWS")
    local friend_properties = LinksGetNodeProperties(friends)
    local messages = LinksGetLinks(friends, Direction.IN, "HAS_CREATOR")

    local results = {}
    local friend_properties_map = {}
    for link, properties in pairs(friend_properties) do
      friend_properties_map[tostring(link:getNodeId())] = properties
    end

    for link, user_messages in pairs(messages) do
         local properties = friend_properties_map[tostring(link:getNodeId())]
         local messages_props = LinksGetNodeProperties(user_messages)

         for j, msg_properties in pairs(messages_props) do
           if (date(msg_properties["creationDate"]) < maxDate) then
              local result = {
                  ["friend.id"] = properties["id"],
                  ["friend.firstName"] = properties["firstName"],
                  ["friend.lastName"] = properties["lastName"]
              }
              result["message.id"] = msg_properties["id"]
              if (msg_properties["content"] == '') then
                  result["message.imageFile"] = msg_properties["imageFile"]
              else
                  result["message.content"] = msg_properties["content"]
              end
              result["message.creationDate"] = msg_properties["creationDate"]
              table.insert(results, result)
          end
        end
    end

      table.sort(results, function(a, b)
          local adate = a["message.creationDate"]
          local bdate = b["message.creationDate"]
          if adate > bdate then
              return true
          end
          if (adate == bdate) then
              return (a["message.id"] < b["message.id"] )
          end
      end)

        local smaller = table.move(results, 1, 20, 1, {})

          for i = 1, #smaller do
              smaller[i]["message.creationDate"] = DateToISO(smaller[i]["message.creationDate"])
          end

smaller














ldbc_snb_is03v2 = function(person_id)

    local knows = NodeGetLinks("Person", person_id, "KNOWS")

    local node_properties = LinksGetNodeProperties(knows)
    local rels_property = LinksGetRelationshipProperty(knows, "creationDate")

    local friendships = {}
    for i, know in pairs(knows) do
      local creation = rels_property[know:getRelationshipId()]
      local friend = node_properties[know:getNodeId()]
      local friendship = {
        ["friend.id"] = friend["id"],
        ["friend.firstName"] = friend["firstName"],
        ["friend.lastName"] = friend["lastName"],
        ["knows.creationDate"] = creation
      }
      table.insert(friendships, friendship)
    end

    table.sort(friendships, function(a, b)
      local adate = a["knows.creationDate"]
      local bdate = b["knows.creationDate"]
      if adate > bdate then
          return true
      end
      if (adate == bdate) then
         return (a["friend.id"] < b["friend.id"] )
      end
    end)

    for i = 1, #friendships do
      friendships[i]["knows.creationDate"] = DateToISO(friendships[i]["knows.creationDate"])
    end

    return friendships
end




    local person_id = "2199023256684"
    local person = NodeGet("Person", person_id)
    local person_properties = person:getProperties()
    local message_node_ids = NodeGetNeighborIds(person:getId(), Direction.IN, "HAS_CREATOR") -- 73106
    local messages = {}
    local messages_dates = NodesGetProperty2(message_node_ids, "creationDate") -- 58k 58699
    local messages_ids = NodesGetProperty2(message_node_ids, "id") -- 8234, 8269-- nosort 8493 vs 14636, 14599 nosort 14939

    for i, id in pairs(message_node_ids) do
    local properties = {
       ["creationDate"] = messages_dates[id],
       ["id"] = messages_ids[id],
       ["node_id"] = id
      }
      table.insert(messages, properties)
    end


for k,v in messages_ids2:pairs() do
    messages[k] = v
end
messages


    local person_id = "2199023256684"
    local person = NodeGet("Person", person_id)
    local person_properties = person:getProperties()
    local message_node_ids = NodeGetNeighborIds(person:getId(), Direction.IN, "HAS_CREATOR") -- 73106
    local messages = {}
    local messages_dates = NodesGetProperty2(message_node_ids, "creationDate") -- 58k 58699
    local messages_ids = NodesGetProperty2(message_node_ids, "id") -- 8234, 8269-- nosort 8493 vs 14636, 14599 nosort 14939

    for i, id in pairs(message_node_ids) do
    local properties = {
       ["creationDate"] = messages_dates[id],
       ["id"] = messages_ids[id],
       ["node_id"] = id
      }
      table.insert(messages, properties)
    end
   table.sort(messages, function(a, b)
        local adate = a["creationDate"]
        local bdate = b["creationDate"]
        if adate > bdate then
            return true
        elseif adate == bdate then
            return a["id"] > b["id"]
        end
        end)
    local smaller = table.move(messages, 1, 10, 1, {})

    results = {}
    for i, properties in pairs(smaller) do

        local result = {
            ["message.id"] = properties["id"],
            ["message.creationDate"] = DateToISO(properties["creationDate"])
        }

        if (properties["content"] == '') then
            result["message.imageFile"] = properties["imageFile"]
        else
            result["message.content"] = properties["content"]
        end

        if (properties["type"] == "post") then
            result["post.id"] = properties["id"]
            result["originalPoster.id"] = person_properties["id"]
            result["originalPoster.firstName"] = person_properties["firstName"]
            result["originalPoster.lastName"] = person_properties["lastName"]
        else
            local node_id = properties["node_id"]
            local hasReply = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
            while (#hasReply > 0) do
                node_id = hasReply[1]:getNodeId()
                hasReply = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
            end
            local poster = NodeGetNeighbors(node_id, Direction.OUT, "HAS_CREATOR")[1]
            local poster_properties = poster:getProperties()
            local post_id = NodeGetProperty(node_id, "id")
            result["post.id"] = post_id
            result["originalPoster.id"] = poster_properties["id"]
            result["originalPoster.firstName"] = poster_properties["firstName"]
            result["originalPoster.lastName"] = poster_properties["lastName"]
        end
        table.insert(results, result)
    end

    return results



        --local messages_dates = NodesGetProperty2(message_node_ids, "creationDate") -- 58k 58699
       -- local messages_ids = NodesGetProperty2(message_node_ids, "id") -- 8234, 8269-- nosort 8493 vs 14636, 14599 nosort 14939
        -- 9430, 9411 vs 16612 if I don't get messages_ids vs 58741


    for i, id in pairs(message_node_ids) do
    local properties = {
       ["creationDate"] = messages_dates[id],
       ["id"] = messages_ids[id],
       ["node_id"] = id
      }
      table.insert(messages, properties)
    end
   --6451 for regular
   --5054 for 2


   -- Interactive Short 2 - Two NodesGetProperty
   ldbc_snb_is02 = function(person_id)
       local person = NodeGet("Person", person_id)
       local person_properties = person:getProperties()
       local message_node_ids = NodeGetNeighborIds(person:getId(), Direction.IN, "HAS_CREATOR")
       local messages = {} -- 58k vs 24k just calling 2 empty NodesGetProperty. vs 34k just calling a single empty NodesGetProperty
       local messages_dates = NodesGetProperty(message_node_ids, "creationDate") -- 14k
       local messages_ids = NodesGetProperty(message_node_ids, "id") -- 8k


       return "done"
   end

Req/s
58k   - No calls
49k   - 1 call  No Seastar no presize
48.5k - 1 call  No Seastar empty RAW
47.8k - 1 call  No Seastar 20 zeros RAW
46k   - 1 call  No Seastar empty
45.7k - 1 call  No Seastar 20 zeros
37k   - 1 call  No Seastar fake data 0
34k   - 1 call             empty
33.6k - 1 call  10 zeros (40) RAW
31.9k - 1 call  10 zeros (40)
31k   - 1 call  No Seastar fake data 0 RAW
19.5k - 1 call  20 zeros RAW
18.5k - 1 call  20 zeros (80)
16.8k - 1 call             fake data 0
15.6k - 1 call             fake data string
14k   - 1 call  correct

41.5k - 2 calls No Seastar no presize
41k   - 2 calls No Seastar empty RAW
39.5k - 2 calls No Seastar 20 zeros RAW
37.5k - 2 calls No Seastar empty
36.9k - 2 calls No Seastar 20 zeros
26k   - 2 calls No Seastar fake data 0
24k   - 2 calls            empty
23.6k - 2 calls 10 zeros RAW
22.3k - 2 calls 10 zeros
20k   - 2 calls No Seastar fake data 0 RAW
12.3k - 2 calls 20 zeros RAW
11.5  - 2 calls 20 zeros
 9.7k - 2 calls            fake data 0
 8.9k - 2 calls            fake data string
 8k   - 2 calls correct
 2k   - 1 call NodesGetProperties

Raw EMTPY calls are faster than non raw empty calls

    local message_node_id = NodeGetId("Message", message_id)
    local author = NodeGetNeighbors(message_node_id, Direction.OUT, "HAS_CREATOR")[1]
    local knows_ids = NodeGetNeighborIds(author:getId(), "KNOWS")

    local comments = {}
    local replies = NodeGetNeighbors(message_node_id, Direction.IN, "REPLY_OF")
    for i, reply in pairs (replies) do
        local replyAuthor = NodeGetNeighbors(reply:getId(), Direction.OUT, "HAS_CREATOR")[1]
        local properties = replyAuthor:getProperties()
        local comment = {
            ["replyAuthor.id"] = properties["id"],
            ["replyAuthor.firstName"] = properties["firstName"],
            ["replyAuthor.lastName"] = properties["lastName"],
            ["knows"] = not knows_ids[replyAuthor:getId()] == nil,
            ["comment.id"] = reply:getProperty("id"),
            ["comment.content"] = reply:getProperty("content"),
            ["comment.creationDate"] = reply:getProperties()["creationDate"]
        }
    table.insert(comments, comment)
    end

    table.sort(comments, function(a, b)
      local adate = a["comment.creationDate"]
      local bdate = b["comment.creationDate"]
      if adate > bdate then
          return true
      end
      if (adate == bdate) then
         return (a["replyAuthor.id"] < b["replyAuthor.id"] )
      end
    end)

    for i = 1, #comments do
        comments[i]["comment.creationDate"] = DateToISO(comments[i]["comment.creationDate"])
    end

comments













    local message_id = "1236950581248"
    local message_node_id = NodeGetId("Message", message_id)
    local author = NodeGetNeighbors(message_node_id, Direction.OUT, "HAS_CREATOR")[1]
    local knows_ids = NodeGetNeighborIds(author:getId(), "KNOWS")

    local comments = {}
    local replies = NodeGetNeighbors(message_node_id, Direction.IN, "REPLY_OF")
    for i, reply in pairs (replies) do
        local replyAuthor = NodeGetNeighbors(reply:getId(), Direction.OUT, "HAS_CREATOR")[1]
        local properties = replyAuthor:getProperties()
        local comment = {
            ["replyAuthor.id"] = properties["id"],
            ["replyAuthor.firstName"] = properties["firstName"],
            ["replyAuthor.lastName"] = properties["lastName"],
            ["knows"] = not knows_ids[replyAuthor:getId()] == nil,
            ["comment.id"] = reply:getProperty("id"),
            ["comment.content"] = reply:getProperty("content"),
            ["comment.creationDate"] = reply:getProperties()["creationDate"]
        }
    table.insert(comments, comment)
    end

    table.sort(comments, function(a, b)
      local adate = a["comment.creationDate"]
      local bdate = b["comment.creationDate"]
      if adate > bdate then
          return true
      end
      if (adate == bdate) then
         return (a["replyAuthor.id"] < b["replyAuthor.id"] )
      end
    end)

    for i = 1, #comments do
        comments[i]["comment.creationDate"] = DateToISO(comments[i]["comment.creationDate"])
    end
comments