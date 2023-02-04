--ALL
-- Interactive Query 1
ldbc_snb_iq01 = function(person_id, firstName)

    local node_id = NodeGetId("Person", person_id)
    local people = NodeGetLinks(node_id, "KNOWS")
    local seen1 = Roar.new()

    seen1:addNodeIds(people)
    local named1 = FilterNodes(seen1:getIds(), "Person", "firstName", Operation.EQ, firstName)
    local named2 = {}
    local named3 = {}

    if(#named1 < 20) then 
      local seen2 = Roar.new()

      local people2 = LinksGetLinks(people, "KNOWS")
      for i,links in pairs(people2) do 
        seen2:addNodeIds(links)
      end  
      seen2:inplace_difference(seen1)
      seen2:remove(node_id)

      named2 = FilterNodes(seen2:getIds(), "Person", "firstName", Operation.EQ, firstName)

      if((#named1 + #named2) < 20) then 

        local seen3 = Roar.new()
        local people3 = LinksGetLinks(seen2:getNodeHalfLinks(), "KNOWS") 
        for i,links2 in pairs(people3) do 
            seen3:addNodeIds(links2) 
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

    return results
  
end

-- Interactive Query 2
ldbc_snb_iq02_orig = function(person_id, maxDate)
    local maxDate_double = maxDate / 1000.0
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighbors(node_id, "KNOWS")
    local results = {}
      for i, friend in pairs(friends) do
          local properties = friend:getProperties()
          local messages = NodeGetNeighbors(friend:getId(), Direction.IN, "HAS_CREATOR")
          for j, message in pairs(messages) do
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

--ALL
ldbc_snb_iq02 = function(person_id, maxDate)
    local maxDate_double = maxDate / 1000.0
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
         local messages_props = FilterNodeProperties(user_message_ids, "Message", "creationDate", Operation.LT, maxDate_double, 0, 20, Sort.DESC)
         for j, msg_properties in pairs(messages_props) do
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



-- Interactive Query 3
ldbc_snb_iq03_orig = function(person_id, country_x_name, country_y_name, start_date, duration_days)
    local start_date_double = start_date / 1000.0
    local end_date = start_date_double + (86400 * duration_days)
    -- Find the person
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")
    -- Store the unique friends and friends of friends in a map
    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    for friend_id, fof_ids in pairs(friend_of_friends) do
        otherPerson:addIds(fof_ids)
    end
    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    -- Get the country node ids

    local country_x_node_id = FindNodeIds("Place", "name", Operation.EQ, country_x_name, 0, 1)[1]
    local country_y_node_id = FindNodeIds("Place", "name", Operation.EQ, country_y_name, 0, 1)[1]

    -- Get the cities of those countries
    local country_x_cities = NodeGetNeighborIds(country_x_node_id, Direction.IN, "IS_PART_OF")
    local country_y_cities = NodeGetNeighborIds(country_y_node_id, Direction.IN, "IS_PART_OF")
    local cities_of_countries = Roar.new()
    cities_of_countries:addIds(country_x_cities)
    cities_of_countries:addIds(country_y_cities)

    -- Eliminate people that are local to either country
    local cities_of_people = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.OUT, "IS_LOCATED_IN", cities_of_countries:getIds())
    for person_id, citi_ids in pairs(cities_of_people) do
        otherPerson:remove(person_id)
    end

    -- Find messages in those countries  NOTE :SLOW PART
    local country_ids = {country_x_node_id, country_y_node_id}
    table.sort(country_ids)
    local person_candidates = {}
    local message_candidates = Roar.new()
    local messages_of_people = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.IN, "HAS_CREATOR")
    for person_id, message_ids in pairs(messages_of_people) do
        local country_x_messages = {}
        local country_y_messages = {}
        local messages_country_ids = NodeIdsGetNeighborIds(message_ids, Direction.OUT, "IS_LOCATED_IN", country_ids)
        for message_id, country_ids in pairs(messages_country_ids) do
            if (country_ids[1] == country_x_node_id) then
              table.insert(country_x_messages, message_id)
            end
            if (country_ids[1] == country_y_node_id) then
              table.insert(country_y_messages, message_id)
            end
        end
        -- Only consider people who have at least 1 message in each country
        if( #country_x_messages > 0 and #country_y_messages > 0) then
            local country_x_message_ids = Roar.new()
            local country_y_message_ids = Roar.new()
            country_x_message_ids:addIds(country_x_messages)
            country_y_message_ids:addIds(country_y_messages)
            message_candidates:addIds(country_x_messages)
            message_candidates:addIds(country_y_messages)
            person_candidates[person_id] = { country_x_message_ids, country_y_message_ids}
        end
    end

    -- Find messages valid in those times
    local equal_or_greater_start_date = FilterNodeIds(message_candidates:getIds(), "Message", "creationDate", Operation.GTE, start_date_double)
    local less_than_end_date = FilterNodeIds(equal_or_greater_start_date, "Message", "creationDate", Operation.LT, end_date)
    local valid_messages =  Roar.new()
    valid_messages:addIds(less_than_end_date)

    -- Get counts of valid messages
    local results = {}
    for person_id, roaring_message_ids in pairs(person_candidates) do
        local valid_x = roaring_message_ids[1]:inplace_intersection(valid_messages)
        local valid_x_count = valid_x:cardinality()
        local valid_y = roaring_message_ids[2]:inplace_intersection(valid_messages)
        local valid_y_count = valid_y:cardinality()

        -- Eliminate zero valid in either country
        if ( valid_x_count > 0 and valid_y_count > 0) then
            table.insert(results, { xCount = valid_x_count, yCount = valid_y_count, count = valid_x_count + valid_y_count, ["otherPerson.id"] = person_id } )
        end
    end

    -- Sort whatever is left by total count desc and id ascending
    table.sort(results, function(a, b)
      if a["count"] > b["count"] then
          return true
      end
      if (a["count"] == b["count"]) then
          return (a["otherPerson.id"] < b["otherPerson.id"] )
      end
    end)

    local smaller = table.move(results, 1, 20, 1, {})

    for i = 1, #smaller do
      smaller[i]["otherPerson.firstName"] = NodeGetProperty(smaller[i]["otherPerson.id"], "firstName")
      smaller[i]["otherPerson.lastName"] = NodeGetProperty(smaller[i]["otherPerson.id"], "lastName")
    end

    return smaller
end

-- Interactive Query 3
ldbc_snb_iq03 = function(person_id, country_x_name, country_y_name, start_date, duration_days)
    local start_date_double = start_date / 1000.0
    local end_date = start_date_double + (86400 * duration_days)
    -- Find the person
    local node_id = NodeGetId("Person", person_id)

    -- Get the country node ids
    local country_x_node_id = FindNodeIds("Place", "name", Operation.EQ, country_x_name, 0, 1)[1]
    local country_y_node_id = FindNodeIds("Place", "name", Operation.EQ, country_y_name, 0, 1)[1]
    local country_ids = { country_x_node_id, country_y_node_id }

    -- Get the cities of those countries
    local country_x_cities = NodeGetNeighborIds(country_x_node_id, Direction.IN, "IS_PART_OF")
    local country_y_cities = NodeGetNeighborIds(country_y_node_id, Direction.IN, "IS_PART_OF")

    -- Find the people that are local to either country
    local localPerson = Roar.new()
    local country_x_people = NodeIdsGetNeighborIds(country_x_cities, Direction.IN, "IS_LOCATED_IN")
    local country_y_people = NodeIdsGetNeighborIds(country_y_cities, Direction.IN, "IS_LOCATED_IN")

    local locals_of_countries = Roar.new()
    for city_id, person_ids in pairs(country_x_people) do
        locals_of_countries:addIds(person_ids)
    end
    for city_id, person_ids in pairs(country_y_people) do
        locals_of_countries:addIds(person_ids)
    end

    -- Find the messages from each country that fit the time range
    local countries_message_ids = NodeIdsGetNeighborIds(country_ids, Direction.IN, "IS_LOCATED_IN")

    local valid_countries_message_ids = {}
    for country_id, message_ids in pairs(countries_message_ids) do
        local equal_or_greater_start_date = FilterNodeIds(message_ids, "Message", "creationDate", Operation.GTE, start_date_double, 0, 10000000)
        local less_than_end_date = FilterNodeIds(equal_or_greater_start_date, "Message", "creationDate", Operation.LT, end_date, 0, 10000000)
        valid_countries_message_ids[country_id] = less_than_end_date
    end

    -- Find the unique friends and friends of friends
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")

    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    for friend_id, fof_ids in pairs(friend_of_friends) do
        otherPerson:addIds(fof_ids)
    end

    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    -- Remove friends and fof that may be locals
    otherPerson:inplace_difference(locals_of_countries)

    -- Count the messages of each creator by country
    local x_results = {}
    local y_results = {}
    local valid_creators_of_country_x = NodeIdsGetNeighborIds(valid_countries_message_ids[country_x_node_id], Direction.OUT, "HAS_CREATOR")
    local valid_creators_of_country_y = NodeIdsGetNeighborIds(valid_countries_message_ids[country_y_node_id], Direction.OUT, "HAS_CREATOR")
    local countryXCreator = Roar.new()
    local countryYCreator = Roar.new()
    for message_id, creator_id in pairs(valid_creators_of_country_x) do
        if ( #creator_id > 0) then
            countryXCreator:add(creator_id[1])
            x_results[creator_id[1]] = (x_results[creator_id[1]] or 0) + 1
        end
    end
    for message_id, creator_id in pairs(valid_creators_of_country_y) do
        if ( #creator_id > 0) then
            countryYCreator:add(creator_id[1])
            y_results[creator_id[1]] = (y_results[creator_id[1]] or 0) + 1
        end
    end
    -- Must be a creator in both countries
    countryXCreator:inplace_intersection(countryYCreator)
    -- Must be a friend or friend of friend
    countryXCreator:inplace_intersection(otherPerson)

   local results = {}
   local valid_creators_of_both = countryXCreator:getIds()

   for i = 1, #valid_creators_of_both do
       table.insert(results, { xCount = x_results[valid_creators_of_both[i]], yCount = y_results[valid_creators_of_both[i]], count = x_results[valid_creators_of_both[i]] + y_results[valid_creators_of_both[i]], ["otherPerson.id"] = valid_creators_of_both[i] } )
   end

    -- Sort whatever is left by total count desc and id ascending
    table.sort(results, function(a, b)
      if a["count"] > b["count"] then
          return true
      end
      if (a["count"] == b["count"]) then
          return (a["otherPerson.id"] < b["otherPerson.id"] )
      end
    end)

    local smaller = table.move(results, 1, 20, 1, {})

    for i = 1, #smaller do
      smaller[i]["otherPerson.firstName"] = NodeGetProperty(smaller[i]["otherPerson.id"], "firstName")
      smaller[i]["otherPerson.lastName"] = NodeGetProperty(smaller[i]["otherPerson.id"], "lastName")
    end

    return smaller
end



-- Interactive Query 4
ldbc_snb_iq04 = function(person_id, start_date, duration_days)
    local start_date_double = start_date / 1000.0
    local end_date = start_date_double + (86400 * duration_days)
    -- Find the person
    local node_id = NodeGetId("Person", person_id)

    -- Find the friends
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    -- Get the Posts of Friends
    local posts_of_friends = NodeIdsGetNeighborIds(friends, Direction.IN, "HAS_CREATOR")
    -- Collect the dates each tag was used by friends based on the post creation date
    local tag_count = {}
    for friend_id, post_ids in pairs(posts_of_friends) do
        local less_than_end_date = FilterNodeIds(post_ids, "Message", "creationDate", Operation.LT, end_date, 0, 10000000)
        local post_id_creation_date = NodesGetProperty(less_than_end_date, "creationDate")
        local post_id_tag_ids =  NodeIdsGetNeighborIds(less_than_end_date, Direction.OUT, "HAS_TAG")
        for post_id, creation_date in pairs(post_id_creation_date) do
            local tag_ids = post_id_tag_ids[post_id]
            for i = 1, #tag_ids do
              tag_count[tag_ids[i]] = (tag_count[tag_ids[i]] or { })
              table.insert(tag_count[tag_ids[i]], creation_date)
            end
        end
    end

    local results = {}
    for tag_id, created_dates in pairs(tag_count) do
        table.sort(created_dates)
        if (created_dates[1] >= start_date_double) then
            table.insert(results, { ["tag.name"] = tag_id, ["postCount"] = #created_dates })
        end
    end

    -- Get the names of the Tags
    local tag_ids = {}
    for i = 1, #results do
      table.insert(tag_ids, results[i]["tag.name"])
    end
    local tag_names = NodesGetProperty(tag_ids, "name")
    for i = 1, #results do
      results[i]["tag.name"] = tag_names[results[i]["tag.name"]]
    end


    -- Sort whatever is left by total count desc and id ascending
    table.sort(results, function(a, b)
      if a["postCount"] > b["postCount"] then
          return true
      end
      if (a["postCount"] == b["postCount"]) then
          return (a["tag.name"] < b["tag.name"] )
      end
    end)

    local smaller = table.move(results, 1, 10, 1, {})
   return smaller
end

-- Interactive Query 5
ldbc_snb_iq05 = function(person_id, min_date)
    local min_date_double = min_date / 1000.0
    -- Find the person
    local node_id = NodeGetId("Person", person_id)
    -- Find the friends and friends of friends
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")

    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    for friend_id, fof_ids in pairs(friend_of_friends) do
        otherPerson:addIds(fof_ids)
    end
    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    --Find Forums that any Person otherPerson became a member of after a given date ($minDate).
    local other_id_forum_links = LinksGetLinks(otherPerson:getNodeHalfLinks(), Direction.IN, "HAS_MEMBER")
    local forum_rels = Roar.new()
    for other_id, forum_links in pairs(other_id_forum_links) do
        forum_rels:addRelationshipIds(forum_links)
    end
    -- Only those after a certain date, side one of the triangle
    local valid_memberships = FilterRelationshipIds(forum_rels:getIds(), "HAS_MEMBER", "joinDate", Operation.GT, min_date_double, 0, 10000000)

    local membership_check = Roar.new()
    membership_check:addIds(valid_memberships)

    -- Get Valid forums
    local valid_other_id_forum_ids = {}
    local all_valid_forums = Roar.new()
    for other_id, forum_links in pairs(other_id_forum_links) do
        local valid_forums = {}
        for i = 1, #forum_links do
            if (membership_check:contains(forum_links[i]:getRelationshipId())) then
                table.insert(valid_forums, forum_links[i]:getNodeId())
            end
        end
        if (#valid_forums > 0) then
            valid_other_id_forum_ids[other_id:getNodeId()] = valid_forums
            all_valid_forums:addIds(valid_forums)
        end
    end

    -- Get posts from other person, side two of the triangle
    local other_person_message_ids = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.IN, "HAS_CREATOR")
    local all_messages = Roar.new()
    for other_id, message_ids in pairs(other_person_message_ids) do
       all_messages:addIds(message_ids)
    end

    -- Get side 3 and close the triangle
    local valid_posts = NodeIdsGetNeighborIds(all_valid_forums:getIds(), Direction.OUT, "CONTAINER_OF", all_messages:getIds())

    -- We have to further filter the valid posts per other person/forum id
    local forum_counts = {}
    local temp_count = 0
    for other_id, forum_ids in pairs(valid_other_id_forum_ids) do
        --temp_count = temp_count + 1 -- 2,443
        if (other_person_message_ids[other_id]) then
            temp_count = temp_count + 1 -- 0
            for i = 1, #forum_ids do
                if (valid_posts[forum_ids[i]]) then
                -- get intersection of the messages in a forum, with the messages of a person
                local forum_count = IntersectIdsCount(valid_posts[forum_ids[i]], other_person_message_ids[other_id])
                if (forum_count > 0) then
                    forum_counts[forum_ids[i]] = (forum_counts[forum_ids[i]]  or 0) + forum_count
                end
                end
            end
        end
    end

    local results = {}
    for forum_id, post_count in pairs(forum_counts) do
        table.insert(results, { ["forum.title"] = forum_id, ["postCount"] = post_count })
    end

    -- Sort whatever is left by total count desc and id ascending
    table.sort(results, function(a, b)
      if a["postCount"] > b["postCount"] then
          return true
      end
      if (a["postCount"] == b["postCount"]) then
          return (a["forum.title"] < b["forum.title"] )
      end
    end)

    local smaller = table.move(results, 1, 20, 1, {})

    for i = 1, #smaller do
      smaller[i]["forum.title"] = NodeGetProperty(smaller[i]["forum.title"], "title")
    end

    return smaller
end

-- Interactive Query 6
ldbc_snb_iq06 = function(person_id, tagName)
    local tag_id = FindNodeIds("Tag", "name", Operation.EQ, tagName, 0, 1)[1]
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends)

    local otherPerson = Roar.new()
    otherPerson:addNodeIds(friends)
    for friend_id, fof_ids in pairs(friend_of_friends) do
        otherPerson:addNodeIds(fof_ids)
    end
    otherPerson.remove(node_id)
    local all_post_links = LinksGetLinks(otherPerson:getNodeHalfLinks(), Direction.IN, "HAS_CREATOR")
    for otherPerson_link, post_links in pairs(all_post_links) do
    --todo check for post vs comments


    end
    --todo:finish
    local results = {}
    local smaller = table.move(results, 1, 20, 1, {})
    return smaller
end

-- Interactive Query 7

-- Interactive Query 8

-- Interactive Query 9

-- Interactive Query 10

-- Interactive Query 11

-- Interactive Query 12

-- Interactive Query 13

ldbc_snb_iq13 = function(person1_id, person2_id)
    if (person1_id == person2_id) then return 0 end
    local length = 1
    local node1_id = NodeGetId("Person", person1_id)
    local node2_id = NodeGetId("Person", person2_id)
    local left_people = {}
    local right_people = {}

    local seen_left = Roar.new()
    local seen_right = Roar.new()
    local next_left = Roar.new()
    local next_right = Roar.new()

    seen_left:add(node1_id)
    seen_right:add(node2_id)
    next_left:add(node1_id)
    next_right:add(node2_id)

    while ((next_left:cardinality() + next_right:cardinality()) > 0) do
        if(next_left:cardinality() > 0) then
            left_people = NodeIdsGetNeighborIds(next_left:getIds(), "KNOWS")
            next_left:clear()
            next_left:addIds(left_people)
            next_left:inplace_difference(seen_left)
            if (next_left:intersection(next_right):cardinality() > 0) then return length end
            length = length + 1
            seen_left:inplace_union(next_left)
        end
        if(next_right:cardinality() > 0) then
            right_people = NodeIdsGetNeighborIds(next_right:getIds(), "KNOWS")
            next_right:clear()
            next_right:addIds(right_people)
            next_right:inplace_difference(seen_right)
            if (next_right:intersection(next_left):cardinality() > 0) then return length end
            length = length + 1
            seen_right:inplace_union(next_right)
        end
    end

    return -1
end

-- Interactive Query 14