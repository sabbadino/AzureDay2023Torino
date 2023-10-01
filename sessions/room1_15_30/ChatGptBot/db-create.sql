USE [master]
GO
/****** Object:  Database [quick-amd-dirty-vector-database]    Script Date: 01/10/2023 10:01:44 ******/
CREATE DATABASE [quick-amd-dirty-vector-database]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'quick-amd-dirty-vector-database', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\quick-amd-dirty-vector-database.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'quick-amd-dirty-vector-database_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\quick-amd-dirty-vector-database_log.ldf' , SIZE = 335872KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [quick-amd-dirty-vector-database].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ARITHABORT OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET  DISABLE_BROKER 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET RECOVERY FULL 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET  MULTI_USER 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET DB_CHAINING OFF 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'quick-amd-dirty-vector-database', N'ON'
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET QUERY_STORE = OFF
GO
USE [quick-amd-dirty-vector-database]
GO
/****** Object:  UserDefinedTableType [dbo].[vector]    Script Date: 01/10/2023 10:01:44 ******/
CREATE TYPE [dbo].[vector] AS TABLE(
	[vectorOrder] [int] NOT NULL,
	[vectorvalue] [real] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[vectorOrder] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  Table [dbo].[ConversationHeader]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConversationHeader](
	[id] [uniqueidentifier] NOT NULL,
	[text] [varchar](8000) NOT NULL,
	[userName] [nvarchar](50) NULL,
 CONSTRAINT [PK_ConversationHeader] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConversationItemEmbeddings]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConversationItemEmbeddings](
	[id] [uniqueidentifier] NOT NULL,
	[conversationItemId] [uniqueidentifier] NOT NULL,
	[proximity] [real] NOT NULL,
	[embeddingId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ConversationItemEmbeddings] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConversationItems]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConversationItems](
	[id] [uniqueidentifier] NOT NULL,
	[conversationHeaderId] [uniqueidentifier] NOT NULL,
	[text] [nvarchar](4000) NOT NULL,
	[chatRole] [char](1) NOT NULL,
	[at] [datetimeoffset](7) NOT NULL,
	[tokens] [int] NOT NULL,
	[originaltext] [nvarchar](4000) NOT NULL,
	[originaltextlanguagecode] [varchar](6) NOT NULL,
	[userHasChangedTopic] [bit] NULL,
 CONSTRAINT [PK_ConversationItems] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Embeddings]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Embeddings](
	[id] [uniqueidentifier] NOT NULL,
	[text] [varchar](max) NOT NULL,
	[setId] [uniqueidentifier] NOT NULL,
	[textDescription] [varchar](100) NOT NULL,
	[tokens] [int] NOT NULL,
 CONSTRAINT [PK_Embeddings] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmbeddingsSet]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmbeddingsSet](
	[id] [uniqueidentifier] NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Description] [varchar](8000) NULL,
 CONSTRAINT [PK_EmbeddingsSet] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmbeddingVectors]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmbeddingVectors](
	[embeddingId] [uniqueidentifier] NOT NULL,
	[vectorValue] [real] NOT NULL,
	[vectorOrder] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_EmbeddingsSet_Code]    Script Date: 01/10/2023 10:01:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EmbeddingsSet_Code] ON [dbo].[EmbeddingsSet]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Embeddings] ADD  CONSTRAINT [DF_Embeddings_textDescription]  DEFAULT ('') FOR [textDescription]
GO
ALTER TABLE [dbo].[ConversationItemEmbeddings]  WITH CHECK ADD  CONSTRAINT [FK_ConversationItemEmbeddings_ConversationItemEmbeddings] FOREIGN KEY([id])
REFERENCES [dbo].[ConversationItemEmbeddings] ([id])
GO
ALTER TABLE [dbo].[ConversationItemEmbeddings] CHECK CONSTRAINT [FK_ConversationItemEmbeddings_ConversationItemEmbeddings]
GO
ALTER TABLE [dbo].[ConversationItemEmbeddings]  WITH CHECK ADD  CONSTRAINT [FK_ConversationItems_ConversationItemEmbeddings] FOREIGN KEY([conversationItemId])
REFERENCES [dbo].[ConversationItems] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ConversationItemEmbeddings] CHECK CONSTRAINT [FK_ConversationItems_ConversationItemEmbeddings]
GO
ALTER TABLE [dbo].[ConversationItemEmbeddings]  WITH CHECK ADD  CONSTRAINT [FK_Embeddings_ConversationItemEmbeddings] FOREIGN KEY([embeddingId])
REFERENCES [dbo].[Embeddings] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ConversationItemEmbeddings] CHECK CONSTRAINT [FK_Embeddings_ConversationItemEmbeddings]
GO
ALTER TABLE [dbo].[ConversationItems]  WITH CHECK ADD  CONSTRAINT [FK_ConversationIHeader_ConversationItems] FOREIGN KEY([conversationHeaderId])
REFERENCES [dbo].[ConversationHeader] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ConversationItems] CHECK CONSTRAINT [FK_ConversationIHeader_ConversationItems]
GO
ALTER TABLE [dbo].[Embeddings]  WITH CHECK ADD  CONSTRAINT [FK_EmbeddingsSet_Embeddings] FOREIGN KEY([setId])
REFERENCES [dbo].[EmbeddingsSet] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Embeddings] CHECK CONSTRAINT [FK_EmbeddingsSet_Embeddings]
GO
ALTER TABLE [dbo].[EmbeddingVectors]  WITH CHECK ADD  CONSTRAINT [FK_Embedding_EmbeddingVectors] FOREIGN KEY([embeddingId])
REFERENCES [dbo].[Embeddings] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmbeddingVectors] CHECK CONSTRAINT [FK_Embedding_EmbeddingVectors]
GO
/****** Object:  StoredProcedure [dbo].[GetRelevantDocuments]    Script Date: 01/10/2023 10:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetRelevantDocuments]
	@Code VARCHAR(50),  
	@threshold REAL,
	@maxItems INT,
	@v1 vector READONLY
AS
BEGIN
	DROP TABLE IF EXISTS #results;
SELECT TOP(@maxItems)
    v2.embeddingId, 
    cosine_distance = SUM(v1.[vectorvalue] * v2.[vectorvalue]) / 
        (
            SQRT(SUM(v1.[vectorvalue] * v1.[vectorvalue])) 
            * 
            SQRT(SUM(v2.[vectorvalue] * v2.[vectorvalue]))
        ) 
INTO
    #results
FROM 
    @v1 v1
INNER JOIN 
    dbo.EmbeddingVectors v2 ON v1.vectorOrder = v2.vectorOrder
INNER JOIN 
    dbo.Embeddings emb ON emb.id = v2.embeddingId
INNER JOIN 
    dbo.EmbeddingsSet embs ON embs.id = emb.setId
WHERE embs.Code = @Code
GROUP BY
    v2.embeddingId
HAVING SUM(v1.[vectorvalue] * v2.[vectorvalue]) / 
        (
            SQRT(SUM(v1.[vectorvalue] * v1.[vectorvalue])) 
            * 
            SQRT(SUM(v2.[vectorvalue] * v2.[vectorvalue]))
        ) > @threshold
ORDER BY
    cosine_distance DESC;

SELECT 
    a.id,
    CAST(r.cosine_distance AS REAL) AS cosine_distance
FROM 
    #results r
INNER JOIN 
    dbo.Embeddings a ON r.embeddingId = a.id
ORDER BY
    r.cosine_distance DESC;

END
GO
USE [master]
GO
ALTER DATABASE [quick-amd-dirty-vector-database] SET  READ_WRITE 
GO
