--ALL
-- Interactive Short 1
ldbc_snb_is01 = function(person_id)

    local properties = NodeGetProperties("Person", person_id)
    local city = NodeGetNeighbors("Person", person_id, Direction.OUT, "PERSON_IS_LOCATED_IN")[1]
    local result = {
        ["person.firstName"] = properties["firstName"],
        ["person.lastName"] = properties["lastName"],
        ["person.birthday"] = properties["birthday"],
        ["person.locationIP"] = properties["locationIP"],
        ["person.browserUsed"] = properties["browserUsed"],
        ["city.id"] = city:getProperty("id"),
        ["person.gender"] = properties["gender"],
        ["person.creationDate"] = DateToISO(properties["creationDate"])
    }

    return result
end

-- Interactive Short 2 - Two NodeIdsGetProperty
ldbc_snb_is02 = function(person_id)
    local person = NodeGet("Person", person_id)
    local person_properties = person:getProperties()
    local message_node_ids = NodeGetNeighborIds(person:getId(), Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
    local messages = {}
    local messages_dates = NodeIdsGetProperty(message_node_ids, "creationDate")
    local messages_ids = NodeIdsGetProperty(message_node_ids, "id")

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
            local poster = NodeGetNeighbors(node_id, Direction.OUT, "POST_HAS_CREATOR")[1]
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
ldbc_snb_is03 = function(person_id)

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

-- Interactive Short 4
ldbc_snb_is04 = function(message_id)

    local properties = NodeGetProperties("Message", message_id)
    local result = {
        ["message.creationDate"] = DateToISO(properties["creationDate"])
    }

    if (properties["content"] == '') then
        result["message.imageFile"] =  properties["imageFile"]
    else
        result["message.content"] = properties["content"]
    end

    return result
end

ldbc_snb_is04("3")

-- Interactive Short 5
ldbc_snb_is05 = function(message_id)

    local person = NodeGetNeighbors("Message", message_id, Direction.OUT, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})[1]
    local result = {
        ["person.id"] = person:getProperty("id"),
        ["person.firstName"] = person:getProperty("firstName"),
        ["person.lastName"] = person:getProperty("lastName")
    }

    return result
end

-- Interactive Short 6
ldbc_snb_is06 = function(message_id)

    local node_id = NodeGetId("Message", message_id)
    local links = NodeGetLinks(node_id, Direction.IN, "CONTAINER_OF")
    while (#links == 0) do
        links = NodeGetLinks(node_id, Direction.OUT, "REPLY_OF")
        node_id = links[1]:getNodeId()
        links = NodeGetLinks(node_id , Direction.IN, "CONTAINER_OF")
    end
    node_id = links[1]:getNodeId()
    local forum = NodeGet(node_id)
    local moderator = NodeGetNeighbors(node_id, Direction.OUT, "HAS_MODERATOR")[1]
    local properties = moderator:getProperties()
    local result = {
        ["forum.id"] = forum:getProperty("id"),
        ["forum.title"] = forum:getProperty("title"),
        ["moderator.id"] = properties["id"],
        ["moderator.firstName"] = properties["firstName"],
        ["moderator.lastName"] = properties["lastName"]
        }

    return result
end


-- Interactive Short 7
ldbc_snb_is07 = function(message_id)

    local message_node_id = NodeGetId("Message", message_id)
    local author = NodeGetNeighbors(message_node_id, Direction.OUT, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})[1]
    local knows_ids = NodeGetNeighborIds(author:getId(), "KNOWS")

    local comments = {}
    local replies = NodeGetNeighbors(message_node_id, Direction.IN, "REPLY_OF")
    for i, reply in pairs (replies) do
        local replyAuthor = NodeGetNeighbors(reply:getId(), Direction.OUT, "COMMENT_HAS_CREATOR")[1]
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

    return comments
end