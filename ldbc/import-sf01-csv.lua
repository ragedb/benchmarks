LoadCSV("Person", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_0_0.csv", "|")

local type = ""
for i, place in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1-csv/place_0_0.csv", "|") do
   type = place.type:sub(1,1):upper()..place.type:sub(2)
   NodeAdd("Place", place.id, "{\"id\":"..place.id..",\"name\":".."\""..place.name.."\","..
   "\"url\":".."\""..place.url.."\","..
   "\"type\":".."\""..type.."\"}")
end

for i, organisation in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1-csv/organisation_0_0.csv", "|") do
   type = organisation.type:sub(1,1):upper()..organisation.type:sub(2)
   NodeAdd("Organisation", organisation.id, "{\"id\":"..organisation.id..",\"name\":".."\""..organisation.name.."\","..
   "\"url\":".."\""..organisation.url.."\","..
   "\"type\":".."\""..type.."\"}")
end

LoadCSV("Tag", "/home/max/CLionProjects/ldbc/sn-sf1-csv/tag_0_0.csv", "|")
LoadCSV("TagClass", "/home/max/CLionProjects/ldbc/sn-sf1-csv/tagclass_0_0.csv", "|")
LoadCSV("Forum", "/home/max/CLionProjects/ldbc/sn-sf1-csv/forum_0_0.csv", "|")

for i, message in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1-csv/post_0_0.csv", "|") do
   NodeAdd("Message", message.id, "{\"id\":"..message.id..",\"imageFile\":".."\""..message.imageFile.."\","..
    "\"locationIP\":".."\""..message.locationIP.."\","..
    "\"browserUsed\":".."\""..message.browserUsed.."\","..
    "\"language\":".."\""..message.language.."\","..
    "\"content\":".."\""..string.gsub(message.content, "\t", " ").."\","..
    "\"length\":"..message.length..",\"creationDate\":".."\""..message.creationDate.."\",\"type\":\"post\"}")
end

for i, message in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1-csv/comment_0_0.csv", "|") do
   NodeAdd("Message", message.id, "{\"id\":"..message.id..",\"locationIP\":".."\""..message.locationIP.."\","..
    "\"browserUsed\":".."\""..message.browserUsed.."\","..
    "\"content\":".."\""..string.gsub(message.content, "\t", " ").."\","..
    "\"length\":"..message.length..",\"creationDate\":".."\""..message.creationDate.."\",\"type\":\"comment\"}")
end

LoadCSV("REPLY_OF", "/home/max/CLionProjects/ldbc/sn-sf1-csv/comment_replyOf_post_0_0.csv", "|")
LoadCSV("REPLY_OF", "/home/max/CLionProjects/ldbc/sn-sf1-csv/comment_replyOf_comment_0_0.csv", "|")
LoadCSV("CONTAINER_OF", "/home/max/CLionProjects/ldbc/sn-sf1-csv/forum_containerOf_post_0_0.csv", "|")
LoadCSV("HAS_CREATOR", "/home/max/CLionProjects/ldbc/sn-sf1-csv/post_hasCreator_person_0_0.csv", "|")
LoadCSV("HAS_CREATOR", "/home/max/CLionProjects/ldbc/sn-sf1-csv/comment_hasCreator_person_0_0.csv", "|")
LoadCSV("IS_LOCATED_IN", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_isLocatedIn_place_0_0.csv", "|")
LoadCSV("IS_LOCATED_IN", "/home/max/CLionProjects/ldbc/sn-sf1-csv/organisation_isLocatedIn_place_0_0.csv", "|")
LoadCSV("IS_LOCATED_IN", "/home/max/CLionProjects/ldbc/sn-sf1-csv/comment_isLocatedIn_place_0_0.csv", "|")
LoadCSV("IS_LOCATED_IN", "/home/max/CLionProjects/ldbc/sn-sf1-csv/post_isLocatedIn_place_0_0.csv", "|")
LoadCSV("KNOWS", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_knows_person_0_0.csv", "|")
LoadCSV("HAS_INTEREST", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_hasInterest_tag_0_0.csv", "|")
LoadCSV("HAS_TAG", "/home/max/CLionProjects/ldbc/sn-sf1-csv/forum_hasTag_tag_0_0.csv", "|")
LoadCSV("HAS_TAG", "/home/max/CLionProjects/ldbc/sn-sf1-csv/comment_hasTag_tag_0_0.csv", "|")
LoadCSV("HAS_TAG", "/home/max/CLionProjects/ldbc/sn-sf1-csv/post_hasTag_tag_0_0.csv", "|")
LoadCSV("HAS_MODERATOR", "/home/max/CLionProjects/ldbc/sn-sf1-csv/forum_hasModerator_person_0_0.csv", "|")
LoadCSV("HAS_MEMBER", "/home/max/CLionProjects/ldbc/sn-sf1-csv/forum_hasMember_person_0_0.csv", "|")
LoadCSV("HAS_TYPE", "/home/max/CLionProjects/ldbc/sn-sf1-csv/tag_hasType_tagclass_0_0.csv", "|")
LoadCSV("IS_SUBCLASS_OF", "/home/max/CLionProjects/ldbc/sn-sf1-csv/tagclass_isSubclassOf_tagclass_0_0.csv", "|")
LoadCSV("STUDY_AT", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_studyAt_organisation_0_0.csv", "|")
LoadCSV("WORK_AT", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_workAt_organisation_0_0.csv", "|")
LoadCSV("LIKES", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_likes_comment_0_0.csv", "|")
LoadCSV("LIKES", "/home/max/CLionProjects/ldbc/sn-sf1-csv/person_likes_post_0_0.csv", "|")
LoadCSV("IS_PART_OF", "/home/max/CLionProjects/ldbc/sn-sf1-csv/place_isPartOf_place_0_0.csv", "|")

local person_id = 0
local next_id = 0
local count
local emails = {}
for i, person in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1-csv/person_email_emailaddress_0_0.csv", "|") do
    next_id = person['Person.id']
    if (person_id == 0) then person_id = next_id end

    if (next_id ~= person_id) then
        NodeSetProperty("Person", person_id, "email", emails)
        count = #emails
        for e=0, count do emails[e]=nil end
        person_id = next_id
    else
      table.insert(emails, person['email'])
    end
end
NodeSetProperty("Person", next_id, "email", emails)

person_id = 0
next_id = 0
local languages = {}
for i, person in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1-csv/person_speaks_language_0_0.csv", "|") do
    next_id = person['Person.id']
    if (person_id == 0) then person_id = next_id end

    if (next_id ~= person_id) then
        NodeSetProperty("Person", person_id, "speaks", languages)
        count = #languages
        for e=0, count do languages[e]=nil end
        person_id = next_id
    else
      table.insert(languages, person['language'])
    end
end
NodeSetProperty("Person", next_id, "speaks", languages)

local nodes_count = AllNodesCounts()
local rels_count= AllRelationshipsCounts()
nodes_count, rels_count