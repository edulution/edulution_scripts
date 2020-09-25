# Preprocessing of topics

# Get topics from content nodes
# Then get full contentnode information joined to channel metadata
get_topics  <- function(contentnodes, channelmetadata){
  topics <- contentnodes %>%
  filter(
    kind == 'topic',
    id != channel_id) %>%
  rename(
    # Rename the content_id to topic_id
    topic_id = id,
    # Rename the title of the node to topic_title
    topic_title = title) %>%
  select(
    # Select the topic_id, topic_title, and channel_id
    topic_id,
    topic_title,
    channel_id) %>%
  # Create a column called channel_topic 
  # consists of channel_id and topic_id separated by underscore
  mutate(channel_topic = paste0(channel_id,"_",topic_id))

  # Join contentnodes and channelmetadata to topics
  topics_full <- contentnodes %>%
  left_join(
    topics,
    c("parent_id"="topic_id","channel_id")) %>%
  left_join(
    # Join to channel_metadata
    channel_metadata,
    c("channel_id"="id")) %>%
  rename(
    # Rename the name column from channel_meta to channel_name
    channel_name = name
  ) %>%
  select(
    content_id,
    channel_id,
    content_title = title,
    kind,
    topic_id = parent_id,
    topic_title
  )

  return(topics_full)
}


# Count of contentnodes for each topic and content kind
get_topic_nodes_count  <- function(topics){
  topic_nodes_count <- topics %>%
  filter(
    kind != 'topic',
    content_id != channel_id) %>%
  count(channel_id, topic_id,kind, name = "nodes_count") %>%
  unite(
    "channel_topic_kind",
    c("channel_id","topic_id","kind"),
    sep = "_",
    remove = F)
}

topics  <- get_topics(channel_contents, channel_metadata)
topic_nodes_count  <- get_topic_nodes_count(topics)