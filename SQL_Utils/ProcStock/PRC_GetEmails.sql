USE [StaffRecruitment]
GO
/****** Object:  StoredProcedure [dbo].[Process_GetEmailByActivity]    Script Date: 21/03/2016 13:36:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Process_GetEmailByActivity]
	-- Add the parameters for the stored procedure here
	@ProcessName nvarchar(100),
	@ActivityName nvarchar(100),
	@ParticipantName nvarchar(100) = NULL,
​
	-- Specific to the project
	@RoleID int,	
	@CandidateID int = NULL,
	@ApplicationID int = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
​
	-- Get Email subject and content
	DECLARE @EmailSubject nvarchar(MAX) = ''
	DECLARE @EmailContent nvarchar(MAX) = ''
​
	SELECT @EmailSubject = EmailSubject,
		   @EmailContent = EmailContent 
	FROM Ref_Email
	WHERE ProcessName = @ProcessName
	AND ActivityName = @ActivityName
​
	-- Replace variables available on Email_Variable table
	DECLARE @VariableCode nvarchar(100) = ''
	DECLARE @VariableTable nvarchar(100) = ''
	DECLARE @variableField nvarchar(100) = ''
	DECLARE @VariableType nvarchar(100) = ''
​
	DECLARE varCursor CURSOR 
	FOR SELECT VariableCode, VariableTable, VariableField, VariableType FROM Ref_Email_Variable
​
	OPEN varCursor
	FETCH NEXT FROM varCursor
	INTO @VariableCode, @VariableTable, @variableField, @VariableType
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
​
			DECLARE @VariableValue nvarchar(MAX) = ''
			DECLARE @SQLString nvarchar(MAX) = N'
							SET @VariableValue = (SELECT '+ @VariableTable +'.'+ @VariableField +'
							FROM Role
								LEFT JOIN Ref_Campus ON Role.CampusID = Ref_Campus.CampusID
								LEFT JOIN Ref_ContractType ON Role.ContractTypeID = Ref_ContractType.ContractTypeID
								LEFT JOIN Ref_CostCode ON Role.CostCodeID = Ref_CostCode.CostCodeID
								LEFT JOIN Ref_Department ON Role.DepartmentID = Ref_Department.DepartmentID
								LEFT JOIN Ref_FacultyService ON Role.FacultyServiceID = Ref_FacultyService.FacultyServiceID
								LEFT JOIN Ref_Grade ON Role.GradeID = Ref_Grade.GradeID
								LEFT JOIN Ref_InterviewFormat ON Role.InterviewFormatID = Ref_InterviewFormat.InterviewFormatID
							WHERE Role.RoleID = '+ CONVERT(nvarchar(100),@RoleID) +')
							IF ('''+ @VariableType +''' = ''DateTime'')
								SET @VariableValue = FORMAT(CONVERT(datetime,@VariableValue), ''dd/MM/yyyy HH:mm tt'')
							IF ('''+ @VariableType +''' = ''Date'')
								SET @VariableValue = FORMAT(CONVERT(date,@VariableValue), ''dd/MM/yyyy'')'
​
			EXEC sp_executesql @SQLString, N'@VariableValue nvarchar(max) OUTPUT', @VariableValue = @VariableValue OUTPUT
			
			SET @EmailSubject = REPLACE(@EmailSubject, @VariableCode, ISNULL(@VariableValue,''))
			SET @EmailContent = REPLACE(@EmailContent, @VariableCode, ISNULL(@VariableValue,''))
​
			FETCH NEXT FROM varCursor 
			INTO @VariableCode, @VariableTable, @variableField, @VariableType
		END 
	CLOSE varCursor;
	DEALLOCATE varCursor;
​
	SELECT @EmailSubject, @EmailContent
​
​
END
Add Comment Colla