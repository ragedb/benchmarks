--ALL
-- Interactive Query 1
ldbc_snb_iq01 = function(person_id, firstName)

    local node_id = NodeGetId("Person", person_id)
    local people = NodeGetNeighborIds(node_id, "KNOWS")
    local seen1 = Roar.new()

    seen1:addIds(people)
    local named1 = FilterNodes(seen1:getIds(), "Person", "firstName", Operation.EQ, firstName)
    local named2 = {}
    local named3 = {}
    local temp_count = 0

    if(#named1 < 20) then
      local seen2 = Roar.new()

      local people2 = NodeIdsGetNeighborIds(people, "KNOWS")
      seen2:addValues(people2)
      seen2:inplace_difference(seen1)
      seen2:remove(node_id)

      named2 = FilterNodes(seen2:getIds(), "Person", "firstName", Operation.EQ, firstName)

      if((#named1 + #named2) < 20) then

        local seen3 = Roar.new()
        local people3 = NodeIdsGetNeighborIds(seen2:getIds(), "KNOWS")
        seen3:addValues(people3)
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
            ["node_id"] = person:getId(),
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
        local person_id = person["node_id"]
        local studied_list = {}
        local worked_list = {}
        local studied = NodeGetRelationships(person_id, Direction.OUT, "STUDY_AT")
        local worked = NodeGetRelationships(person_id, Direction.OUT, "WORK_AT")

        for s = 1, #studied do
            local temp = {}
            table.insert(temp, NodeGetProperty(studied[s]:getEndingNodeId(), "name"))
            table.insert(temp, studied[s]:getProperty("classYear"))
            table.insert(temp, NodeGetNeighbors(studied[s]:getEndingNodeId(), Direction.OUT, "ORGANISATION_IS_LOCATED_IN")[1]:getProperty("name"))
            table.insert(studied_list, table.concat(temp, ", "))
        end

       for s = 1, #worked do
          local temp = {}
          table.insert(temp, NodeGetProperty(worked[s]:getEndingNodeId(), "name"))
          table.insert(temp, worked[s]:getProperty("workFrom"))
          table.insert(temp, NodeGetNeighbors(worked[s]:getEndingNodeId(), Direction.OUT, "ORGANISATION_IS_LOCATED_IN")[1]:getProperty("name"))
          table.insert(worked_list, table.concat(temp, ", "))
       end

       local located_in = NodeGetNeighbors(person_id, Direction.OUT, "PERSON_IS_LOCATED_IN" )

      person["universities"] = studied_list
      person["companies"] = worked_list
      person["otherPerson.creationDate"] = DateToISO(person["otherPerson.creationDate"])
      person["locationCity.name"] = located_in[1]:getProperty("name")
      person["node_id"] = nil
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
          local messages = NodeGetNeighbors(friend:getId(), Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
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
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_properties = NodeIdsGetProperties(friends)
    local messages = NodeIdsGetNeighborIds(friends, Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})

    local results = {}
    local friend_properties_map = {}
    for id, properties in pairs(friend_properties) do
      friend_properties_map[id] = properties
    end

    for friend_id, user_message_ids in pairs(messages) do
         local properties = friend_properties_map[friend_id]
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
    local cities_of_people = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.OUT, "PERSON_IS_LOCATED_IN", cities_of_countries:getIds())
    for person_id, citi_ids in pairs(cities_of_people) do
        otherPerson:remove(person_id)
    end

    -- Find messages in those countries  NOTE :SLOW PART
    local country_ids = {country_x_node_id, country_y_node_id}
    table.sort(country_ids)
    local person_candidates = {}
    local message_candidates = Roar.new()
    local messages_of_people = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
    for person_id, message_ids in pairs(messages_of_people) do
        local country_x_messages = {}
        local country_y_messages = {}
        local messages_country_ids = NodeIdsGetNeighborIds(message_ids, Direction.OUT, {"POST_IS_LOCATED_IN", "COMMENT_IS_LOCATED_IN"}, country_ids)
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
    local country_x_people = NodeIdsGetNeighborIds(country_x_cities, Direction.IN, "PERSON_IS_LOCATED_IN")
    local country_y_people = NodeIdsGetNeighborIds(country_y_cities, Direction.IN, "PERSON_IS_LOCATED_IN")

    local locals_of_countries = Roar.new()
    for city_id, person_ids in pairs(country_x_people) do
        locals_of_countries:addIds(person_ids)
    end
    for city_id, person_ids in pairs(country_y_people) do
        locals_of_countries:addIds(person_ids)
    end

    -- Find the messages from each country that fit the time range
    local countries_message_ids = NodeIdsGetNeighborIds(country_ids, Direction.IN, {"POST_IS_LOCATED_IN", "COMMENT_IS_LOCATED_IN"})

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
    otherPerson:addValues(friend_of_friends)

    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    -- Remove friends and fof that may be locals
    otherPerson:inplace_difference(locals_of_countries)

    -- Count the messages of each creator by country
    local x_results = {}
    local y_results = {}
    local valid_creators_of_country_x = NodeIdsGetNeighborIds(valid_countries_message_ids[country_x_node_id], Direction.OUT, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
    local valid_creators_of_country_y = NodeIdsGetNeighborIds(valid_countries_message_ids[country_y_node_id], Direction.OUT, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
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
    local posts_of_friends = NodeIdsGetNeighborIds(friends, Direction.IN, "POST_HAS_CREATOR")
    -- Collect the dates each tag was used by friends based on the post creation date
    local tag_count = {}
    for friend_id, post_ids in pairs(posts_of_friends) do
        local less_than_end_date = FilterNodeIds(post_ids, "Message", "creationDate", Operation.LT, end_date, 0, 10000000)
        local post_id_creation_date = NodeIdsGetProperty(less_than_end_date, "creationDate")
        local post_id_tag_ids =  NodeIdsGetNeighborIds(less_than_end_date, Direction.OUT, "POST_HAS_TAG")
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
    local tag_names = NodeIdsGetProperty(tag_ids, "name")
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
    otherPerson:addValues(friend_of_friends)

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

    -- Collect a map of forum_id keys and a list of other id values
    local forum_id_valid_other_ids = {}
    local all_valid_forums = Roar.new()
    for other_id, forum_links in pairs(other_id_forum_links) do
        for i = 1, #forum_links do
            if (membership_check:contains(forum_links[i]:getRelationshipId())) then
                if (forum_id_valid_other_ids[forum_links[i]:getNodeId()] == nil) then
                    forum_id_valid_other_ids[forum_links[i]:getNodeId()] = Roar.new()
                end
               forum_id_valid_other_ids[forum_links[i]:getNodeId()]:add(other_id:getNodeId())
            end
        end
    end

    for forum_id, _ in pairs(forum_id_valid_other_ids) do
        all_valid_forums:add(forum_id)
    end

    -- Get all the posts for the valid forums
    local results = {}
    local forum_posts = NodeIdsGetNeighborIds(all_valid_forums:getIds(), Direction.OUT, "CONTAINER_OF")
    for forum_id, post_ids in pairs(forum_posts) do
        -- sum the posts in the forum that were created by the other ids
        local forum_count = 0
        local post_count = NodeIdsGetNeighborIds(post_ids, Direction.OUT, "POST_HAS_CREATOR", forum_id_valid_other_ids[forum_id]:getIds())
        for post_id, _ in pairs(post_count) do
            forum_count = forum_count + 1
        end
        if (forum_count > 0) then
            table.insert(results, { ["forum.title"] = forum_id, ["postCount"] = forum_count })
        end
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
    -- Get the tag, person and their friends and friends of friends
    local tag_id = FindNodeIds("Tag", "name", Operation.EQ, tagName, 0, 1)[1]
    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")

    -- Collect friends and fofs
    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    otherPerson:addValues(friend_of_friends)
    -- Remove starting person
    otherPerson:remove(node_id)

    -- From the starting tag, get all the posts
    local tagged_post_ids = NodeGetNeighborIds(tag_id, Direction.IN, "POST_HAS_TAG")

    -- From these posts, get all the creators that are our friends and fofs
    local posts_creator_ids = NodeIdsGetNeighborIds(tagged_post_ids, Direction.OUT, "POST_HAS_CREATOR", otherPerson:getIds())

    -- Collect the tagged posts of our friends and fofs
    local valid_posts = Roar.new()
    for post_id, _ in pairs(posts_creator_ids) do
        valid_posts:add(post_id)
    end

    local post_counts = {}
    local posts_tag_ids = NodeIdsGetNeighborIds(valid_posts:getIds(), Direction.OUT, "POST_HAS_TAG")
    for post_id, tag_ids in pairs(posts_tag_ids) do
        for i = 1, #tag_ids do
            post_counts[tag_ids[i]] = (post_counts[tag_ids[i]] or 0) + 1
        end
    end
    -- Do not count starting tag
    post_counts[tag_id] = nil

    local results = {}
    for tag_id, post_count in pairs (post_counts) do
        table.insert(results, {["otherTag.name"] = tag_id, ["postCount"] = post_count})
    end

    -- Sort whatever is left by total count desc and id ascending
    table.sort(results, function(a, b)
      if a["postCount"] > b["postCount"] then
          return true
      end
      if (a["postCount"] == b["postCount"]) then
          return (a["otherTag.name"] < b["otherTag.name"] )
      end
    end)

    local smaller = table.move(results, 1, 10, 1, {})

    local tag_ids = {}
    for i = 1, #smaller do
        table.insert(tag_ids, smaller[i]["otherTag.name"])
    end

    local tag_names = NodeIdsGetProperty(tag_ids, "name")
    for i = 1, #smaller do
      smaller[i]["otherTag.name"] = tag_names[smaller[i]["otherTag.name"]]
    end
    return smaller
end

-- Interactive Query 7
ldbc_snb_iq07 = function(person_id)
    local node_id = NodeGetId("Person", person_id)
    local people = NodeGetNeighborIds(node_id, "KNOWS")
    local friends = Roar.new()
    friends:addIds(people)

    local created = NodeGetNeighborIds(node_id, Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
    local messages = Roar.new()
    messages:addIds(created)
    local message_likes = LinksGetLinks(messages:getNodeHalfLinks(), Direction.IN, "LIKES")
    local rels = Roar.new()
    for message_link, likes_links in pairs(message_likes) do
        for i = 1, #likes_links do
            rels:add(likes_links[i]:getRelationshipId())
        end
    end
    local liked_rels = FilterRelationships(rels:getIds(), "LIKES", "creationDate", Operation.GT, 0.0, 0, 20, Sort.DESC)
    local results = {}
    for i = 1, #liked_rels do
        local friend_id = liked_rels[i]:getStartingNodeId()
        local friend_properties = NodeGetProperties(friend_id)
        local message_id = liked_rels[i]:getEndingNodeId()
        local msg_properties = NodeGetProperties(message_id)
        local liked_time = liked_rels[i]:getProperty("creationDate")
        local result = {
           ["friend.id"] = friend_properties["id"],
           ["friend.firstName"] = friend_properties["firstName"],
           ["friend.lastName"] = friend_properties["lastName"],
           ["likes.creationDate"] = DateToISO(liked_time),
           ["message.id"] = msg_properties["id"],
           ["minutesLatency"] = math.floor(((liked_time - msg_properties["creationDate"]) / 60) + 0.5),
           ["isNew"] = friends:contains(friend_id)
        }
       if (msg_properties["content"] == '') then
           result["message.imageFile"] = msg_properties["imageFile"]
       else
           result["message.content"] = msg_properties["content"]
       end
       table.insert(results, result)
    end

      table.sort(results, function(a, b)
          local adate = a["likes.creationDate"]
          local bdate = b["likes.creationDate"]
          if adate > bdate then
              return true
          end
          if (adate == bdate) then
              return (a["friend.id"] < b["friend.id"] )
          end
      end)

    return results
end

-- Interactive Query 8
ldbc_snb_iq08 = function(person_id)
    local node_id = NodeGetId("Person", person_id)
    local created = NodeGetNeighborIds(node_id, Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
    local messages = Roar.new()
    messages:addIds(created)
    local message_replies = NodeIdsGetNeighborIds(messages:getIds(), Direction.IN, "REPLY_OF")
    local comment_ids = Roar.new()
    comment_ids:addValues(message_replies)
    local latest = FilterNodes(comment_ids:getIds(), "Message", "creationDate", Operation.GT, 0.0, 0, 20, Sort.DESC)

    local results = {}
    for i = 1, #latest do
        local msg_properties = latest[i]:getProperties()
        local author = NodeGetNeighbors(latest[i], Direction.OUT, "COMMENT_HAS_CREATOR")[1]
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

    return results
end

-- Interactive Query 9
ldbc_snb_iq09 = function(person_id, max_date)
    local maxDate_double = max_date / 1000.0

    local node_id = NodeGetId("Person", person_id)
    local friends = NodeGetNeighborIds(node_id, "KNOWS")
    local friend_of_friends = NodeIdsGetNeighborIds(friends, "KNOWS")
    -- Store the unique friends and friends of friends in a map
    local otherPerson = Roar.new()
    otherPerson:addIds(friends)
    otherPerson:addValues(friend_of_friends)
    -- Remove original person from friends and fof list
    otherPerson:remove(node_id)

    local otherPerson_messages = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.IN, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})
    local messages = Roar.new()
    messages:addValues(otherPerson_messages)
    local latest = FilterNodes(messages:getIds(), "Message", "creationDate", Operation.LT, maxDate_double, 0, 20, Sort.DESC)

    local results = {}
    for i = 1, #latest do
        local msg_properties = latest[i]:getProperties()
        local author = NodeGetNeighbors(latest[i], Direction.OUT, {"POST_HAS_CREATOR", "COMMENT_HAS_CREATOR"})[1]
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

    return results
end

-- Interactive Query 10
ldbc_snb_iq10 = function(person_id, month)

end

-- Interactive Query 11
ldbc_snb_iq11 = function(person_id, country_name, workFromYear)
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
    local company_ids = NodeGetNeighborIds(country_id, Direction.IN, "ORGANISATION_IS_LOCATED_IN") -- gets companies
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

    return smaller
end

-- Interactive Query 12
ldbc_snb_iq12 = function(person_id, tag_class_name)
     -- Get the person and their friends
     local node_id = NodeGetId("Person", person_id)
     local friends = NodeGetNeighborIds(node_id, "KNOWS")
     table.sort(friends)

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

     -- Get the Posts
     local tag_posts = NodeIdsGetNeighborIds(all_tag_ids:getIds(), Direction.IN, "POST_HAS_TAG")
     local all_posts = Roar.new()
     all_posts:addValues(tag_posts)

     -- Get the comments of all the messages
     local posts_comments = NodeIdsGetNeighborIds(all_posts:getIds(), Direction.IN, "REPLY_OF")
     local all_comments = Roar.new()
     all_comments:addValues(posts_comments)

     -- Get the messages of the friends backwards
     local comment_friends = NodeIdsGetNeighborIds(all_comments:getIds(), Direction.OUT, "COMMENT_HAS_CREATOR", friends)

     local valid_friends = Roar.new()
     local results_count = {}
     local results_tags = {}
     for tag_id, post_ids in pairs(tag_posts) do
         for i = 1, #post_ids do
             local comments = posts_comments[post_ids[i]]
             for j = 1, #comments do
                 local friend_id = comment_friends[comments[j]]
                 if (friend_id) then
                     if (#friend_id > 0) then
                         friend_id = friend_id[1]
                         valid_friends:add(friend_id)
                         results_count[friend_id] = (results_count[friend_id] or 0) + 1
                         results_tags[friend_id] = (results_tags[friend_id] or {})
                         table.insert(results_tags[friend_id], tag_id)
                     end
                 end
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

     return smaller
end

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
            next_left:addValues(left_people)
            next_left:inplace_difference(seen_left)
            if (next_left:intersection(next_right):cardinality() > 0) then return length end
            length = length + 1
            seen_left:inplace_union(next_left)
        end
        if(next_right:cardinality() > 0) then
            right_people = NodeIdsGetNeighborIds(next_right:getIds(), "KNOWS")
            next_right:clear()
            next_right:addValues(right_people)
            next_right:inplace_difference(seen_right)
            if (next_right:intersection(next_left):cardinality() > 0) then return length end
            length = length + 1
            seen_right:inplace_union(next_right)
        end
    end

    return -1
end

-- Interactive Query 14
ldbc_snb_iq14 = function(person1_id, person2_id)

end