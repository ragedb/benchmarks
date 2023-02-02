
    local person_id = "21990232559429"
    local start_date = 1335830400000
    local duration_days = 37


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
    smaller