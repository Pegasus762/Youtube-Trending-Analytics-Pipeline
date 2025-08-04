CREATE TABLE trending_videos (
    id NVARCHAR(50),
    title NVARCHAR(255),
    channel_title NVARCHAR(255),
    published_at DATETIME,
    view_count BIGINT,
    like_count BIGINT,
    comment_count BIGINT
); 