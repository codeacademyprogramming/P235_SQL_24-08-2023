Select Name From Students
union all
Select FullName as Name From Teachers
union
Select Name as FullName From Groups 

Select COUNT(distinct Name) From
(Select Name From Students
union all
Select FullName as Name From Teachers
) as unTables

select Name,Count(*) from Students where age > 20
Group By Name
Having Count(*) > 2

--View
Create View usv_GetStuGroupTeachers
as
Select s.Name StudentName,s.SurName,s.Age,s.Email,g.Name GroupName,t.FullName From Students s
join Groups g
on s.GroupId = g.Id
join TeacherGroups tg
on tg.GroupId = g.Id
join Teachers t
on t.Id = tg.TeacherId where s.Age > 25

Alter View usv_GetStuGroupTeachers
as
Select s.Name StudentName,s.SurName,s.Age,s.Email,g.Name GroupName,t.FullName From Students s
join Groups g
on s.GroupId = g.Id
join TeacherGroups tg
on tg.GroupId = g.Id
join Teachers t
on t.Id = tg.TeacherId

Select StudentName as Name From usv_GetStuGroupTeachers

--Procedure
Create Procedure usp_GetStuGroupTeacherByAge
@age tinyint
as
begin
	Select s.Name StudentName,s.SurName,s.Age,s.Email,g.Name GroupName,t.FullName From Students s
	join Groups g
	on s.GroupId = g.Id
	join TeacherGroups tg
	on tg.GroupId = g.Id
	join Teachers t
	on t.Id = tg.TeacherId where Age > @age
end

alter Procedure usp_GetStuGroupTeacherByAge
(@age tinyint, @groupId int)
as
begin
	Select s.Name StudentName,s.SurName,s.Age,s.Email,g.Name GroupName,t.FullName From Students s
	join Groups g
	on s.GroupId = g.Id
	join TeacherGroups tg
	on tg.GroupId = g.Id
	join Teachers t
	on t.Id = tg.TeacherId where Age > @age And s.GroupId = @groupId
end

alter Procedure usp_GetStuGroupTeacherByAge
(@age tinyint)
as
begin
	select * from usv_GetStuGroupTeachers where Age > @age
end

exec usp_GetStuGroupTeacherByAge 20


--Function
Create Function usf_AllCountByAge
(@age tinyInt)
returns int
as
Begin
	declare @count int

	Select @count = Count(*) From Students s
	join Groups g
	on s.GroupId = g.Id
	join TeacherGroups tg
	on tg.GroupId = g.Id
	join Teachers t
	on t.Id = tg.TeacherId where Age > @age

	return @count
End


alter Function usf_AllCountByAge
(@age tinyInt)
returns int
as
Begin
	declare @count int

	Select @count = Count(*) From Students s
	join Groups g
	on s.GroupId = g.Id
	join TeacherGroups tg
	on tg.GroupId = g.Id
	join Teachers t
	on t.Id = tg.TeacherId where Age > @age

	return @count
End

select dbo.usf_AllCountByAge(21) as count

select * From Students where Age > dbo.usf_AllCountByAge(21)

Create Table ArchiveStudents
(
	Id int,
	Name nvarchar(100),
	SurName nvarchar(100),
	Age TinyInt,
	Email nvarchar(100),
	GroupId int,
	Grade decimal(5,2),
	Date Datetime,
	ActionType nvarchar(100)
)

Create Trigger StuInsert
on Students
after insert
as
Begin
	declare @id int
	declare @name nvarchar(100)
	declare @surname nvarchar(100)
	declare @age tinyInt
	declare @email nvarchar(100)
	declare @groupId int
	declare @grade decimal(5,2)

	select @id = obj.Id from inserted obj
	select @name = obj.Name from inserted obj
	select @surname = obj.SurName from inserted obj
	select @email = obj.Email from inserted obj
	select @grade = obj.Grade from inserted obj
	select @groupId = obj.GroupId from inserted obj
	select @age = obj.Age from inserted obj

	Insert Into ArchiveStudents(Id, Name, SurName, Age, Grade, Email, GroupId, ActionType,Date)
	Values
	(@id,@name,@surname,@age,@grade,@email,@groupId,'Insert',GETDATE())

End

alter Trigger StuInsert
on Students
after insert,delete
as
Begin
	declare @id int
	declare @name nvarchar(100)
	declare @surname nvarchar(100)
	declare @age tinyInt
	declare @email nvarchar(100)
	declare @groupId int
	declare @grade decimal(5,2)
	declare @actionType nvarchar(100)

	select @id = obj.Id from inserted obj
	select @name = obj.Name from inserted obj
	select @surname = obj.SurName from inserted obj
	select @email = obj.Email from inserted obj
	select @grade = obj.Grade from inserted obj
	select @groupId = obj.GroupId from inserted obj
	select @age = obj.Age from inserted obj
	select @actionType = 'Insert' from inserted obj

	select @id = obj.Id from deleted obj
	select @name = obj.Name from deleted obj
	select @surname = obj.SurName from deleted obj
	select @email = obj.Email from deleted obj
	select @grade = obj.Grade from deleted obj
	select @groupId = obj.GroupId from deleted obj
	select @age = obj.Age from deleted obj
	select @actionType = 'Delete' from deleted obj

	Insert Into ArchiveStudents(Id, Name, SurName, Age, Grade, Email, GroupId, ActionType,Date)
	Values
	(@id,@name,@surname,@age,@grade,@email,@groupId,@actionType,GETDATE())

End


Insert Into Students(Name,SurName,Age,Email,Grade,GroupId)
Values
('Test1','Test1Ov',56,'test1@mail.ru',0,1)