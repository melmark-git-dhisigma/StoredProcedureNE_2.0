USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[WBC_spInsertWBC]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WBC_spInsertWBC]
                @StudentID int, 
                @ClientName varchar(200), 
                @LabelID varchar(50), 
                @IdentifiedInitials VARCHAR (10),
                @IdentifiedDate               DATE,
                @IdentifiedTime               TIME (7),    
                @FamilyNotify                   BIT,         
                @FamilyNotifyDate DATE         ,
                @FamilyNotifyTime TIME (7)     ,
                @UICompleted    BIT          ,
                @UIRNumber       VARCHAR (50) ,
                @UIDate                                 DATE         ,
                @UITime                                TIME (7)     ,
                @NurseNotify      BIT          ,
                @NurseNotifyName  VARCHAR (200),
                @NurseNotifyID    INT          ,
                @NurseNotifyDate  DATE         ,
                @NurseNotifyTime  TIME (7)     ,
                @AdminNotify    BIT          ,
                @AdminNotifyName  VARCHAR (200),
                @AdminNotifyID    INT          ,
                @AdminNotifyDate  DATE         ,
                @AdminNotifyTime TIME (7)     ,
                @InjuryOriginText   VARCHAR (200),
                @InjuryOriginVal              VARCHAR (50) ,
                @InjuryLocText                VARCHAR (200),
                @InjuryLocVal                   VARCHAR (50) ,
                @InjuryTypeText                             VARCHAR (200),
                @InjuryTypeVal                VARCHAR (50) ,
                @SITrauma              BIT,          
                @AdditionalNotes                           VARCHAR (MAX),
                @SubmittedByName                     VARCHAR (200),
                @SubmittedByID                             VARCHAR (100),
                @SubmittedByDate                        VARCHAR (200),
                @SubmittedByTime                        VARCHAR (100),
                @SubmittedByPosition VARCHAR (200),
                @WBCStatus      VARCHAR (1),
                @ActiveStatus  VARCHAR (1),
                @WBCID int,
                @ImageInsert1 varbinary(MAX),
                @ImageSize1 int,
                @ImageInsert2 varbinary(MAX),
                @ImageSize2 int,
                @ImageInsert3 varbinary(MAX),
                @ImageSize3 int,
				@SelectedLocName Varchar(200),
				@SelectedLocVal varchar(200)
AS
BEGIN

IF EXISTS (SELECT * FROM [dbo].[WBC_MainDataTable] WHERE WBCID=@WBCID) 
BEGIN
UPDATE [dbo].[WBC_MainDataTable] SET [IdentifiedDate] = @IdentifiedDate, [IdentifiedTime] = @IdentifiedTime, [FamilyNotify] = @FamilyNotify, [FamilyNotifyDate] = @FamilyNotifyDate, [FamilyNotifyTime] = @FamilyNotifyTime, [UICompleted] = @UICompleted, [UIRNumber] = @UIRNumber, [UIDate] = @UIDate, [UITime] = @UITime, [NurseNotify] = @NurseNotify, [NurseNotifyName] = @NurseNotifyName, [NurseNotifyID] = @NurseNotifyID, [NurseNotifyDate] = @NurseNotifyDate, [NurseNotifyTime] = @NurseNotifyTime, [AdminNotify] = @AdminNotify, [AdminNotifyName] = @AdminNotifyName, [AdminNotifyID] = @AdminNotifyID, [AdminNotifyDate] = @AdminNotifyDate, [AdminNotifyTime] = @AdminNotifyTime, [InjuryOriginText] = @InjuryOriginText, [InjuryOriginVal] = @InjuryOriginVal, [InjuryLocText] = @InjuryLocText, [InjuryLocVal] = @InjuryLocVal, [InjuryTypeText] = @InjuryTypeText, [InjuryTypeVal] = @InjuryTypeVal, [SITrauma] = @SITrauma, [AdditionalNotes] = @AdditionalNotes, [WBCStatus] = @WBCStatus WHERE WBCID=@WBCID


if(@ImageInsert1 is not null)
begin
INSERT INTO [dbo].[WBC_PicTable]([WBCID],[ImageData],[ImageSize],[ImageStatus],[ActiveStatus]) values(@WBCID,@ImageInsert1,@ImageSize1,'A','A')
end

if(@ImageInsert2 is not null)
begin
INSERT INTO [dbo].[WBC_PicTable]([WBCID],[ImageData],[ImageSize],[ImageStatus],[ActiveStatus]) values(@WBCID,@ImageInsert2,@ImageSize2,'A','A')
end

if(@ImageInsert3 is not null)
begin
INSERT INTO [dbo].[WBC_PicTable]([WBCID],[ImageData],[ImageSize],[ImageStatus],[ActiveStatus]) values(@WBCID,@ImageInsert3,@ImageSize3,'A','A')
end

END

ELSE
BEGIN
INSERT INTO [dbo].[WBC_MainDataTable]([StudentID], [ClientName], [LabelID], [IdentifiedInitials], [IdentifiedDate], [IdentifiedTime], [FamilyNotify], [FamilyNotifyDate], [FamilyNotifyTime], [UICompleted], [UIRNumber], [UIDate], [UITime], [NurseNotify], [NurseNotifyName], [NurseNotifyID], [NurseNotifyDate], [NurseNotifyTime], [AdminNotify], [AdminNotifyName], [AdminNotifyID], [AdminNotifyDate], [AdminNotifyTime], [InjuryOriginText], [InjuryOriginVal], [InjuryLocText], [InjuryLocVal], [InjuryTypeText], [InjuryTypeVal], [SITrauma], [AdditionalNotes], [SubmittedByName],[SubmittedByID], [SubmittedByDate], [SubmittedByTime], [SubmittedByPosition], [WBCStatus],[ActiveStatus],[SelectedLocName],[SelectedLocVal] )VALUES(@StudentID, @ClientName, @LabelID, @IdentifiedInitials, @IdentifiedDate, @IdentifiedTime, @FamilyNotify, @FamilyNotifyDate, @FamilyNotifyTime, @UICompleted, @UIRNumber, @UIDate, @UITime, @NurseNotify, @NurseNotifyName, @NurseNotifyID, @NurseNotifyDate, @NurseNotifyTime, @AdminNotify, @AdminNotifyName, @AdminNotifyID, @AdminNotifyDate, @AdminNotifyTime, @InjuryOriginText, @InjuryOriginVal, @InjuryLocText, @InjuryLocVal, @InjuryTypeText, @InjuryTypeVal, @SITrauma, @AdditionalNotes, @SubmittedByName, @SubmittedByID, @SubmittedByDate, @SubmittedByTime, @SubmittedByPosition, @WBCStatus, @ActiveStatus,@SelectedLocName,@SelectedLocVal)
SELECT @WBCID = SCOPE_IDENTITY()

if(@ImageInsert1 is not null)
begin
INSERT INTO [dbo].[WBC_PicTable]([WBCID],[ImageData],[ImageSize],[ImageStatus],[ActiveStatus]) values(@WBCID,@ImageInsert1,@ImageSize1,'A','A')
end

if(@ImageInsert2 is not null)
begin
INSERT INTO [dbo].[WBC_PicTable]([WBCID],[ImageData],[ImageSize],[ImageStatus],[ActiveStatus]) values(@WBCID,@ImageInsert2,@ImageSize2,'A','A')
end

if(@ImageInsert3 is not null)
begin
INSERT INTO [dbo].[WBC_PicTable]([WBCID],[ImageData],[ImageSize],[ImageStatus],[ActiveStatus]) values(@WBCID,@ImageInsert3,@ImageSize3,'A','A')
end




END

INSERT INTO [dbo].[WBC_UpdateData]([WBCID],[UpdatedByName],[UpdatedByID],[UpdateDate],[UpdateTime],[UpdateStatus]) VALUES (@WbcID,@SubmittedByName,@SubmittedByID,@SubmittedByDate,@SubmittedByTime,@WBCStatus)
           
if(@WBCStatus='C')
begin
UPDATE [dbo].[WBC_MainDataTable] SET ClosedByID= @SubmittedByID, ClosedByName = @SubmittedByName, ClosedByDate=@SubmittedByDate, ClosedByTime = @SubmittedByTime where WBCID=@WBCID

end


END


GO
