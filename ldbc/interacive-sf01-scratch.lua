    local person_id = "17592186052613"
    local tag_class_name = "BasketballPlayer"
    -- Get the person and their friends
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")

    -- Get the TagClass
    local tag_class_id = FindNodeIds("TagClass", "name", Operation.EQ, tag_class_name, 0, 1)[1]
    -- Loop until we get all the sub classes
    local all_tag_class_ids = Roar.new()
    all_tag_class_ids:add(tag_class_id)
    local cardinality = 0
    while (all_tag_class_ids:cardinality() > cardinality) do
        cardinality = all_tag_class_ids:cardinality()
        local sub_class_ids = NodeIdsGetNeighborIds(all_tag_class_ids:getIds(), Direction.IN, "IS_SUBCLASS_OF")
        all_tag_class_ids:addValues(sub_class_ids)
    end

    -- Get the Tags
    local tag_ids = NodeIdsGetNeighborIds(all_tag_class_ids:getIds(), Direction.IN, "HAS_TYPE")
    local all_tag_ids = Roar.new()
    all_tag_ids:addValues(tag_ids)

    -- Get the messages of the friends
    local friend_messages = NodeIdsGetNeighborIds(friends, Direction.IN, "HAS_CREATOR")
    local reverse_message_friend = {}
    for friend_id, message_ids in pairs(friend_messages) do
        for i = 1, #message_ids do
            reverse_message_friend[message_ids[i]] = friend_id
        end
    end

    local all_messages = Roar.new()
    all_messages:addValues(friend_messages)
    -- Get the posts of all the messages
    local comment_posts = NodeIdsGetNeighborIds(all_messages:getIds(), Direction.OUT, "REPLY_OF")
    local reverse_comment_posts = {}
    for comment_id, post_ids in pairs(comment_posts) do
        if (#post_ids > 0) then
            reverse_comment_posts[post_ids[1]] = comment_id
        end
    end
    -- Get the tags of all the posts that match
    local all_posts = Roar.new()
    all_posts:addValues(comment_posts)

    local valid_posts = NodeIdsGetNeighborIds(all_posts:getIds(), Direction.OUT, "HAS_TAG", all_tag_ids:getIds())

    local valid_friends = Roar.new()
    local results_count = {}
    local results_tags = {}
    for post_id, tag_ids in pairs(valid_posts) do
        if (#tag_ids > 0) then
            local friend_id = reverse_message_friend[reverse_comment_posts[post_id]]
            valid_friends:add(friend_id)
             results_count[friend_id] = (results_count[friend_id] or 0) + 1
             results_tags[friend_id] = (results_tags[friend_id] or {})
             for i = 1, #tag_ids do
                table.insert(results_tags[friend_id], tag_ids[i])
             end
        end
    end

    local friend_ids = NodeIdsGetProperty(valid_friends:getIds(), "id")
    local results = {}
    for friend_id, count in pairs(results_count) do
        table.insert(results, {["replyCount"] = count, ["friend.id"] = friend_ids[friend_id], ["friend.node_id"] = friend_id})
    end

    -- Sort whatever is left by total count desc and id ascending
    table.sort(results, function(a, b)
      if a["replyCount"] > b["replyCount"] then
          return true
      end
      if (a["replyCount"] == b["replyCount"]) then
          return (a["friend.id"] < b["friend.id"] )
      end
    end)

    local smaller = table.move(results, 1, 20, 1, {})


    local ids = {}
    for i = 1, #smaller do
      smaller[i]["friend.firstName"] = NodeGetProperty(smaller[i]["friend.node_id"], "firstName")
      smaller[i]["friend.lastName"] = NodeGetProperty(smaller[i]["friend.node_id"], "lastName")
      local result_tag_ids = Roar.new()
      ids = results_tags[ smaller[i]["friend.node_id"] ]
      result_tag_ids:addIds(ids)
      local table_names = {}
      for tag_id, name in pairs(NodeIdsGetProperty(result_tag_ids:getIds(), "name")) do
        table.insert(table_names, name)
      end
      smaller[i]["tagNames"] = table.concat(table_names, ", ")
      smaller[i]["friend.node_id"] = nil
    end


ids, smaller

   return smaller











    local person_id = "30786325583618"
    local country_name = "Laos"
    local workFromYear = 2010

    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")
    -- Store the unique friends and friends of friends in a map
    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    otherPerson:addValues(friend_of_friends)
    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    -- Get the country and the companies in that country (we unfortunately get messages as well due to a weird model)
    local country_id = FindNodeIds("Place", "name", Operation.EQ, country_name, 0, 1)[1]
    local company_ids = NodeGetNeighborIds(country_id, Direction.IN, "ORG_IS_LOCATED_IN") -- gets companies and messages
    local companies = Roar.new()
    companies:addIds(company_ids)

    local company_id_other_ids = NodeIdsGetNeighborIds(company_ids, Direction.IN, "WORK_AT", otherPerson:getIds())
    local valid_others = Roar.new()
    valid_others:addValues(company_id_other_ids)


    local work_at_links = LinksGetLinks(valid_others:getNodeHalfLinks(), Direction.OUT, "WORK_AT")
    local work_at_rels = Roar.new()
    for other_id, links in pairs(work_at_links) do
        for i = 1, #links do
            work_at_rels:add(links[i]:getRelationshipId())
        end
    end

    local valid_work_at_rels = FilterRelationships(work_at_rels:getIds(), "WORK_AT", "workFrom", Operation.LT, workFromYear, 0, 10000000, Sort.ASC)
    local valid_other_ids = Roar.new()
    local valid_company_ids = Roar.new()
    for i = 1, #valid_work_at_rels do
        valid_other_ids:add(valid_work_at_rels[i]:getStartingNodeId())
        valid_company_ids:add(valid_work_at_rels[i]:getEndingNodeId())
    end

    local other_id_ids = NodeIdsGetProperty(valid_other_ids:getIds(), "id")
    local company_id_names = NodeIdsGetProperty(valid_company_ids:getIds(), "name")

    --Optimization keep track of top-k
    local results = {}
    for i = 1, #valid_work_at_rels do
            local result = {
               ["otherPerson.id"] = other_id_ids[valid_work_at_rels[i]:getStartingNodeId()],
               ["workAt.workFrom"] = valid_work_at_rels[i]:getProperty("workFrom"),
               ["company.name"] = company_id_names[valid_work_at_rels[i]:getEndingNodeId()]
            }
           table.insert(results, result)
    end

    table.sort(results, function(a, b)
      local adate = a["workAt.workFrom"]
      local bdate = b["workAt.workFrom"]
      if adate < bdate then
          return true
      end
      if (adate == bdate) then
        local amessage_id = a["otherPerson.id"]
        local bmessage_id = b["otherPerson.id"]
        if  amessage_id < bmessage_id then
            return true
        end
        if (amessage_id == bmessage_id) then
            return (a["company.name"] < b["company.name"] )
        end
      end
    end)

    local smaller = table.move(results, 1, 10, 1, {})

    for i = 1, #smaller do
      smaller[i]["otherPerson.firstName"] = NodeGetProperty("Person", tostring(smaller[i]["otherPerson.id"]), "firstName")
      smaller[i]["otherPerson.lastName"] = NodeGetProperty("Person", tostring(smaller[i]["otherPerson.id"]), "lastName")
    end


    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")
    -- Store the unique friends and friends of friends in a map
    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    otherPerson:addValues(friend_of_friends)
    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    -- Get the country and the companies in that country (we unfortunately get messages as well due to a weird model)
    local country_id = FindNodeIds("Place", "name", Operation.EQ, country_name, 0, 1)[1]
    local company_ids = NodeGetNeighborIds(country_id, Direction.IN, "IS_LOCATED_IN") -- gets companies and messages
    local companies = Roar.new()
    companies:addIds(company_ids)


    local work_at_links = LinksGetLinks(otherPerson:getNodeHalfLinks(), Direction.OUT, "WORK_AT")
    local work_at_rels = Roar.new()
    for other_id, links in pairs(work_at_links) do
        for i = 1, #links do
            if (companies:contains(links[i]:getNodeId())) then
                work_at_rels:add(links[i]:getRelationshipId())
            end
        end
    end

    local valid_work_at_rels = FilterRelationships(work_at_rels:getIds(), "WORK_AT", "workFrom", Operation.LT, workFromYear, 0, 10000000, Sort.ASC)
    local valid_other_ids = Roar.new()
    local valid_company_ids = Roar.new()
    for i = 1, #valid_work_at_rels do
        valid_other_ids:add(valid_work_at_rels[i]:getStartingNodeId())
        valid_company_ids:add(valid_work_at_rels[i]:getEndingNodeId())
    end

    local other_id_ids = NodeIdsGetProperty(valid_other_ids:getIds(), "id")
    local company_id_names = NodeIdsGetProperty(valid_company_ids:getIds(), "name")

    --Optimization keep track of top-k
    local results = {}
    for i = 1, #valid_work_at_rels do
            local result = {
               ["otherPerson.id"] = other_id_ids[valid_work_at_rels[i]:getStartingNodeId()],
               ["workAt.workFrom"] = valid_work_at_rels[i]:getProperty("workFrom"),
               ["company.name"] = company_id_names[valid_work_at_rels[i]:getEndingNodeId()]
            }
           table.insert(results, result)
    end

    table.sort(results, function(a, b)
      local adate = a["workAt.workFrom"]
      local bdate = b["workAt.workFrom"]
      if adate < bdate then
          return true
      end
      if (adate == bdate) then
        local amessage_id = a["otherPerson.id"]
        local bmessage_id = b["otherPerson.id"]
        if  amessage_id < bmessage_id then
            return true
        end
        if (amessage_id == bmessage_id) then
            return (a["company.name"] < b["company.name"] )
        end
      end
    end)

    local smaller = table.move(results, 1, 10, 1, {})

    for i = 1, #smaller do
      smaller[i]["otherPerson.firstName"] = NodeGetProperty("Person", tostring(smaller[i]["otherPerson.id"]), "firstName")
      smaller[i]["otherPerson.lastName"] = NodeGetProperty("Person", tostring(smaller[i]["otherPerson.id"]), "lastName")
    end

 smaller



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