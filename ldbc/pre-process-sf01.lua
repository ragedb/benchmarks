-- Takes about 10 minutes:
function calculate_weight(num_interactions)
    if (num_interactions > 0) then
        local integer, fraction = math.modf(40 - math.sqrt(num_interactions) + 0.5)
        return math.max(integer, 1)
    end
    return 0
end


-- Instead of scanning down all people, we'll scan all KNOWS relationships
local skip = 0
local all_knows = AllRelationships("KNOWS", skip, 10000)

local rels = Roar.new()

while (#all_knows > 0) do
    local posts_cache = {}
    local reply_cache = {}
    for i = 1, #all_knows do
        local person1_id = all_knows[i]:getStartingNodeId()
        local person2_id = all_knows[i]:getEndingNodeId()

        local person1_posts = posts_cache[person1_id]
        if (person1_posts == nil) then
            person1_posts = Roar.new()
            person1_posts:addIds(NodeGetNeighborIds(person1_id, Direction.IN, "HAS_CREATOR"))
            posts_cache[person1_id] = person1_posts
        end

        local person2_posts = posts_cache[person2_id]
        if (person2_posts == nil) then
            person2_posts = Roar.new()
            person2_posts:addIds(NodeGetNeighborIds(person2_id, Direction.IN, "HAS_CREATOR"))
            posts_cache[person2_id] = person2_posts
        end

        local person1_replies = reply_cache[person1_id]
        if (person1_replies == nil) then
            person1_replies = Roar.new()
            person1_replies:addValues(NodeIdsGetNeighborIds(person1_posts:getIds(), Direction.OUT, "REPLY_OF"))
            reply_cache[person1_id] = person1_replies
        end

        local person2_replies = reply_cache[person2_id]
        if (person2_replies == nil) then
            person2_replies = Roar.new()
            person2_replies:addValues(NodeIdsGetNeighborIds(person2_posts:getIds(), Direction.OUT, "REPLY_OF"))
            reply_cache[person2_id] = person2_replies
        end


        local reply_count =  0 + (person1_posts:intersection(person2_replies)):cardinality() + (person2_posts:intersection(person1_replies)):cardinality()
        if (reply_count > 0) then
            local weight = calculate_weight(reply_count)
            RelationshipSetProperty(all_knows[i]:getId(), "weight", weight)
            rels:add(all_knows[i]:getId())
        end
    end

    -- Get the next batch
    posts_cache = {}
    reply_cache = {}
    skip = skip + 10000
    all_knows = AllRelationships("KNOWS", skip, 10000)
end

"done preprocessing"