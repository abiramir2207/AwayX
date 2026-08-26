/*
Navicat SQL Server Data Transfer

Source Server         : DBSTAGE05
Source Server Version : 100000
Source Host           : 10.2.4.26:1433
Source Database       : DEV_V70
Source Schema         : dbo

Target Server Type    : SQL Server
Target Server Version : 100000
File Encoding         : 65001

Date: 2012-06-12 07:56:27
*/


-- ----------------------------
-- Table structure for [dbo].[Dashboard_Access]
-- ----------------------------
DROP TABLE [dbo].[Dashboard_Access]
GO
CREATE TABLE [dbo].[Dashboard_Access] (
[Dashboard_Access_ID] int NOT NULL IDENTITY(1,1) ,
[Profile_ID] int NOT NULL ,
[Budget] bit NULL DEFAULT ((0)) ,
[Billback] bit NULL DEFAULT ((0)) ,
[Sales] bit NULL DEFAULT ((0)) ,
[Created_Date] datetime NULL DEFAULT (getdate()) 
)


GO

-- ----------------------------
-- Records of Dashboard_Access
-- ----------------------------
SET IDENTITY_INSERT [dbo].[Dashboard_Access] ON
GO
INSERT INTO [dbo].[Dashboard_Access] ([Dashboard_Access_ID], [Profile_ID], [Budget], [Billback], [Sales], [Created_Date]) VALUES (N'1', N'35', N'1', N'1', N'1', N'2012-01-12 13:13:23.523');
GO
SET IDENTITY_INSERT [dbo].[Dashboard_Access] OFF
GO
