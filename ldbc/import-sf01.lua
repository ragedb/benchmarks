for i, person in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_0_0.csv", "|") do
   NodeAdd("Person", person.id,
  "{\"id\":"..person.id..","..
   "\"firstName\":".."\""..person.firstName.."\","..
   "\"lastName\":".."\""..person.lastName.."\","..
   "\"gender\":".."\""..person.gender.."\","..
   "\"birthday\":".."\""..person.birthday.."\","..
   "\"creationDate\":".."\""..person.creationDate.."\","..
   "\"locationIP\":".."\""..person.locationIP.."\","..
   "\"browserUsed\":".."\""..person.browserUsed.."\"}")
end

local type = ""
for i, place in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/place_0_0.csv", "|") do
   type = place.type:sub(1,1):upper()..place.type:sub(2)
   NodeAdd("Place", place.id, "{\"id\":"..place.id..",\"name\":".."\""..place.name.."\","..
   "\"url\":".."\""..place.url.."\","..
   "\"type\":".."\""..type.."\"}")
end

for i, organisation in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/organisation_0_0.csv", "|") do
   type = organisation.type:sub(1,1):upper()..organisation.type:sub(2)
   NodeAdd("Organisation", organisation.id, "{\"id\":"..organisation.id..",\"name\":".."\""..organisation.name.."\","..
   "\"url\":".."\""..organisation.url.."\","..
   "\"type\":".."\""..type.."\"}")
end

for i, tag in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/tag_0_0.csv", "|") do
   NodeAdd("Tag", tag.id, "{\"id\":"..tag.id..",\"name\":".."\""..tag.name.."\",\"url\":".."\""..tag.url.."\"}")
end

for i, tagclass in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/tagclass_0_0.csv", "|") do
   NodeAdd("TagClass", tagclass.id, "{\"id\":"..tagclass.id..",\"name\":".."\""..tagclass.name.."\",\"url\":".."\""..tagclass.url.."\"}")
end

for i, forum in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/forum_0_0.csv", "|") do
   NodeAdd("Forum", forum.id, "{\"id\":"..forum.id..",\"title\":".."\""..forum.title.."\",\"creationDate\":".."\""..forum.creationDate.."\"}")
end

for i, message in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/post_0_0.csv", "|") do
   NodeAdd("Message", message.id, "{\"id\":"..message.id..",\"imageFile\":".."\""..message.imageFile.."\","..
    "\"locationIP\":".."\""..message.locationIP.."\","..
    "\"browserUsed\":".."\""..message.browserUsed.."\","..
    "\"language\":".."\""..message.language.."\","..
    "\"content\":".."\""..string.gsub(message.content, "\t", " ").."\","..
    "\"length\":"..message.length..",\"creationDate\":".."\""..message.creationDate.."\",\"type\":\"post\"}")
end

for i, message in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/comment_0_0.csv", "|") do
   NodeAdd("Message", message.id, "{\"id\":"..message.id..",\"locationIP\":".."\""..message.locationIP.."\","..
    "\"browserUsed\":".."\""..message.browserUsed.."\","..
    "\"content\":".."\""..string.gsub(message.content, "\t", " ").."\","..
    "\"length\":"..message.length..",\"creationDate\":".."\""..message.creationDate.."\",\"type\":\"comment\"}")
end


for i, replyOf in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/comment_replyOf_post_0_0.csv", "|") do
    RelationshipAdd("REPLY_OF", "Message", replyOf['Comment.id'], "Message", replyOf['Post.id'])
end

for i, replyOf in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/comment_replyOf_comment_0_0.csv", "|") do
    RelationshipAdd("REPLY_OF", "Message", replyOf['Comment1.id'], "Message", replyOf['Comment2.id'])
end

for i, containerOf in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/forum_containerOf_post_0_0.csv", "|") do
    RelationshipAdd("CONTAINER_OF", "Forum", containerOf['Forum.id'], "Message", containerOf['Post.id'])
end

for i, hasCreator in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/post_hasCreator_person_0_0.csv", "|") do
    RelationshipAdd("HAS_CREATOR", "Message", hasCreator['Post.id'], "Person", hasCreator['Person.id'])
end

for i, hasCreator in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/comment_hasCreator_person_0_0.csv", "|") do
    RelationshipAdd("HAS_CREATOR", "Message", hasCreator['Comment.id'], "Person", hasCreator['Person.id'])
end

for i, isLocatedIn in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_isLocatedIn_place_0_0.csv", "|") do
    RelationshipAdd("IS_LOCATED_IN", "Person", isLocatedIn['Person.id'], "Place", isLocatedIn['Place.id'])
end

for i, isLocatedIn in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/organisation_isLocatedIn_place_0_0.csv", "|") do
    RelationshipAdd("IS_LOCATED_IN", "Organisation", isLocatedIn['Organisation.id'], "Place", isLocatedIn['Place.id'])
end

for i, isLocatedIn in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/comment_isLocatedIn_place_0_0.csv", "|") do
    RelationshipAdd("IS_LOCATED_IN", "Message", isLocatedIn['Comment.id'], "Place", isLocatedIn['Place.id'])
end

for i, isLocatedIn in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/post_isLocatedIn_place_0_0.csv", "|") do
    RelationshipAdd("IS_LOCATED_IN", "Message", isLocatedIn['Post.id'], "Place", isLocatedIn['Place.id'])
end

for i, knows in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_knows_person_0_0.csv", "|") do
    RelationshipAdd("KNOWS", "Person", knows['Person1.id'], "Person", knows['Person2.id'], "{\"creationDate\":".."\""..knows.creationDate.."\"}")
end

for i, hasInterest in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_hasInterest_tag_0_0.csv", "|") do
    RelationshipAdd("HAS_INTEREST", "Person", hasInterest['Person.id'], "Tag", hasInterest['Tag.id'])
end

for i, hasTag in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/forum_hasTag_tag_0_0.csv", "|") do
    RelationshipAdd("HAS_TAG", "Forum", hasTag['Forum.id'], "Tag", hasTag['Tag.id'])
end

for i, hasTag in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/comment_hasTag_tag_0_0.csv", "|") do
    RelationshipAdd("HAS_TAG", "Message", hasTag['Comment.id'], "Tag", hasTag['Tag.id'])
end

for i, hasTag in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/post_hasTag_tag_0_0.csv", "|") do
    RelationshipAdd("HAS_TAG", "Message", hasTag['Post.id'], "Tag", hasTag['Tag.id'])
end

for i, hasModerator in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/forum_hasModerator_person_0_0.csv", "|") do
    RelationshipAdd("HAS_MODERATOR", "Forum", hasModerator['Forum.id'], "Person", hasModerator['Person.id'])
end

for i, hasMember in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/forum_hasMember_person_0_0.csv", "|") do
    RelationshipAdd("HAS_MEMBER", "Forum", hasMember['Forum.id'], "Person", hasMember['Person.id'], "{\"joinDate\":".."\""..hasMember.joinDate.."\"}")
end

for i, hasType in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/tag_hasType_tagclass_0_0.csv", "|") do
    RelationshipAdd("HAS_TYPE", "Tag", hasType['Tag.id'], "TagClass", hasType['TagClass.id'])
end

for i, isSubclassOf in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/tagclass_isSubclassOf_tagclass_0_0.csv", "|") do
    RelationshipAdd("IS_SUBCLASS_OF", "TagClass", isSubclassOf['TagClass1.id'], "TagClass", isSubclassOf['TagClass2.id'])
end

for i, studyAt in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_studyAt_organisation_0_0.csv", "|") do
    RelationshipAdd("STUDY_AT", "Person", studyAt['Person.id'], "Organisation", studyAt['Organisation.id'], "{\"classYear\":"..studyAt.classYear.."}")
end

for i, workAt in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_workAt_organisation_0_0.csv", "|") do
    RelationshipAdd("WORK_AT", "Person", workAt['Person.id'], "Organisation", workAt['Organisation.id'], "{\"workFrom\":"..workAt.workFrom.."}")
end

for i, likes in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_likes_comment_0_0.csv", "|") do
    RelationshipAdd("LIKES", "Person", likes['Person.id'], "Message", likes['Comment.id'], "{\"creationDate\":".."\""..likes.creationDate.."\"}")
end

for i, likes in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_likes_post_0_0.csv", "|") do
    RelationshipAdd("LIKES", "Person", likes['Person.id'], "Message", likes['Post.id'], "{\"creationDate\":".."\""..likes.creationDate.."\"}")
end

for i, isPartOf in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/place_isPartOf_place_0_0.csv", "|") do
    RelationshipAdd("IS_PART_OF", "Place", isPartOf['Place1.id'], "Place", isPartOf['Place2.id'])
end

local person_id = 0
local next_id = 0
local count
local emails = {}
for i, person in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_email_emailaddress_0_0.csv", "|") do
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
for i, person in ftcsv.parseLine("/home/max/CLionProjects/ldbc/sn-sf1/person_speaks_language_0_0.csv", "|") do
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