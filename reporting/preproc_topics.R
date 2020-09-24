# Preprocessing of topics
topics <- channel_contents %>%
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
contentnodes_topics <- channel_contents %>%
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

# Count of contentnodes for each topic and content kind
topic_nodes_count <- contentnodes_topics %>%
  filter(
    kind != 'topic',
    content_id != channel_id) %>%
  count(channel_id, topic_id,kind, name = "nodes_count") %>%
  unite(
    "channel_topic_kind",
    c("channel_id","topic_id","kind"),
    sep = "_",
    remove = F)