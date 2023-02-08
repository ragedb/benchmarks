 local person_id = "13194139542834"
 local max_date = 1324080000000
 local maxDate_double = maxDate / 1000.0

    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")
    -- Store the unique friends and friends of friends in a map
    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    otherPerson:addValues(friend_of_friends)
    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    local otherPerson_messages = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.IN, "HAS_CREATOR")
    local messages = Roar.new()
    messages:addValues(otherPerson_messages)
    local latest = FilterNodes(comment_ids:getIds(), "Message", "creationDate", Operation.LT, maxDate_double, 0, 20, Sort.DESC)

    local results = {}
    for i = 1, #latest do
        local msg_properties = latest[i]:getProperties()
        local author = NodeGetNeighbors(latest[i], Direction.OUT, "HAS_CREATOR")[1]
        local author_props = author:getProperties()
        local result = {
           ["otherPerson.id"] = author_props["id"],
           ["otherPerson.firstName"] = author_props["firstName"],
           ["otherPerson.lastName"] = author_props["lastName"],
           ["message.creationDate"] = DateToISO(msg_properties["creationDate"]),
           ["message.id"] = msg_properties["id"],
        }
        if (msg_properties["content"] == '') then
           result["message.imageFile"] = msg_properties["imageFile"]
        else
           result["message.content"] = msg_properties["content"]
        end

       table.insert(results, result)
    end

      table.sort(results, function(a, b)
          local adate = a["message.creationDate"]
          local bdate = b["message.creationDate"]
          if adate > bdate then
              return true
          end
          if (adate == bdate) then
              return (a["message.id"] < b["comment.id"] )
          end
      end)

results





    local created = NodeGetNeighborIds(node_id, Direction.IN, "HAS_CREATOR")
    local messages = Roar.new()
    messages:addIds(created)
    local message_replies = NodeIdsGetNeighborIds(messages:getIds(), Direction.IN, "REPLY_OF")
    local comment_ids = Roar.new()
    comment_ids:addValues(message_replies)
    local latest = FilterNodes(comment_ids:getIds(), "Message", "creationDate", Operation.GT, 0.0, 0, 20, Sort.DESC)

    local results = {}
    for i = 1, #latest do
        local msg_properties = latest[i]:getProperties()
        local author = NodeGetNeighbors(latest[i], Direction.OUT, "HAS_CREATOR")[1]
        local author_props = author:getProperties()
        local result = {
           ["commentAuthor.id"] = author_props["id"],
           ["commentAuthor.firstName"] = author_props["firstName"],
           ["commentAuthor.lastName"] = author_props["lastName"],
           ["comment.creationDate"] = DateToISO(msg_properties["creationDate"]),
           ["comment.id"] = msg_properties["id"],
           ["comment.content"] = msg_properties["content"]

        }
       table.insert(results, result)
    end

      table.sort(results, function(a, b)
          local adate = a["comment.creationDate"]
          local bdate = b["comment.creationDate"]
          if adate > bdate then
              return true
          end
          if (adate == bdate) then
              return (a["comment.id"] < b["comment.id"] )
          end
      end)

results


    local liked_at = LinksGetRelationshipProperty(likes, "creationDate")
    for rel_id, creation in pairs(liked_at) do

    end

    local rels = Roar.new()
    for message_link, likes_link in pairs(likes)
        rels:add(likes_link:getRelationshipId())
    end














local firstName = "Chau"

    local node_id = NodeGetId("Person", person_id)
    local people = NodeGetNeighborIds(node_id, "KNOWS")
    local seen1 = Roar.new()

    seen1:addIds(people)
    local named1 = FilterNodes(seen1:getIds(), "Person", "firstName", Operation.EQ, firstName)
    local named2 = {}
    local named3 = {}

    if(#named1 < 20) then
      local seen2 = Roar.new()

      local people2 = NodeIdsGetNeighborIds(people, "KNOWS")
      for i,links in pairs(people2) do
        seen2:addIds(links)
      end
      seen2:inplace_difference(seen1)
      seen2:remove(node_id)

      named2 = FilterNodes(seen2:getIds(), "Person", "firstName", Operation.EQ, firstName)

      if((#named1 + #named2) < 20) then

        local seen3 = Roar.new()
        local people3 = NodeIdsGetNeighborIds(seen2:getIds(), "KNOWS")
        for i,links2 in pairs(people3) do
            seen3:addIds(links2)
        end
        seen3:inplace_difference(seen2)
        seen3:inplace_difference(seen1)
        seen3:remove(node_id)

        named3 = FilterNodes(seen3:getIds(), "Person", "firstName", Operation.EQ, firstName)
      end
    end

    local known = {}
    local found = {named1, named2, named3}

    for i = 1, #found do
      if (#found[i] > 0) then
        for j, person in pairs(found[i]) do
          local properties = person:getProperties()
          otherPerson = {
            ["otherPerson.id"] = properties["id"],
            ["otherPerson.lastName"] = properties["lastName"],
            ["otherPerson.birthday"] = properties["birthday"],
            ["otherPerson.creationDate"] = properties["creationDate"],
            ["otherPerson.gender"] = properties["gender"],
            ["otherPerson.browserUsed"] = properties["browserUsed"],
            ["otherPerson.locationIP"] = properties["locationIP"],
            ["otherPerson.email"] = properties["email"],
            ["otherPerson.speaks"] = properties["speaks"],
            ["distanceFromPerson"] = i
          }
          table.insert(known, otherPerson)
        end
      end
    end

    function sort_on_values(t,...)
      local a = {...}
      table.sort(t, function (u,v)
        for i = 1, #a do
          if u[a[i]] > v[a[i]] then return false end
          if u[a[i]] < v[a[i]] then return true end
        end
      end)
    end

    sort_on_values(known,"distanceFromPerson","otherPerson.lastName", "otherPerson.id")
    local smaller = table.move(known, 1, 20, 1, {})

    local results = {}
    for j, person in pairs(smaller) do
        local studied_list = {}
        local worked_list = {}
        local studied = NodeGetRelationships("Person", tostring(person["otherPerson.id"]), Direction.OUT, "STUDY_AT" )
        local worked = NodeGetRelationships("Person", tostring(person["otherPerson.id"]), Direction.OUT, "WORK_AT" )

        for s = 1, #studied do
            table.insert(studied_list, NodeGetProperty(studied[s]:getEndingNodeId(), "name"))
            table.insert(studied_list, RelationshipGetProperty(studied[s]:getId(), "classYear"))
        end

       for s = 1, #worked do
          table.insert(worked_list, NodeGetProperty(worked[s]:getEndingNodeId(), "name"))
          table.insert(worked_list, RelationshipGetProperty(worked[s]:getId(), "workFrom"))
       end

      person["universities"] = table.concat(studied_list, ", ")
      person["companies"] = table.concat(worked_list, ", ")
      person["otherPerson.creationDate"] = DateToISO(person["otherPerson.creationDate"])
      table.insert(results, person)
    end

results