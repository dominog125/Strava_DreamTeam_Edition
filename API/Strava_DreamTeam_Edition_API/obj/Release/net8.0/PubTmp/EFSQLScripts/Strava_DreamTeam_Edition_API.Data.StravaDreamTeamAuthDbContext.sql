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
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetRoles] (
        [Id] nvarchar(450) NOT NULL,
        [Name] nvarchar(256) NULL,
        [NormalizedName] nvarchar(256) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetUsers] (
        [Id] nvarchar(450) NOT NULL,
        [UserName] nvarchar(256) NULL,
        [NormalizedUserName] nvarchar(256) NULL,
        [Email] nvarchar(256) NULL,
        [NormalizedEmail] nvarchar(256) NULL,
        [EmailConfirmed] bit NOT NULL,
        [PasswordHash] nvarchar(max) NULL,
        [SecurityStamp] nvarchar(max) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        [PhoneNumber] nvarchar(max) NULL,
        [PhoneNumberConfirmed] bit NOT NULL,
        [TwoFactorEnabled] bit NOT NULL,
        [LockoutEnd] datetimeoffset NULL,
        [LockoutEnabled] bit NOT NULL,
        [AccessFailedCount] int NOT NULL,
        CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetRoleClaims] (
        [Id] int NOT NULL IDENTITY,
        [RoleId] nvarchar(450) NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetUserClaims] (
        [Id] int NOT NULL IDENTITY,
        [UserId] nvarchar(450) NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetUserLogins] (
        [LoginProvider] nvarchar(450) NOT NULL,
        [ProviderKey] nvarchar(450) NOT NULL,
        [ProviderDisplayName] nvarchar(max) NULL,
        [UserId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
        CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetUserRoles] (
        [UserId] nvarchar(450) NOT NULL,
        [RoleId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
        CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE TABLE [AspNetUserTokens] (
        [UserId] nvarchar(450) NOT NULL,
        [LoginProvider] nvarchar(450) NOT NULL,
        [Name] nvarchar(450) NOT NULL,
        [Value] nvarchar(max) NULL,
        CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'ConcurrencyStamp', N'Name', N'NormalizedName') AND [object_id] = OBJECT_ID(N'[AspNetRoles]'))
        SET IDENTITY_INSERT [AspNetRoles] ON;
    EXEC(N'INSERT INTO [AspNetRoles] ([Id], [ConcurrencyStamp], [Name], [NormalizedName])
    VALUES (N''c1a1f400-1d2b-4f5a-8b66-aaaaaaaaaaaa'', NULL, N''Admin'', N''ADMIN''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', NULL, N''User'', N''USER'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'ConcurrencyStamp', N'Name', N'NormalizedName') AND [object_id] = OBJECT_ID(N'[AspNetRoles]'))
        SET IDENTITY_INSERT [AspNetRoles] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'AccessFailedCount', N'ConcurrencyStamp', N'Email', N'EmailConfirmed', N'LockoutEnabled', N'LockoutEnd', N'NormalizedEmail', N'NormalizedUserName', N'PasswordHash', N'PhoneNumber', N'PhoneNumberConfirmed', N'SecurityStamp', N'TwoFactorEnabled', N'UserName') AND [object_id] = OBJECT_ID(N'[AspNetUsers]'))
        SET IDENTITY_INSERT [AspNetUsers] ON;
    EXEC(N'INSERT INTO [AspNetUsers] ([Id], [AccessFailedCount], [ConcurrencyStamp], [Email], [EmailConfirmed], [LockoutEnabled], [LockoutEnd], [NormalizedEmail], [NormalizedUserName], [PasswordHash], [PhoneNumber], [PhoneNumberConfirmed], [SecurityStamp], [TwoFactorEnabled], [UserName])
    VALUES (N''e3c3f622-3f4d-7h8c-0d88-cccccccccccc'', 0, N''873093df-2d14-400b-b2cf-b6ad61c21365'', N''admin@localhost'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''ADMIN@LOCALHOST'', N''ADMIN'', N''AQAAAAIAAYagAAAAEKsNThz+OaU8yDp1m/ni3/zlQum3nuA5wzpsxE57pxUbUVx2sYiSVN9FJoPoWDFQvQ=='', NULL, CAST(0 AS bit), N''14b92e80-0d5d-4145-9c1e-206eaf209c28'', CAST(0 AS bit), N''admin''),
    (N''f4d4g733-4h5e-9i0d-1e99-dddddddddddd'', 0, N''ff12d5b5-8f6a-41a2-add2-4c8c1e16ffb4'', N''user@localhost'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''USER@LOCALHOST'', N''USER'', N''AQAAAAIAAYagAAAAEIyNtGD2P5rAqTBiGWzL7hC70YSH855wgO7QZ5SDSO3164gKvaq5pb7IpOEZajHo/Q=='', NULL, CAST(0 AS bit), N''1ac58a5a-b780-49cd-af47-6d61787dc432'', CAST(0 AS bit), N''user'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'AccessFailedCount', N'ConcurrencyStamp', N'Email', N'EmailConfirmed', N'LockoutEnabled', N'LockoutEnd', N'NormalizedEmail', N'NormalizedUserName', N'PasswordHash', N'PhoneNumber', N'PhoneNumberConfirmed', N'SecurityStamp', N'TwoFactorEnabled', N'UserName') AND [object_id] = OBJECT_ID(N'[AspNetUsers]'))
        SET IDENTITY_INSERT [AspNetUsers] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'UserId') AND [object_id] = OBJECT_ID(N'[AspNetUserRoles]'))
        SET IDENTITY_INSERT [AspNetUserRoles] ON;
    EXEC(N'INSERT INTO [AspNetUserRoles] ([RoleId], [UserId])
    VALUES (N''c1a1f400-1d2b-4f5a-8b66-aaaaaaaaaaaa'', N''e3c3f622-3f4d-7h8c-0d88-cccccccccccc''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', N''f4d4g733-4h5e-9i0d-1e99-dddddddddddd'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'UserId') AND [object_id] = OBJECT_ID(N'[AspNetUserRoles]'))
        SET IDENTITY_INSERT [AspNetUserRoles] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260111223328_Creating Auth Database'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260111223328_Creating Auth Database', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    EXEC(N'DELETE FROM [AspNetUserRoles]
    WHERE [RoleId] = N''c1a1f400-1d2b-4f5a-8b66-aaaaaaaaaaaa'' AND [UserId] = N''e3c3f622-3f4d-7h8c-0d88-cccccccccccc'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    EXEC(N'DELETE FROM [AspNetUserRoles]
    WHERE [RoleId] = N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'' AND [UserId] = N''f4d4g733-4h5e-9i0d-1e99-dddddddddddd'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    EXEC(N'DELETE FROM [AspNetUsers]
    WHERE [Id] = N''e3c3f622-3f4d-7h8c-0d88-cccccccccccc'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    EXEC(N'DELETE FROM [AspNetUsers]
    WHERE [Id] = N''f4d4g733-4h5e-9i0d-1e99-dddddddddddd'';
    SELECT @@ROWCOUNT');
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'AccessFailedCount', N'ConcurrencyStamp', N'Email', N'EmailConfirmed', N'LockoutEnabled', N'LockoutEnd', N'NormalizedEmail', N'NormalizedUserName', N'PasswordHash', N'PhoneNumber', N'PhoneNumberConfirmed', N'SecurityStamp', N'TwoFactorEnabled', N'UserName') AND [object_id] = OBJECT_ID(N'[AspNetUsers]'))
        SET IDENTITY_INSERT [AspNetUsers] ON;
    EXEC(N'INSERT INTO [AspNetUsers] ([Id], [AccessFailedCount], [ConcurrencyStamp], [Email], [EmailConfirmed], [LockoutEnabled], [LockoutEnd], [NormalizedEmail], [NormalizedUserName], [PasswordHash], [PhoneNumber], [PhoneNumberConfirmed], [SecurityStamp], [TwoFactorEnabled], [UserName])
    VALUES (N''10000000-0000-0000-0000-000000000001'', 0, N''ef38c7fb-d588-4291-b507-0d42fc907d49'', N''admin@strava.local'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''ADMIN@STRAVA.LOCAL'', N''ADMIN'', N''AQAAAAIAAYagAAAAEDlNpcsiDugf2dIA0LfPK+DEYGmcNABoBLLD99i9s7hJuJnGuJfhuHylxTIneyVvUg=='', NULL, CAST(0 AS bit), N''814f9bec-fc78-4e3c-a498-dbe2fb13a856'', CAST(0 AS bit), N''admin''),
    (N''10000000-0000-0000-0000-000000000002'', 0, N''0761eb6d-8181-418f-b099-577c192b32df'', N''jan.kowalski@strava.local'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''JAN.KOWALSKI@STRAVA.LOCAL'', N''J.KOWALSKI'', N''AQAAAAIAAYagAAAAEFA8MLy5znP1EN67MAF05DFsRnkOw01jz9qz5fw+MgE5ro2bodmTBcSLF5TK4Jbv0Q=='', NULL, CAST(0 AS bit), N''eb3e8c3f-da12-4ec6-b960-ee7c83e399e7'', CAST(0 AS bit), N''j.kowalski''),
    (N''10000000-0000-0000-0000-000000000003'', 0, N''c45cb6a5-8ed0-4722-a18b-a8c5fd406e19'', N''anna.nowak@strava.local'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''ANNA.NOWAK@STRAVA.LOCAL'', N''A.NOWAK'', N''AQAAAAIAAYagAAAAEF+DBXexBZNqvU+bpH4cyYQBHefxSh6xPzShEJ5X8FlQ7VV57pYPR9NC4iECiKGfbA=='', NULL, CAST(0 AS bit), N''08cf3204-0cf8-464d-8356-3a0bf1473e3c'', CAST(0 AS bit), N''a.nowak''),
    (N''10000000-0000-0000-0000-000000000004'', 0, N''b2589b97-a111-4910-a3c0-5b3dd2283e25'', N''piotr.zielinski@strava.local'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''PIOTR.ZIELINSKI@STRAVA.LOCAL'', N''P.ZIELINSKI'', N''AQAAAAIAAYagAAAAEBeMDmqRex+X3vlGExuD4WFL/kDLqjj/ng9oS6gNINNoBzi3aONeCKp7zhmm822bCQ=='', NULL, CAST(0 AS bit), N''78f36b29-6739-400d-8690-a6813f4767b1'', CAST(0 AS bit), N''p.zielinski''),
    (N''10000000-0000-0000-0000-000000000005'', 0, N''b9d50b89-a193-4895-83d4-5e123e1c5451'', N''karolina.mazur@strava.local'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''KAROLINA.MAZUR@STRAVA.LOCAL'', N''K.MAZUR'', N''AQAAAAIAAYagAAAAEMashU2/m4/WYJkggMIO+xaxXwyHDTYbgAq2xfGVTSZBY6D/YxkMJZB80HFd6h8oTg=='', NULL, CAST(0 AS bit), N''7ed6e08d-ee02-4a31-b565-49cb6fc21760'', CAST(0 AS bit), N''k.mazur''),
    (N''10000000-0000-0000-0000-000000000006'', 0, N''98ef4618-3752-438e-bc40-5a18de084ca3'', N''marek.lewandowski@strava.local'', CAST(1 AS bit), CAST(0 AS bit), NULL, N''MAREK.LEWANDOWSKI@STRAVA.LOCAL'', N''M.LEWANDOWSKI'', N''AQAAAAIAAYagAAAAEDcJK5bO9eHDBdSQWP0bnIpEeYfCbIWJSUO6+gpksRtvy/oBkJ85uNm3MBubYXSE1Q=='', NULL, CAST(0 AS bit), N''2a9e1f43-a386-4bc2-85bd-207f8fd26485'', CAST(0 AS bit), N''m.lewandowski'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'AccessFailedCount', N'ConcurrencyStamp', N'Email', N'EmailConfirmed', N'LockoutEnabled', N'LockoutEnd', N'NormalizedEmail', N'NormalizedUserName', N'PasswordHash', N'PhoneNumber', N'PhoneNumberConfirmed', N'SecurityStamp', N'TwoFactorEnabled', N'UserName') AND [object_id] = OBJECT_ID(N'[AspNetUsers]'))
        SET IDENTITY_INSERT [AspNetUsers] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'UserId') AND [object_id] = OBJECT_ID(N'[AspNetUserRoles]'))
        SET IDENTITY_INSERT [AspNetUserRoles] ON;
    EXEC(N'INSERT INTO [AspNetUserRoles] ([RoleId], [UserId])
    VALUES (N''c1a1f400-1d2b-4f5a-8b66-aaaaaaaaaaaa'', N''10000000-0000-0000-0000-000000000001''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', N''10000000-0000-0000-0000-000000000002''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', N''10000000-0000-0000-0000-000000000003''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', N''10000000-0000-0000-0000-000000000004''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', N''10000000-0000-0000-0000-000000000005''),
    (N''d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb'', N''10000000-0000-0000-0000-000000000006'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'UserId') AND [object_id] = OBJECT_ID(N'[AspNetUserRoles]'))
        SET IDENTITY_INSERT [AspNetUserRoles] OFF;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260113155259_xyz'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260113155259_xyz', N'8.0.0');
END;
GO

COMMIT;
GO

