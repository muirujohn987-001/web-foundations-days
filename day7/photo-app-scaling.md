# SnapShare: Scaling Plan

## 1. Assumptions and Traffic Estimates

SnapShare is a photo-sharing application where users upload photos and view feeds containing photos from people they follow.

### Given information

- Registered users: 10,000,000
- Daily active users: 10% of registered users
- Uploads per active user: 1 photo per day
- Feed views per active user: 50 pages per day
- Average original photo size: 2 MB
- Average thumbnail size: 50 KB
- Time period: 365 days per year
- Peak traffic: 5 times average traffic

### Daily active users

Daily active users (DAU) are calculated as:

10,000,000 × 10% = 1,000,000 daily active users.

Therefore, SnapShare has an estimated **1 million daily active users**.

### Uploads per second

Each daily active user uploads one photo per day.

Daily uploads = 1,000,000 × 1 = 1,000,000 photos per day.

Average uploads per second:

1,000,000 ÷ 86,400 = approximately 11.57 uploads per second.

Therefore, SnapShare should handle approximately **12 photo uploads per second on average**.

Peak uploads per second, assuming peak traffic is five times the average:

11.57 × 5 = approximately 57.87 uploads per second.

The system should be designed to handle at least 58 uploads per second during peak periods, with additional capacity for unexpected spikes.

### Feed views per second

Each daily active user views 50 feed pages per day.

Daily feed views = 1,000,000 × 50 = 50,000,000 feed views per day.

Average feed views per second:

50,000,000 ÷ 86,400 = approximately 578.70 feed views per second.

Peak feed views per second:

578.70 × 5 = approximately 2,893.52 feed views per second.

Therefore, SnapShare should handle approximately **579 feed views per second on average and 2,894 per second at peak**.

These figures represent feed-page requests, not the individual photo requests generated when users load images.

### Photo storage per year

Each day, users upload one million original photos.

Daily original-photo storage:

1,000,000 × 2 MB = 2,000,000 MB per day, or approximately 2 TB per day using decimal units.

Annual original-photo storage:

2 TB × 365 = approximately 730 TB per year.

Thumbnails also consume storage:

1,000,000 × 50 KB = approximately 50 GB per day.

Annual thumbnail storage:

50 GB × 365 = approximately 18.25 TB per year.

Therefore, the application needs approximately **730 TB of additional original-photo storage per year**, plus approximately 18.25 TB for thumbnails.

The combined total is approximately 748.25 TB per year, excluding database data, backups, replicas and other overhead.

These estimates assume that every uploaded photo is retained for the entire year, each active user uploads exactly one photo daily, and the average file sizes remain constant. Actual storage requirements may differ.

## 2. Is SnapShare Read-Heavy or Write-Heavy?

SnapShare is primarily a **read-heavy system**.

Users generate approximately 50 million feed views daily but only one million photo uploads daily. This produces a ratio of approximately 50 feed views for every upload.

A feed view can also generate several additional requests for photos, thumbnails and other information.

This means the system must efficiently serve large numbers of read requests while still accepting uploads reliably.

To support this workload, SnapShare should use a content delivery network (CDN) to serve photos and thumbnails close to users, a cache to reduce repeated database queries, and a database read replica to handle additional read traffic. Application servers should also scale horizontally when demand increases.

## 3. Why Photos Should Not Be Stored Inside the Database

Original photos and thumbnails should be stored in object storage rather than directly inside the relational database.

Photo files are large binary objects, and storing hundreds of terabytes in the database would increase its storage requirements, backup costs and operational complexity.

The database should instead store metadata such as the photo ID, owner ID, object-storage key, upload timestamp, visibility settings and thumbnail status.

Object storage holds the original images and generated thumbnails. The application retrieves their locations from the database and serves the images through the CDN.

This separation allows the database to focus on structured information while object storage handles large files efficiently.

## 4. Proposed Architecture Diagram

```text
                         USERS
                           |
              +------------+------------+
              |                         |
              v                         v
       Application/API             Photo Requests
          Requests                       |
              |                          v
              v                    +-----------+
       +---------------+            |    CDN    |
       | Load Balancer |            +-----------+
       +---------------+                  |
              |                           v
              v                    Object Storage
       +---------------+            +-----------+
       | App Servers   |----------->| Originals |
       | (Multiple)    |            | Thumbnails|
       +---------------+            +-----------+
          |       |
          |       +--------------------------+
          |                                  |
          v                                  v
    +-----------+                     +---------------+
    |   Cache   |                     | Message Queue |
    +-----------+                     +---------------+
          |                                  |
          v                                  v
    +----------------+               +---------------+
    | Primary        |               | Thumbnail     |
    | Database       |               | Worker        |
    +----------------+               +---------------+
          |
          v
    +----------------+
    | Read Replica   |
    +----------------+
```

The diagram shows the main services and their responsibilities. In a production implementation, the application servers would access the primary database for writes and the read replica for suitable read queries. The thumbnail worker would consume jobs from the queue and save generated thumbnails to object storage.

## 5. Components and the Problems They Solve

### Users
Users upload photos and request feeds, creating the traffic the application must handle.

### Load Balancer
The load balancer distributes incoming application requests across multiple app servers so that one server does not become a bottleneck.

### App Servers
The app servers handle authentication, upload authorization, feed generation, metadata updates and other application logic, and can scale horizontally as traffic increases.

### Cache
The cache stores frequently requested information, such as feed data and photo metadata, so the application can reduce repeated database queries and respond faster.

### Primary Database
The primary database stores structured information such as users, relationships, photo metadata, permissions and upload status while maintaining data integrity.

### Database Read Replica
The read replica handles suitable read queries separately from the primary database, reducing the primary database's workload.

### Object Storage
Object storage holds the original photo files and generated thumbnails without placing large binary files directly inside the database.

### Content Delivery Network (CDN)
The CDN caches and serves photos and thumbnails from locations closer to users, reducing latency and the amount of image traffic reaching the origin storage.

### Message Queue
The queue stores thumbnail-generation jobs so that image processing can happen asynchronously without forcing users to wait for it to finish.

### Thumbnail Worker
The worker retrieves queued jobs, creates smaller versions of uploaded photos, saves them to object storage and updates the thumbnail status in the database.

## 6. Step-by-Step Photo Upload Flow

1. **User selects a photo:** The user chooses a photo and submits it through the SnapShare application.

2. **Request reaches the load balancer:** The load balancer routes the upload request to a healthy application server.

3. **Application validates the request:** The app server authenticates the user and checks the file type, file size and upload permissions.

4. **Application prepares the upload:** The application creates a photo record or upload record and determines the object-storage location. Depending on the design, it can issue a short-lived, authorized upload URL so the client uploads directly to object storage.

5. **Original photo is uploaded:** The client uploads the photo to object storage, avoiding the need to route the entire file through the application servers when direct uploads are supported.

6. **Upload is confirmed:** The application verifies that the upload succeeded and updates the photo metadata and upload status in the database.

7. **Thumbnail job is queued:** The application publishes a thumbnail-generation job to the message queue.

8. **Worker processes the job:** A thumbnail worker consumes the job and downloads or reads the original photo from object storage.

9. **Thumbnail is generated:** The worker resizes the original photo to create a smaller thumbnail and uploads it to object storage.

10. **Metadata is updated:** The worker records the thumbnail location and marks thumbnail processing as complete in the database.

11. **Photo becomes available:** The application makes the photo available according to its visibility settings, and users can retrieve the image or thumbnail through the CDN.

If thumbnail processing fails, the job can be retried and the application can track the pending or failed processing status.

## 7. Trade-Offs

### Trade-Off 1: Eventual Consistency Versus Immediate Availability

Using a message queue to generate thumbnails asynchronously improves upload responsiveness because users do not need to wait for image processing to finish.

However, a thumbnail might not be available immediately after the original upload. The application must handle pending thumbnail status and possible processing failures.

### Trade-Off 2: Cache Performance Versus Data Freshness

Caching feed data and metadata reduces database load and improves response times.

However, cached information can become outdated when a user uploads a photo, changes visibility settings or deletes content. The application must use cache expiration, invalidation or versioning to prevent users from seeing stale or unauthorized information.

### Trade-Off 3: Read Replicas Versus Read Consistency

A read replica allows the database to serve more read requests without sending every query to the primary database.

However, replication can introduce a delay before new changes appear on the replica. A user might upload a photo and not immediately see it in a feed served from the replica. The application can address this by briefly reading recent changes from the primary database or using another read-after-write strategy.

### Trade-Off 4: CDN Performance Versus Storage and Invalidation Complexity

A CDN reduces image delivery latency and lowers the load on origin storage.

However, cached images may remain available after an update or deletion unless the cache is invalidated or the system uses appropriate cache-control rules and versioned object URLs. Private photos also require appropriate access controls, such as short-lived signed URLs or authenticated delivery.

## Conclusion

SnapShare should use horizontally scalable application servers, a cache, a primary database with a read replica, object storage, a CDN and asynchronous thumbnail processing.

The workload is read-heavy because feed views substantially outnumber uploads. Separating photo files from metadata, caching frequently requested content and processing thumbnails asynchronously allows the system to handle high traffic while keeping database operations manageable.
