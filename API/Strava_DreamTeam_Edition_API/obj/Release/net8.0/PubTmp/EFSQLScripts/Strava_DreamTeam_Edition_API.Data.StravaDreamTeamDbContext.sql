IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111093626_Activity and ActivityCategories'
)
BEGIN
    CREATE TABLE [ActivityCategories] (
        [ID] uniqueidentifier NOT NULL,
        [Name] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_ActivityCategories] PRIMARY KEY ([ID])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111093626_Activity and ActivityCategories'
)
BEGIN
    CREATE TABLE [Activities] (
        [ID] uniqueidentifier NOT NULL,
        [Name] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NOT NULL,
        [LengthInKm] nvarchar(max) NOT NULL,
        [AuthorId] nvarchar(max) NOT NULL,
        [ActivityCategory] uniqueidentifier NOT NULL,
        [categoryID] uniqueidentifier NOT NULL,
        CONSTRAINT [PK_Activities] PRIMARY KEY ([ID]),
        CONSTRAINT [FK_Activities_ActivityCategories_categoryID] FOREIGN KEY ([categoryID]) REFERENCES [ActivityCategories] ([ID]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111093626_Activity and ActivityCategories'
)
BEGIN
    CREATE INDEX [IX_Activities_categoryID] ON [Activities] ([categoryID]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111093626_Activity and ActivityCategories'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260111093626_Activity and ActivityCategories', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111095931_Fix'
)
BEGIN
    ALTER TABLE [Activities] DROP CONSTRAINT [FK_Activities_ActivityCategories_categoryID];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111095931_Fix'
)
BEGIN
    DECLARE @var0 sysname;
    SELECT @var0 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Activities]') AND [c].[name] = N'ActivityCategory');
    IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Activities] DROP CONSTRAINT [' + @var0 + '];');
    ALTER TABLE [Activities] DROP COLUMN [ActivityCategory];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111095931_Fix'
)
BEGIN
    EXEC sp_rename N'[Activities].[categoryID]', N'CategoryId', N'COLUMN';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111095931_Fix'
)
BEGIN
    EXEC sp_rename N'[Activities].[IX_Activities_categoryID]', N'IX_Activities_CategoryId', N'INDEX';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111095931_Fix'
)
BEGIN
    ALTER TABLE [Activities] ADD CONSTRAINT [FK_Activities_ActivityCategories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [ActivityCategories] ([ID]) ON DELETE CASCADE;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111095931_Fix'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260111095931_Fix', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111102006_Changes of activity'
)
BEGIN
    DECLARE @var1 sysname;
    SELECT @var1 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Activities]') AND [c].[name] = N'LengthInKm');
    IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Activities] DROP CONSTRAINT [' + @var1 + '];');
    ALTER TABLE [Activities] ALTER COLUMN [LengthInKm] decimal(18,2) NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111102006_Changes of activity'
)
BEGIN
    ALTER TABLE [Activities] ADD [CreatedAt] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111102006_Changes of activity'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260111102006_Changes of activity', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223411_Creating Auth Database'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260111223411_Creating Auth Database', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260112170338_AddUserProfile'
)
BEGIN
    CREATE TABLE [UserProfiles] (
        [UserId] nvarchar(450) NOT NULL,
        [FirstName] nvarchar(max) NULL,
        [LastName] nvarchar(max) NULL,
        [BirthDate] datetime2 NULL,
        [Gender] nvarchar(max) NULL,
        [HeightCm] decimal(18,2) NULL,
        [WeightKg] decimal(18,2) NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_UserProfiles] PRIMARY KEY ([UserId])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260112170338_AddUserProfile'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260112170338_AddUserProfile', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155333_xyz'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'UserId', N'BirthDate', N'FirstName', N'Gender', N'HeightCm', N'LastName', N'UpdatedAt', N'WeightKg') AND [object_id] = OBJECT_ID(N'[UserProfiles]'))
        SET IDENTITY_INSERT [UserProfiles] ON;
    EXEC(N'INSERT INTO [UserProfiles] ([UserId], [BirthDate], [FirstName], [Gender], [HeightCm], [LastName], [UpdatedAt], [WeightKg])
    VALUES (N''10000000-0000-0000-0000-000000000002'', ''1994-02-10T00:00:00.0000000'', N''Jan'', N''M'', 178.0, N''Kowalski'', ''2026-01-13T15:53:32.8415702Z'', 76.0),
    (N''10000000-0000-0000-0000-000000000003'', ''1996-06-05T00:00:00.0000000'', N''Anna'', N''F'', 168.0, N''Nowak'', ''2026-01-13T15:53:32.8415705Z'', 60.0),
    (N''10000000-0000-0000-0000-000000000004'', ''1991-09-21T00:00:00.0000000'', N''Piotr'', N''M'', 182.0, N''Zieliński'', ''2026-01-13T15:53:32.8415707Z'', 83.0),
    (N''10000000-0000-0000-0000-000000000005'', ''1998-01-14T00:00:00.0000000'', N''Karolina'', N''F'', 165.0, N''Mazur'', ''2026-01-13T15:53:32.8415708Z'', 57.0),
    (N''10000000-0000-0000-0000-000000000006'', ''1990-11-03T00:00:00.0000000'', N''Marek'', N''M'', 180.0, N''Lewandowski'', ''2026-01-13T15:53:32.8415710Z'', 82.0)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'UserId', N'BirthDate', N'FirstName', N'Gender', N'HeightCm', N'LastName', N'UpdatedAt', N'WeightKg') AND [object_id] = OBJECT_ID(N'[UserProfiles]'))
        SET IDENTITY_INSERT [UserProfiles] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155333_xyz'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260113155333_xyz', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    ALTER TABLE [Activities] ADD [ActiveSeconds] int NOT NULL DEFAULT 0;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    ALTER TABLE [Activities] ADD [FinishedAt] datetime2 NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    ALTER TABLE [Activities] ADD [StartedAt] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    ALTER TABLE [Activities] ADD [Status] int NOT NULL DEFAULT 0;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    CREATE TABLE [activityGpsPoints] (
        [Id] uniqueidentifier NOT NULL,
        [ActivityId] uniqueidentifier NOT NULL,
        [Latitude] float NOT NULL,
        [Longitude] float NOT NULL,
        [Timestamp] datetime2 NOT NULL,
        CONSTRAINT [PK_activityGpsPoints] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_activityGpsPoints_Activities_ActivityId] FOREIGN KEY ([ActivityId]) REFERENCES [Activities] ([ID]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    CREATE TABLE [FriendRelations] (
        [Id] uniqueidentifier NOT NULL,
        [UserId] nvarchar(450) NOT NULL,
        [OtherUserId] nvarchar(450) NOT NULL,
        [Status] int NOT NULL,
        [InitiatorUserId] nvarchar(max) NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_FriendRelations] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ID', N'Name') AND [object_id] = OBJECT_ID(N'[ActivityCategories]'))
        SET IDENTITY_INSERT [ActivityCategories] ON;
    EXEC(N'INSERT INTO [ActivityCategories] ([ID], [Name])
    VALUES (''11111111-1111-1111-1111-111111111111'', N''Bieg''),
    (''22222222-2222-2222-2222-222222222222'', N''Rower''),
    (''33333333-3333-3333-3333-333333333333'', N''Spacer''),
    (''44444444-4444-4444-4444-444444444444'', N''Hiking''),
    (''55555555-5555-5555-5555-555555555555'', N''Trening siłowy'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ID', N'Name') AND [object_id] = OBJECT_ID(N'[ActivityCategories]'))
        SET IDENTITY_INSERT [ActivityCategories] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:42:34.4806648Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:42:34.4806652Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:42:34.4806653Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:42:34.4806655Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:42:34.4806656Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    CREATE INDEX [IX_activityGpsPoints_ActivityId] ON [activityGpsPoints] ([ActivityId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    CREATE UNIQUE INDEX [IX_FriendRelations_UserId_OtherUserId] ON [FriendRelations] ([UserId], [OtherUserId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113164234_xyz1'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260113164234_xyz1', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'CreatedAt', N'InitiatorUserId', N'OtherUserId', N'Status', N'UpdatedAt', N'UserId') AND [object_id] = OBJECT_ID(N'[FriendRelations]'))
        SET IDENTITY_INSERT [FriendRelations] ON;
    EXEC(N'INSERT INTO [FriendRelations] ([Id], [CreatedAt], [InitiatorUserId], [OtherUserId], [Status], [UpdatedAt], [UserId])
    VALUES (''90000000-0000-0000-0000-000000000001'', ''2025-12-20T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000002'', N''10000000-0000-0000-0000-000000000003'', 1, ''2025-12-21T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000002''),
    (''90000000-0000-0000-0000-000000000002'', ''2025-12-20T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000002'', N''10000000-0000-0000-0000-000000000002'', 1, ''2025-12-21T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000003''),
    (''90000000-0000-0000-0000-000000000003'', ''2025-12-25T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000004'', N''10000000-0000-0000-0000-000000000004'', 1, ''2025-12-26T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000002''),
    (''90000000-0000-0000-0000-000000000004'', ''2025-12-25T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000004'', N''10000000-0000-0000-0000-000000000002'', 1, ''2025-12-26T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000004''),
    (''90000000-0000-0000-0000-000000000005'', ''2026-01-10T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000003'', N''10000000-0000-0000-0000-000000000005'', 0, NULL, N''10000000-0000-0000-0000-000000000003''),
    (''90000000-0000-0000-0000-000000000006'', ''2026-01-10T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000003'', N''10000000-0000-0000-0000-000000000003'', 0, NULL, N''10000000-0000-0000-0000-000000000005''),
    (''90000000-0000-0000-0000-000000000007'', ''2026-01-11T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000006'', N''10000000-0000-0000-0000-000000000002'', 0, NULL, N''10000000-0000-0000-0000-000000000006''),
    (''90000000-0000-0000-0000-000000000008'', ''2026-01-11T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000006'', N''10000000-0000-0000-0000-000000000006'', 0, NULL, N''10000000-0000-0000-0000-000000000002''),
    (''90000000-0000-0000-0000-000000000009'', ''2026-01-05T12:00:00.0000000Z'', N''10000000-0000-0000-0000-000000000004'', N''10000000-0000-0000-0000-000000000005'', 2, NULL, N''10000000-0000-0000-0000-000000000004'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'CreatedAt', N'InitiatorUserId', N'OtherUserId', N'Status', N'UpdatedAt', N'UserId') AND [object_id] = OBJECT_ID(N'[FriendRelations]'))
        SET IDENTITY_INSERT [FriendRelations] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:50:17.1499433Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:50:17.1499435Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:50:17.1499437Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:50:17.1499438Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:50:17.1499440Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165017_SeedFriendRelations'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260113165017_SeedFriendRelations', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ID', N'ActiveSeconds', N'AuthorId', N'CategoryId', N'CreatedAt', N'Description', N'FinishedAt', N'LengthInKm', N'Name', N'StartedAt', N'Status') AND [object_id] = OBJECT_ID(N'[Activities]'))
        SET IDENTITY_INSERT [Activities] ON;
    EXEC(N'INSERT INTO [Activities] ([ID], [ActiveSeconds], [AuthorId], [CategoryId], [CreatedAt], [Description], [FinishedAt], [LengthInKm], [Name], [StartedAt], [Status])
    VALUES (''a1000000-0000-0000-0000-000000000001'', 0, N''10000000-0000-0000-0000-000000000002'', ''11111111-1111-1111-1111-111111111111'', ''2025-12-20T12:00:00.0000000Z'', N''Lekki bieg przed pracą'', NULL, 5.2, N''Poranny bieg'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a1000000-0000-0000-0000-000000000002'', 0, N''10000000-0000-0000-0000-000000000002'', ''22222222-2222-2222-2222-222222222222'', ''2025-12-21T12:00:00.0000000Z'', N''Rower – interwały'', NULL, 22.4, N''Trening rowerowy'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a2000000-0000-0000-0000-000000000001'', 0, N''10000000-0000-0000-0000-000000000003'', ''33333333-3333-3333-3333-333333333333'', ''2025-12-25T12:00:00.0000000Z'', N''Spokojny spacer po parku'', NULL, 3.1, N''Spacer z psem'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a2000000-0000-0000-0000-000000000002'', 0, N''10000000-0000-0000-0000-000000000003'', ''11111111-1111-1111-1111-111111111111'', ''2025-12-26T12:00:00.0000000Z'', N''Tempo progowe'', NULL, 6.8, N''Bieg wieczorny'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a3000000-0000-0000-0000-000000000001'', 0, N''10000000-0000-0000-0000-000000000004'', ''44444444-4444-4444-4444-444444444444'', ''2026-01-05T12:00:00.0000000Z'', N''Tatry – Dolina Kościeliska'', NULL, 12.5, N''Hiking w górach'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a4000000-0000-0000-0000-000000000001'', 0, N''10000000-0000-0000-0000-000000000005'', ''55555555-5555-5555-5555-555555555555'', ''2026-01-10T12:00:00.0000000Z'', N''Siłownia – całe ciało'', NULL, 0.0, N''Trening siłowy – FBW'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a5000000-0000-0000-0000-000000000001'', 0, N''10000000-0000-0000-0000-000000000006'', ''11111111-1111-1111-1111-111111111111'', ''2026-01-11T12:00:00.0000000Z'', N''Bieg tlenowy'', NULL, 14.3, N''Długi bieg'', ''0001-01-01T00:00:00.0000000'', 0),
    (''a5000000-0000-0000-0000-000000000002'', 0, N''10000000-0000-0000-0000-000000000006'', ''22222222-2222-2222-2222-222222222222'', ''2026-01-10T12:00:00.0000000Z'', N''Trasa wiejska'', NULL, 35.0, N''Rower szosowy'', ''0001-01-01T00:00:00.0000000'', 0)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ID', N'ActiveSeconds', N'AuthorId', N'CategoryId', N'CreatedAt', N'Description', N'FinishedAt', N'LengthInKm', N'Name', N'StartedAt', N'Status') AND [object_id] = OBJECT_ID(N'[Activities]'))
        SET IDENTITY_INSERT [Activities] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:54:48.6982595Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:54:48.6982600Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:54:48.6982601Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:54:48.6982603Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-13T16:54:48.6982604Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113165448_activitesseed'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260113165448_activitesseed', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    ALTER TABLE [Activities] ADD [PaceMinPerKm] decimal(18,2) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    ALTER TABLE [Activities] ADD [SpeedKmPerHour] decimal(18,2) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a1000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a1000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a2000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a2000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a3000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a4000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a5000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PaceMinPerKm] = NULL, [SpeedKmPerHour] = NULL
    WHERE [ID] = ''a5000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-14T15:52:35.5161417Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-14T15:52:35.5161420Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-14T15:52:35.5161422Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-14T15:52:35.5161423Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-14T15:52:35.5161425Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260114155236_SpeedAndTempo'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260114155236_SpeedAndTempo', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    ALTER TABLE [Activities] ADD [PhotoUrl1] nvarchar(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    ALTER TABLE [Activities] ADD [PhotoUrl2] nvarchar(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a1000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a1000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a2000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a2000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a3000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a4000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a5000000-0000-0000-0000-000000000001'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [Activities] SET [PhotoUrl1] = NULL, [PhotoUrl2] = NULL
    WHERE [ID] = ''a5000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T14:18:44.5452518Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T14:18:44.5452521Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T14:18:44.5452522Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T14:18:44.5452524Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T14:18:44.5452526Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115141845_addactivityphotos'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260115141845_addactivityphotos', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115154814_AddAvatarToUserProfile1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T15:48:14.5003608Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115154814_AddAvatarToUserProfile1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T15:48:14.5003612Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115154814_AddAvatarToUserProfile1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T15:48:14.5003614Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115154814_AddAvatarToUserProfile1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T15:48:14.5003615Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115154814_AddAvatarToUserProfile1'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T15:48:14.5003617Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115154814_AddAvatarToUserProfile1'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260115154814_AddAvatarToUserProfile1', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115170112_AddAvatarToUserProfile2'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T17:01:11.7295361Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000002'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115170112_AddAvatarToUserProfile2'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T17:01:11.7295363Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000003'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115170112_AddAvatarToUserProfile2'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T17:01:11.7295365Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000004'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115170112_AddAvatarToUserProfile2'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T17:01:11.7295367Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000005'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115170112_AddAvatarToUserProfile2'
)
BEGIN
    EXEC(N'UPDATE [UserProfiles] SET [UpdatedAt] = ''2026-01-15T17:01:11.7295368Z''
    WHERE [UserId] = N''10000000-0000-0000-0000-000000000006'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115170112_AddAvatarToUserProfile2'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260115170112_AddAvatarToUserProfile2', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115171723_AddAvatarToUserProfile3'
)
BEGIN
    ALTER TABLE [UserProfiles] ADD [Avatar] varbinary(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115171723_AddAvatarToUserProfile3'
)
BEGIN
    ALTER TABLE [UserProfiles] ADD [AvatarContentType] nvarchar(100) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115171723_AddAvatarToUserProfile3'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260115171723_AddAvatarToUserProfile3', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115194819_RemoveActivityPhotoUrls'
)
BEGIN
    DECLARE @var2 sysname;
    SELECT @var2 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Activities]') AND [c].[name] = N'PhotoUrl1');
    IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Activities] DROP CONSTRAINT [' + @var2 + '];');
    ALTER TABLE [Activities] DROP COLUMN [PhotoUrl1];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115194819_RemoveActivityPhotoUrls'
)
BEGIN
    DECLARE @var3 sysname;
    SELECT @var3 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Activities]') AND [c].[name] = N'PhotoUrl2');
    IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Activities] DROP CONSTRAINT [' + @var3 + '];');
    ALTER TABLE [Activities] DROP COLUMN [PhotoUrl2];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115194819_RemoveActivityPhotoUrls'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260115194819_RemoveActivityPhotoUrls', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115202704_AddActivityPhotosBlob'
)
BEGIN
    ALTER TABLE [Activities] ADD [Photo1] varbinary(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115202704_AddActivityPhotosBlob'
)
BEGIN
    ALTER TABLE [Activities] ADD [Photo1ContentType] nvarchar(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115202704_AddActivityPhotosBlob'
)
BEGIN
    ALTER TABLE [Activities] ADD [Photo2] varbinary(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115202704_AddActivityPhotosBlob'
)
BEGIN
    ALTER TABLE [Activities] ADD [Photo2ContentType] nvarchar(max) NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260115202704_AddActivityPhotosBlob'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260115202704_AddActivityPhotosBlob', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116004319_AddActivityCommentsAndLikes'
)
BEGIN
    CREATE TABLE [ActivityComments] (
        [Id] uniqueidentifier NOT NULL,
        [ActivityId] uniqueidentifier NOT NULL,
        [AuthorId] nvarchar(max) NOT NULL,
        [Content] nvarchar(max) NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_ActivityComments] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_ActivityComments_Activities_ActivityId] FOREIGN KEY ([ActivityId]) REFERENCES [Activities] ([ID]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116004319_AddActivityCommentsAndLikes'
)
BEGIN
    CREATE TABLE [ActivityLikes] (
        [Id] uniqueidentifier NOT NULL,
        [ActivityId] uniqueidentifier NOT NULL,
        [UserId] nvarchar(450) NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_ActivityLikes] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_ActivityLikes_Activities_ActivityId] FOREIGN KEY ([ActivityId]) REFERENCES [Activities] ([ID]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116004319_AddActivityCommentsAndLikes'
)
BEGIN
    CREATE INDEX [IX_ActivityComments_ActivityId] ON [ActivityComments] ([ActivityId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116004319_AddActivityCommentsAndLikes'
)
BEGIN
    CREATE UNIQUE INDEX [IX_ActivityLikes_ActivityId_UserId] ON [ActivityLikes] ([ActivityId], [UserId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116004319_AddActivityCommentsAndLikes'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260116004319_AddActivityCommentsAndLikes', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116165824_RenameActivityPhotosToUseAndMap'
)
BEGIN
    EXEC sp_rename N'[Activities].[Photo2ContentType]', N'UsePhotoContentType', N'COLUMN';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116165824_RenameActivityPhotosToUseAndMap'
)
BEGIN
    EXEC sp_rename N'[Activities].[Photo2]', N'UsePhoto', N'COLUMN';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116165824_RenameActivityPhotosToUseAndMap'
)
BEGIN
    EXEC sp_rename N'[Activities].[Photo1ContentType]', N'MapPhotoContentType', N'COLUMN';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116165824_RenameActivityPhotosToUseAndMap'
)
BEGIN
    EXEC sp_rename N'[Activities].[Photo1]', N'MapPhoto', N'COLUMN';
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260116165824_RenameActivityPhotosToUseAndMap'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260116165824_RenameActivityPhotosToUseAndMap', N'8.0.0');
END;
GO

COMMIT;
GO

