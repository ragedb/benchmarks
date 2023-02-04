local person_id = "8796093030404"
local min_date  = 1347062400000


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
    local valid_memberships = FilterRelationshipIds(forum_rels:getIds(), "HAS_MEMBER", "joinDate", Operation.GT, min_date_double, 0, 10000000)

    -- Traverse Links to Links
    local membership_check = Roar.new()
    membership_check:addIds(valid_memberships)

    -- Get posts from other person
    local other_person_message_ids = NodeIdsGetNeighborIds(otherPerson:getIds(), Direction.IN, "HAS_CREATOR")

    local forum_counts = {}

    -- Get Valid Forums per other_id
    for other_id_link, forum_links in pairs(other_id_forum_links) do
        local other_id = other_id_link:getNodeId()
        local valid_forums = {}
        for i = 1, #forum_links do
            if (membership_check:contains(forum_links[i]:getRelationshipId())) then
                table.insert(valid_forums, forum_links[i]:getNodeId())
            end
        end
        -- Close the triangle
        local valid_posts = NodeIdsGetNeighborIds(other_person_message_ids[other_id], Direction.IN, "CONTAINER_OF", valid_forums)
        for message_id, forum_ids in pairs(valid_posts) do
            -- Group Count
            forum_counts[forum_ids[1]] = (forum_counts[forum_ids[1]] or 0) + 1
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


smaller