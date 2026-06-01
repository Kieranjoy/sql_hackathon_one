USE DATABASE sql_hackathon;
USE SCHEMA linkedin;

WITH engagement_stats as (
SELECT
ts.organization_entity
,TO_DATE(ts.day) as day
,SUM(ts.engagement) as engagement
,SUM(ts.unique_impressions_count) as unique_impressions_count
,SUM(ts.share_count) as share_count
,SUM(ts.click_count) as click_count
,SUM(ts.like_count) as like_count
,SUM(ts.impression_count) as impression_count
,SUM(ts.comment_count) as comment_count
,SUM(tf.follower_gains_organic_follower_gain) as follower_gains_organic_follower_gain
FROM time_bound_share_statistic as ts
JOIN time_bound_follower_statistic as tf
ON (ts.ORGANIZATION_ENTITY=tf.organization_entity
AND ts.day = tf.day)
GROUP BY 1,2
ORDER BY organization_entity ASC, day ASC
)
SELECT
u.id as post_id
,TO_DATE(u.first_published_at) as publish_date
,o.localized_name as post_author
,p.media_title
,es.* EXCLUDE (organization_entity)
FROM ugc_post_history as u
JOIN engagement_stats as es
ON u.author = es.organization_entity
AND publish_date<=es.day
JOIN post_content as p
ON u.id = p.post_id
JOIN organization as o
ON o.id = (SPLIT_PART(u.author,':',4))
WHERE p.media_title IS NOT NULL
QUALIFY (ROW_NUMBER() OVER (PARTITION BY es.day ORDER BY publish_date DESC)) = 1
ORDER BY publish_date ASC, es.day ASC;