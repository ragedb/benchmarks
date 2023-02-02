-- Test Query Parameters for IQ13
local max_length = 4
local length = 0
local node1_id = NodeGetId("Person", "1129")
local left_people = {}
local seen_left = Roar.new()
local next_left = Roar.new()
next_left:add(node1_id)
while ((next_left:cardinality()) > 0 and length < max_length) do
    left_people = NodeIdsGetNeighborIds(next_left:getIds(), "KNOWS")
    next_left:clear()
    next_left:addIds(left_people)
    next_left:inplace_difference(seen_left)
    seen_left:inplace_union(next_left)
    length = length + 1
end
length, NodesGetProperty(next_left:getIds(), "id")




ldbc_snb_iq02 = function(person_id, maxDate)
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetLinks(node_id, "KNOWS")
    local friend_properties = LinksGetNodeProperties(friends)
    local messages = LinksGetNeighborIds(friends, Direction.IN, "HAS_CREATOR")

    local results = {}
    local friend_properties_map = {}
    for id, properties in pairs(friend_properties) do
      friend_properties_map[id] = properties
    end

    for link, user_message_ids in pairs(messages) do
         local properties = friend_properties_map[link:getNodeId()]
         local messages_props = FilterNodes(user_message_ids, "Message", "creationDate", Operation.LT, maxDate, 0, 10000000)
         one = message_props
         for j, msg_node in pairs(messages_props) do
               local result = {
                  ["friend.id"] = properties["id"],
                  ["friend.firstName"] = properties["firstName"],
                  ["friend.lastName"] = properties["lastName"]
              }
              local msg_properties = msg_node:getProperties()
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