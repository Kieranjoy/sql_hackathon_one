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
ON (ts.organization_entity=tf.organization_entity
AND ts.day = tf.day)
WHERE (SPLIT_PART(ts.organization_entity,':',4)) = 79414052
GROUP BY 1,2
ORDER BY organization_entity ASC, day ASC
)
SELECT
u.id AS post_id,
CASE WHEN es.day = TO_DATE(u.first_published_at) THEN TO_DATE(u.first_published_at) END AS first_publish_date
,p.media_title
,p.type
,o.localized_name
,es.*
FROM engagement_stats as es
LEFT JOIN ugc_post_history as u
ON u.author = es.organization_entity
AND TO_DATE(u.first_published_at) = es.day
LEFT JOIN post_content as p
ON u.id = p.post_id
LEFT JOIN organization as o
ON o.id = (SPLIT_PART(es.organization_entity,':',4))
ORDER BY es.day ASC, o.localized_name ASC;