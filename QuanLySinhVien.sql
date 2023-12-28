-- DDL
USE master 
GO
IF EXISTS (SELECT * FROM sysdatabases WHERE name = 'QuanLySinhVien')
	DROP DATABASE QuanLySinhVien
GO
CREATE DATABASE QuanLySinhVien
GO
USE QuanLySinhVien
GO

CREATE TABLE Khoa(
	MaKhoa nvarchar(10) PRIMARY KEY,
	TenKhoa nvarchar(50),
	SL_CBGD int CHECK(SL_CBGD BETWEEN 0 AND 4) DEFAULT 0
)
GO
CREATE TABLE MonHoc(
	MaMH nvarchar(10) PRIMARY KEY,
	TenMH nvarchar(50) NOT NULL,
	SoTC_ToiThieu int CHECK(SoTC_ToiThieu >= 2)
)
GO
CREATE TABLE SinhVien(
	MSSV nvarchar(6) PRIMARY KEY CHECK (MSSV LIKE '[a-z][0-9][0-9][0-9][0-9][FM]'),
	Ten nvarchar(50) NOT NULL,
	PhaiNu int CHECK(PhaiNu IN (0,1)),
	-- PhaiNu int CHECK(PhaiNu BETWEEN 0 AND 1),
	DiaChi nvarchar(100) NOT NULL,
	DienThoai nvarchar(10) CHECK(DienThoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	OR DienThoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	MaKhoa nvarchar(10),
	SoCMND nvarchar(12) UNIQUE,
	NgaySinh date,
	NgayNhapHoc date,
	NgayVaoDoan date,
	NgayVaoDang date,
	NgayRaTruong date,
	LyDoNgungHoc nvarchar(50) CHECK(LyDoNgungHoc IN (N'hoàn tất chương trình', 
	N'nghỉ học giữa khóa học', N'buộc thôi học', N'xin thôi học', N'Xin tạm ngừng', N'khác')),
	FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa) ON DELETE CASCADE
)
GO
-- Thêm RBTV
ALTER TABLE SinhVien
	ADD CHECK(DATEDIFF(YEAR, NgaySinh, NgayNhapHoc) >= 18),
	CHECK(DATEDIFF(YEAR, NgaySinh, NgayVaoDoan) >= 16),
	CHECK(NgayVaoDang > NgayVaoDoan)
	
CREATE TABLE GiaoVien(
	MaGV nvarchar(4) PRIMARY KEY CHECK(MaGV LIKE '[a-z][0-9][0-9][FM]'),
	TenGV nvarchar(50) NOT NULL,
	MaKhoa nvarchar(10),
	FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
)
GO

CREATE TABLE GiangDay(
	MaKhoaHoc nvarchar(4) PRIMARY KEY CHECK(MaKhoaHoc LIKE '[K][0-9][0-9][0-9]'),
	MaGV nvarchar(4),
	MaMH nvarchar(10),
	HocKy int CHECK(HocKy IN (1,2,3)),
	NienKhoa nvarchar(9),
	NgayBatDauLyThuyet date,
	NgayBatDauThucHanh date,
	NgayKetThuc date,
	TongSoTC int CHECK(TongSoTC BETWEEN 2 AND 6),
	SoTCLT int DEFAULT 0 CHECK(SoTCLT >= 0),
	SoTCTH int DEFAULT 0 CHECK(SoTCTH >= 0),
	SoTietLT int,
	SoTietTH int
	FOREIGN KEY (MaGV) REFERENCES GiaoVien(MaGV),
	FOREIGN KEY (MaMH) REFERENCES MonHoc(MaMH)
)
GO

ALTER TABLE GiangDay
	ADD CHECK(TongSoTC = SoTCLT + SoTCTH),
		CHECK(SoTietLT = SoTCLT * 15),
		CHECK(SoTietTH = SoTCTH * 30)

CREATE TABLE KetQua(
	MSSV nvarchar(6),
	MaKhoaHoc nvarchar(4),
	DiemKTGiuaKy float CHECK(DiemKTGiuaKy BETWEEN 0 AND 10) DEFAULT 0,
	DiemThiLan1 float CHECK(DiemThiLan1 BETWEEN 0 AND 10) DEFAULT 0,
	DiemThiLan2 float CHECK(DiemThiLan2 BETWEEN 0 AND 10) DEFAULT 0,
	DiemKhoaHoc float CHECK(DiemKhoaHoc BETWEEN 0 AND 10) DEFAULT 0
	PRIMARY KEY (MSSV, MaKhoaHoc)
	FOREIGN KEY (MSSV) REFERENCES SinhVien(MSSV),
	FOREIGN KEY (MaKhoaHoc) REFERENCES GiangDay(MaKhoaHoc)
)
GO
-- DML
SET DATEFORMAT dmy

INSERT INTO Khoa(MaKhoa, TenKhoa, SL_CBGD) VALUES (N'CNTT', N'Công Nghệ Thông Tin', 3)
INSERT INTO Khoa(TenKhoa, SL_CBGD, MaKhoa) VALUES (N'Toán', 1, N'TOAN')
INSERT INTO Khoa VALUES (N'SINH', N'Sinh học', 0)

INSERT INTO MonHoc VALUES (N'CSDL', N'Cơ sở dữ liệu', 2)
INSERT INTO MonHoc VALUES (N'CTDL', N'Cấu trúc dữ liệu', 3)
INSERT INTO MonHoc VALUES (N'KTLT', N'Kỹ thuật lập trình', 3)
INSERT INTO MonHoc VALUES (N'CWIN', N'Lập trình C trên Windows', 3)
INSERT INTO MonHoc VALUES (N'TRR', N'Toán rời rạc', 2)
INSERT INTO MonHoc VALUES (N'LTDT', N'Lý thuyết đồ thị', 2)

INSERT INTO SinhVien VALUES (N'C0001F', N'Bùi Thúy An', 1, N'223 Trần Hưng Đạo, HCM', N'38132202', N'CNTT',
							N'135792468', '14/8/1992', '1/10/2010', NULL , NULL , '15/11/2012', N'xin thôi học')
INSERT INTO SinhVien VALUES (N'C0002M', N'Nguyễn Thanh Tùng', 0, N'140 Cống Quỳnh, Sóc Trăng', N'38125678', N'CNTT',
							N'987654321', '23/11/1992', '1/10/2010', NULL , NULL , NULL, NULL)
INSERT INTO SinhVien VALUES (N'T0003M', N'Nguyễn Thành Long', 0, N'112/4 Cống Quỳnh, HCM', N'0918345623', N'TOAN',
							N'123456789', '17/8/1991', '1/10/2010', '19/5/2007', '1/5/2012', NULL, NULL)
INSERT INTO SinhVien VALUES (N'C0004F', N'Hoàng Thị Hoa', 1, N'90 Nguyễn Văn Cừ, HCM', N'38320123', N'CNTT',
							N'246813579', '2/9/1991', '17/10/2010', NULL , NULL , NULL, NULL)
INSERT INTO SinhVien VALUES (N'T0005M', N'Trần Hồng Sơn', 0, N'54 Cao Thắng, Hà Nội', N'38345987', N'TOAN',
							N'864297531', '24/4/1993', '15/10/2011', '2/9/2010' , NULL , NULL, NULL)

INSERT INTO GiaoVien VALUES (N'C01F', N'Phạm Thị Thảo', N'CNTT')
INSERT INTO GiaoVien VALUES (N'T02M', N'Lâm Hoàng Vũ', N'TOAN')
INSERT INTO GiaoVien VALUES (N'C03M', N'Trần Văn Tiến', N'CNTT')
INSERT INTO GiaoVien VALUES (N'C04M', N'Hoàng Vương', N'CNTT')

INSERT INTO GiangDay VALUES (N'K001', N'C01F', N'CSDL', 1, N'2011-2012', '15/9/2011', '1/10/2011', '2/1/2012',
							4, 3, 1, 45, 30)
INSERT INTO GiangDay VALUES (N'K002', N'C04M', N'KTLT', 2, N'2011-2012', '17/2/2012', '1/3/2012', '18/5/2012',
							4, 2, 2, 30, 60)
INSERT INTO GiangDay VALUES (N'K003', N'C03M', N'CTDL', 1, N'2012-2013', '11/9/2012', '14/3/2012', '3/1/2013',
							4, 3, 1, 45, 30)
INSERT INTO GiangDay VALUES (N'K004', N'C04M', N'CWIN', 1, N'2012-2013', '13/9/2012', '13/10/2012', '14/1/2013',
							4, 2, 2, 30, 60)
INSERT INTO GiangDay VALUES (N'K005', N'T02M', N'TRR', 1, N'2012-2013', '14/9/2012', '2/10/2012', '18/1/2013',
							2, 2, 0, 30, 0)
INSERT INTO GiangDay VALUES (N'K006', N'C04M', N'CSDL', 1, N'2011-2012', '15/9/2011', '1/10/2012', '2/1/2012',
							4, 3, 1, 45, 30)
INSERT INTO GiangDay VALUES (N'K007', N'C04M', N'CTDL', 1, N'2011-2012', '15/9/2011', '1/10/2012', '2/1/2012',
							4, 3, 1, 45, 30)
INSERT INTO GiangDay VALUES (N'K008', N'C04M', N'TRR', 1, N'2011-2012', '15/9/2011', '1/10/2012', '2/1/2012',
							4, 3, 1, 45, 30)
INSERT INTO GiangDay VALUES (N'K009', N'C04M', N'LTDT', 1, N'2011-2012', '15/9/2011', '1/10/2012', '2/1/2012',
							4, 3, 1, 45, 30)

INSERT INTO KetQua VALUES (N'C0001F', N'K001', 8.5, 5, NULL, 6.4)
INSERT INTO KetQua VALUES (N'C0001F', N'K003', 8.0, 9, NULL, 8.6)
INSERT INTO KetQua VALUES (N'T0003M', N'K004', 9.0, 7, NULL, 7.8)
INSERT INTO KetQua VALUES (N'C0001F', N'K002', 9.0, 7, NULL, 7.8)
INSERT INTO KetQua VALUES (N'T0003M', N'K003', 6.0, 2, 2.5, 3.9)
INSERT INTO KetQua VALUES (N'T0005M', N'K003', 9.0, 7, NULL, 7.8)
INSERT INTO KetQua VALUES (N'C0002M', N'K001', 7.0, 2, 5, 5.8)
INSERT INTO KetQua VALUES (N'T0003M', N'K002', 6.5, 2, 3, 4.4)
INSERT INTO KetQua VALUES (N'T0005M', N'K005', 7.0, 10, NULL, 8.8)
INSERT INTO KetQua VALUES (N'C0001F', N'K004', 8.0, 9, NULL, 8.6)

-- Structured query language - sql

/*3.3.1.	Truy vấn dữ liệu với Dùng Structured Query Language (SQL)
1.	Cho biết tên, địa chỉ, điện thọai của tất cả các sinh viên.*/
SELECT Ten, DiaChi, DienThoai
FROM SinhVien

/*2.	Cho biết tên các môn học và số tín chỉ tối thiểu của từng môn học.*/
SELECT TenMH, SoTC_ToiThieu
FROM MonHoc

--3.	Cho biết kết quả học tập của sinh viên có Mã số “T0003M”.
SELECT *
FROM KetQua
WHERE MSSV = 'T0003M'

--4.	Cho biết tên các giáo viên có ký tự thứ 3 của họ và tên là “A”.
SELECT TenGV
FROM GiaoVien
WHERE TenGV LIKE N'__[AẠẦÀ]%'

--5.	Cho biết tên những môn học có chứa chữ “dữ” (ví dụ như các môn Cơ sở dữ liệu, Cấu trúc dữ liệu,...).
SELECT TenMH
FROM MonHoc
WHERE TenMH LIKE N'%dữ%'

--6.	Cho biết tên các giáo viên có ký tự đầu tiên của họ và tên là các ký tự “P” hoặc “L”.
SELECT TenGV
FROM GiaoVien
WHERE TenGV LIKE N'[PL]%'

--7.	Cho biết tên, địa chỉ của những sinh viên có địa chỉ trên đường “Cống Quỳnh”.
SELECT Ten, DiaChi
FROM SinhVien
WHERE DiaChi LIKE N'%Cống Quỳnh%'

--8.	Cho biết mã môn học, tên môn học, mã khóa học và tổng số tín chỉ (TongSoTC) của những môn học có cấu trúc của mã môn học như sau: ký tự thứ 1 là “C”, ký tự thứ 3 là “D”.
SELECT M.MaMH, TenMH, MaKhoaHoc, TongSoTC
FROM MonHoc M INNER JOIN GiangDay G ON M.MaMH = G.MaMH
WHERE M.MaMH LIKE N'C_D%'

--9.	Cho biết tên các môn học được dạy trong niên khóa 2011-2012.
SELECT TenMH
FROM MonHoc INNER JOIN GiangDay ON MonHoc.MaMH = GiangDay.MaMH
WHERE NienKhoa = N'2011-2012'

--10.	Cho biết tên khoa, mã số sinh viên, tên, địa chỉ của các SV theo từng Khoa sắp theo thứ tự A-Z của tên sinh viên.
SELECT TenKhoa, MSSV, Ten, DiaChi
FROM Khoa INNER JOIN SinhVien ON SinhVien.MaKhoa = Khoa.MaKhoa
ORDER BY Ten ASC

--11.	Cho biết tên môn học, tên sinh viên, điểm tổng kết (DiemKhoaHoc) của sinh viên qua từng khóa học.
SELECT TenMH, Ten, DiemKhoaHoc
FROM SinhVien INNER JOIN (KetQua INNER JOIN (GiangDay INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH) ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc) ON SinhVien.MSSV = KetQua.MSSV

--12.	Cho biết tên và điểm tổng kết của sinh viên qua từng khóa học (DiemKhoaHoc) của các SV học môn ‘CSDL’ với DiemKhoaHoc từ 6 đến 7.
SELECT GiangDay.MaKhoaHoc, Ten, DiemKhoaHoc
FROM SinhVien INNER JOIN (KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc) ON SinhVien.MSSV = KetQua.MSSV
WHERE GiangDay.MaMH = N'CSDL' AND DiemKhoaHoc BETWEEN 6 AND 7

--13.	Cho biết Tên sinh viên, tên môn học, mã khóa học, điểm tổng kết của sinh viên qua từng khóa học (DiemKhoaHoc) của SV có tên là ‘TUNG’.
SELECT Ten, TenMH, GiangDay.MaKhoaHoc, DiemKhoaHoc
FROM SinhVien INNER JOIN (KetQua INNER JOIN (GiangDay INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH) ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc) ON SinhVien.MSSV = KetQua.MSSV
WHERE Ten LIKE N'%T[uù]ng'

--14.	Cho biết tên khoa, tên môn học mà những sinh viên trong khoa đã học. Yêu cầu khi kết quả có nhiều dòng trùng nhau, chỉ hiển thị 1 dòng làm đại diện
SELECT DISTINCT TenKhoa, TenMH
FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
			INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
			INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
			INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH

--15.	Cho biết tên khoa, mã khóa học mà giáo viên của khoa có tham gia giảng dạy.
SELECT DISTINCT TenKhoa, MaKhoaHoc
FROM Khoa INNER JOIN GiaoVien ON Khoa.MaKhoa = GiaoVien.MaKhoa
			INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV

--16.	Cho biết tên những giáo viên tham gia giảng dạy môn “Ky thuat lap trinh”.
SELECT DISTINCT TenGV
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenMH = N'Kỹ thuật lập trình'

--17.	Cho biết mã, tên các SV có DiemKhoaHoc của 1 môn học nào đó trên 8 (kết quả các môn khác có thể <=8).
SELECT DISTINCT  SinhVien.MSSV, Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE DiemKhoaHoc > 8

--18.	Cho biết tên sinh viên, mã môn học, tên môn học, DiemKhoaHoc của những SV đã học môn ‘CSDL’ hoặc ‘CTDL’.
--(i).-	Sử dụng 1 lệnh SELECT
SELECT Ten, MonHoc.MaMH, TenMH, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE MonHoc.MaMH = N'CSDL' OR MonHoc.MaMH = N'CTDL'

--(ii).Sử dụng từ 2 lệnh SELECT trở lên và các lệnh này được kết với nhau qua 1 trong 2 toán tử INTERSECT hoặc UNION.
SELECT Ten, MonHoc.MaMH, TenMH, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE MonHoc.MaMH = N'CSDL'
UNION
SELECT Ten, MonHoc.MaMH, TenMH, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE MonHoc.MaMH = N'CTDL'

--19.	Cho biết tên môn học mà giáo viên “Tran Van Tien” tham gia giảng dạy trong học kỳ 1 niên khóa 2012-2013.
--(i).-	Sử dụng 1 lệnh SELECT
SELECT TenMH
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenGV = N'Trần Văn Tiến' AND HocKy = 1 AND NienKhoa = N'2012-2013'

--(ii).Sử dụng từ 2 lệnh SELECT trở lên và các lệnh này được kết với nhau qua 1 trong 2 toán tử INTERSECT hoặc UNION.
SELECT TenMH
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenGV = N'Trần Văn Tiến'
INTERSECT
SELECT TenMH
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE HocKy = 1
INTERSECT
SELECT TenMH
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE NienKhoa = N'2012-2013'

--20.	Cho biết tên những sinh viên đã có điểm trong table Kết quả (yêu cầu loại bỏ các tên trùng nhau nếu có).
SELECT DISTINCT Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
------


--21.	Cho hiển thị 35% dữ liệu có trong table kết quả.
SELECT TOP 35 PERCENT *
FROM KetQua

--22.	Cho biết tên 3 sinh viên có DiemKhoaHoc cao nhất trong table kết quả.
SELECT TOP 3 Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
ORDER BY DiemKhoaHoc DESC

/*23.	Cho biết tên môn học và điểm lớn nhất mà sinh viên ‘C0001F’ đạt được. 
Nếu sinh viên ‘C0001F’ có nhiều môn có cùng điểm lớn nhất (ví dụ cùng đạt 8.6), hãy liệt kê tất cả những môn học này.*/
SELECT TOP 1 WITH TIES TenMH, DiemKhoaHoc
FROM KetQua INNER JOIN GiangDay ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE KetQua.MSSV = N'C0001F'
ORDER BY DiemKhoaHoc DESC

--24.	Cho biết tên những sinh viên thuộc khoa Toán có DiemKhoaHoc lớn hơn tất cả các điểm của những SV không thuộc khoa Toán.
/* gia tri >= ALL(Tap gia tri) -> voi moi
	gia tri >= ANY(tap gia tri) -> ton tai */
SELECT Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE MaKhoa = N'TOAN' AND DiemKhoaHoc >= ALL(
SELECT DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE MaKhoa <> N'TOAN'
)

--25.	Cho biết tên những sinh viên không thuộc khoa Công nghệ thông tin có năm sinh nhỏ hơn năm sinh của bất kỳ SV nào thuộc khoa Công nghệ thông tin.
SELECT Ten
FROM SinhVien
WHERE MaKhoa <> N'CNTT' AND DATEPART(YEAR, NgaySinh) < ANY(
SELECT DATEPART(YEAR, NgaySinh)
FROM SinhVien
WHERE MaKhoa = N'CNTT'
)

--26.	Cho biết tên những khoa có sinh viên theo học. Lần lượt thực hiện yêu cầu này bằng các cách:
--(i).-	Không sử dụng sub Select.
SELECT DISTINCT TenKhoa
FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa

--(ii).-Sử dụng sub Select và toán tử IN.
SELECT TenKhoa
FROM Khoa
WHERE MaKhoa IN (
SELECT MaKhoa
FROM SinhVien
)

--(iii).-Sử dụng sub Select và toán tử EXISTS.
SELECT TenKhoa
FROM Khoa
WHERE EXISTS (
SELECT MaKhoa
FROM SinhVien
WHERE Khoa.MaKhoa = SinhVien.MaKhoa
)

/*27.(*) Cho biết tên những sinh viên có tháng sinh trùng nhau. Kết quả hiển thị gồm tên sinh viên (X), 
ngày sinh của sinh viên (X), tên sinh viên (Y) trùng tháng sinh với sinh viên X,  ngày sinh của sinh viên (Y). 
Thực hiện liên kết các table tham gia bằng 2 cách:*/
--(i).-	Inner join
SELECT S1.Ten, S1.NgaySinh, S2.Ten, S2.NgaySinh
FROM SinhVien S1 INNER JOIN SinhVien S2 ON DATEPART(MONTH, S1.NgaySinh) = DATEPART(MONTH, S2.NgaySinh)
WHERE S1.MSSV <> S2.MSSV

--(ii).-Phép nhân
SELECT S1.Ten, S1.NgaySinh, S2.Ten, S2.NgaySinh
FROM SinhVien S1, SinhVien S2
WHERE S1.MSSV <> S2.MSSV AND DATEPART(MONTH, S1.NgaySinh) = DATEPART(MONTH, S2.NgaySinh)

--28.	Lần lượt sử dụng các hàm xếp hạng: Row_Number, Dense_Rank, Rank để xuất các kết quả sau:
--a
SELECT MSSV, DiemKhoaHoc, ROW_NUMBER() OVER (ORDER BY DiemKhoaHoc DESC) AS XepHang
FROM KetQua

--b
SELECT MSSV, DiemKhoaHoc, DENSE_RANK() OVER (ORDER BY DiemKhoaHoc DESC) AS XepHang
FROM KetQua

--c
SELECT MSSV, DiemKhoaHoc, Rank() OVER (ORDER BY DiemKhoaHoc DESC) AS XepHang
FROM KetQua

--d
SELECT ROW_NUMBER() OVER (ORDER BY MSSV), Ten, MSSV
FROM SinhVien

--e
SELECT SinhVien.MSSV, Ten, DiemKhoaHoc, DENSE_RANK() OVER (PARTITION BY SinhVien.MSSV
															ORDER BY DiemKhoaHoc DESC)
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
ORDER BY SinhVien.MSSV ASC

--f
SELECT TenKhoa AS N'Tên Khoa', TenMH AS N'Tên môn học', ROW_NUMBER() OVER (PARTITION BY TenMH, TenKhoa
																			ORDER BY Ten ASC) AS 'STT SV', Ten AS N'Họ và tên SV', DiemKhoaHoc
FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
		INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
		INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
		INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
ORDER BY TenKhoa ASC

--3.3.2.	Aggregate Functions
/* syntax:
SELECT ALL|DISTINCT|TOP n [WITH TIES|PERCENT] *|field name| MIN, MAX, SUM, COUNT, AVG -- Aggregate functions
FROM tableName
WHERE dieuKien
ORDER BY fieldname ASC|DESC
*/
--29.	Có bao nhiêu SV.
SELECT COUNT(MSSV) AS SoLuongSV
FROM SinhVien

--30.	Có bao nhiêu GV.
SELECT COUNT(MaGV) AS SoLuongGV
FROM GiaoVien

--31.	Có bao nhiêu giáo viên khoa CNTT.
SELECT COUNT(MaGV) AS SoLuongGV
FROM GiaoVien
WHERE MaKhoa = N'CNTT'

--32.	Có bao nhiêu SV nữ thuộc khoa “CNTT”.
SELECT COUNT(MaGV) AS SoLuongGV
FROM GiaoVien
WHERE MaKhoa = N'CNTT' AND MaGV LIKE N'%F'

--33.	Có bao nhiêu môn học được giảng dạy trong học kỳ I năm 2011-2012.
SELECT COUNT(MaMH) AS SoMonHoc
FROM GiangDay
WHERE HocKy = 1 AND NienKhoa = N'2011-2012'

--34.	Có bao nhiêu SV học môn CSDL.
SELECT COUNT(MSSV) AS SoSVHocCSDL
FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
WHERE MaMH = N'CSDL'

--35.	Cho biết số lượng môn học đã tham gia và điểm TB của tất cả các DiemKhoaHoc của SV có mã số ‘T0003M’.
SELECT MSSV, COUNT(*) AS 'SoLuongMon', DiemTrungBinh = FORMAT(AVG(DiemKhoaHoc), 'N', 'en-us')
FROM KetQua
WHERE MSSV = 'T0003M'
GROUP BY MSSV

--36.	Cho biết mã, tên, địa chỉ và điểm TB của tất cả các DiemKhoaHoc của từng SV.
SELECT SinhVien.MSSV, Ten, DiaChi, DiemTrungBinh = FORMAT(AVG(DiemKhoaHoc), 'N', 'en-us')
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten, DiaChi

/*37.	Cho biết số lượng DiemKhoaHoc >=8 của từng sinh viên (chỉ xuất kết quả cho những sinh viên có DiemKhoaHoc >=8). 
Minh họa kết quả thực hiện	Họ tên SV	SL DiemKhoaHoc >=8
	BUI THUY AN	2
	TRAN HONG SON	18*/
SELECT Ten, COUNT(*) AS 'SLDiemKhoaHoc>=8'
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE DiemKhoaHoc >= 8
GROUP BY Ten

/*38.	Cho biết tên khoa, số lượng sinh viên có trong từng khoa (chỉ xuất kết quả cho những khoa có sinh viên).
Minh họa kết quả thực hiện	TenKhoa	SL Khóa học
	Công nghệ thông tin	3
	Toan	2*/
SELECT TenKhoa, COUNT(*) AS 'SoLuongSinhVien'
FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
GROUP BY TenKhoa

/*39.	Cho biết tên khoa, số lượng khóa học mà giáo viên của khoa có tham gia giảng dạy (chỉ xuất kết quả cho những khoa có giáo viên tham gia giảng dạy trong các khóa học).
Minh họa kết quả thực hiện	TenKhoa	SL Khóa học
	Công nghệ thông tin	4
	Toan	1*/
SELECT TenKhoa, COUNT(*) AS 'SLGVThamGiaGiangDay'
FROM Khoa INNER JOIN GiaoVien ON Khoa.MaKhoa = GiaoVien.MaKhoa
			INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenKhoa

--40.	Cho biết số lượng tín chỉ lý thuyết, số lượng tín chỉ thực hành mà từng sinh viên đã tham gia (gồm MSSV, tên SV, số lượng tín chỉ lý thuyết, số lượng tín chỉ thực hành).
SELECT SinhVien.MSSV, Ten, SUM(SoTCLT) AS 'SoTCLyThuyet', SUM(SoTCTH) AS 'SoTCTH'
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
GROUP BY SinhVien.MSSV, Ten

--41.	Cho biết tên tất cả các giáo viên cùng với số lương khóa học, số lượng tín chỉ (lý thuyết + thực hành) mà từng giáo viên đã tham gia giảng dạy. 
SELECT TenGV, COUNT(*) AS 'SoLuongKhoaHoc', 'SoLuongTinChi' = SUM(SoTCLT) + SUM(SoTCTH)
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenGV

/*42.	Giả sử người ta muốn thống kê số lượng sinh viên theo từng nhóm điểm (với nhóm điểm được làm tròn không lấy số lẻ từ DiemKhoaHoc trong table Kết quả):
Yêu cầu: Đếm xem mỗi nhóm trong DiemKhoaHoc_PhanNhom có bao nhiêu sinh viên.*/
SELECT DiemKhoaHoc = ROUND(DiemKhoaHoc, 0), COUNT(*) AS 'SLSV'
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY ROUND(DiemKhoaHoc, 0)

/*3.3.3.	Having
syntax:
SELECT ALL|DISTINCT|TOP n [WITH TIES|PERCENT] *|field name| MIN, MAX, SUM, COUNT, AVG -- Aggregate functions
FROM tableName
WHERE dieuKien
HAVING dieuKien
ORDER BY fieldname ASC|DESC
*/
--43.	Cho biết tên những sinh viên chỉ mới thi đúng một môn.
SELECT Ten, COUNT(*) AS 'SoLuongMon'
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY Ten
HAVING COUNT(*) = 1

--44.	Cho biết mã, tên, địa chỉ và điểm của các SV có điểm trung bình (của tất cả các DiemKhoaHoc) >8.5.
SELECT SinhVien.MSSV, Ten, DiaChi, AVG(DiemKhoaHoc) AS 'DiemTrungBinh'
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten, DiaChi 
HAVING AVG(DiemKhoaHoc) > 8.5

--45.	Cho biết Mã khóa học, học kỳ, năm, số lượng SV tham gia của những khóa học có số lượng SV tham gia từ 2 đến 4 người.
SELECT KetQua.MaKhoaHoc, HocKy, NienKhoa, COUNT(*) AS 'SoLuongSV'
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
GROUP BY KetQua.MaKhoaHoc, HocKy, NienKhoa
HAVING COUNT(*) BETWEEN 2 AND 4

--46.	Cho biết các SV đã học đủ 2 môn ‘CSDL’ & ’CTDL’ hoặc có DiemKhoaHoc của 1 trong 2 môn này >=8. Yêu cầu thực hiện bằng 2 cách: 
--a.-	Sử dụng duy nhất 1 lệnh SELECT.
SELECT DISTINCT Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
WHERE SinhVien.MSSV IN (SELECT MSSV
						FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
						WHERE MaMH IN ('CSDL', 'CTDL')
						GROUP BY MSSV
						HAVING COUNT(*) = 2)
OR SinhVien.MSSV IN (SELECT MSSV
						FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
						WHERE MaMH IN ('CSDL', 'CTDL') AND DiemKhoaHoc >= 8)

--b.-	Sử dụng phép UNION giữa kết quả của 2 lệnh SELECT.*/
SELECT DISTINCT Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
WHERE SinhVien.MSSV IN (SELECT Ten
						FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
						WHERE MaMH IN ('CSDL', 'CTDL')
						GROUP BY MSSV
						HAVING COUNT(*) = 2)
UNION
SELECT DISTINCT Ten
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
WHERE SinhVien.MSSV IN (SELECT MSSV
						FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
						WHERE MaMH IN ('CSDL', 'CTDL') AND DiemKhoaHoc >= 8)
--3.3.4 Lệnh Case - Hàm IIF
/* CASE WHEN dk1 THEN aaa
		WHEN dk2 THEN bbb
		WHEN dk3 then ccc
		ELSE ddd
		END */
--47.	Trả lời “Có” hoặc “không”
--a.-	Cho biết sinh viên có mã số ‘C0001F’  có tham  gia khóa học ‘K001’ hay không?
SELECT TraLoi = IIF (COUNT(*) >= 1, 'Co', 'Khong')
FROM KetQua
WHERE MSSV = 'C0001F' AND MaKhoaHoc = 'K001'
---------------------------------
SELECT TraLoi = CASE WHEN COUNT(*) >= 1 THEN 'Co'
						ELSE 'Khong'
						END
FROM KetQua
WHERE MSSV = 'C0001F' AND MaKhoaHoc = 'K001'

--b.-	Cho biết khóa học K1 có sinh viên bị thi lại (DiemKhoaHoc <5) hay không? 
SELECT TraLoi = IIF (COUNT(*) >= 1, 'Co', 'Khong')
FROM KetQua
WHERE DiemKhoaHoc < 5
----------------------
SELECT TraLoi = CASE WHEN COUNT(*) >= 1 THEN 'Co'
						ELSE 'Khong'
						END
FROM KetQua
WHERE DiemKhoaHoc < 5

--c.-	Cho biết Khoa CNTT có sinh viên Nữ đạt DiemKhoaHoc cả 2 môn ‘CSDL’ & ’CTDL’ >=5 hay không? 
SELECT TraLoi = IIF (COUNT(*) >= 2, 'Co', 'Khong')
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc 
WHERE MaKhoa = N'CNTT' AND PhaiNu = 1 AND ((MaMH = 'CSDL' AND DiemKhoaHoc >= 5) OR (MaMH = 'CTDL' AND DiemKhoaHoc >= 5))
------------------------------------
SELECT TraLoi = CASE WHEN COUNT(*) >= 2  THEN 'Co'
						ELSE 'Khong'
						END
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc 
WHERE MaKhoa = N'CNTT' AND PhaiNu = 1 AND ((MaMH = 'CSDL' AND DiemKhoaHoc >= 5) OR (MaMH = 'CTDL' AND DiemKhoaHoc >= 5))

--d.-	Cho biết giáo viên tên 'THAO' có dạy môn học nào trong năm 2011-2012 hay không?  
SELECT TraLoi = IIF (COUNT(*) >= 1, 'Co', 'Khong')
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
WHERE TenGV LIKE N'%Thảo' AND NienKhoa = N'2011-2012'
---------------------------------------
SELECT TraLoi = CASE WHEN COUNT(*) >= 1 THEN 'Co'
						ELSE 'Khong'
						END
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
WHERE TenGV LIKE N'%Thảo' AND NienKhoa = N'2011-2012'

--48.	Giả sử cần tạo dữ liệu gồm 3 cột MSSV, Họ tên, Học bổng. Trong đó những sinh viên có điểm trung bình của tất cả các môn đều phải >=7 sẽ nhận học bổng là 1tr, ngược lại, học bổng =0.
SELECT SinhVien.MSSV, Ten, HocBong = IIF (AVG(DiemKhoaHoc) >= 7, 1000000, 0)
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten
--------------------------------------
SELECT SinhVien.MSSV, Ten, HocBong = CASE WHEN AVG(DiemKhoaHoc) >= 7 THEN 1000000
											ELSE 0
											END
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten


/*49.	Giả sử cần tạo dữ liệu gồm 3 cột MSSV, Họ tên, Xếp loại. Trong đó cột Xếp loại căn cứ  trên điểm trung bình (của tất cả các DiemKhoaHoc) theo quy định xếp loại như sau:
	DiemKhoaHoc >=	9	=> xuất sắc
8 <= 	DiemKhoaHoc < 	9 	=> giỏi
7 <= 	DiemKhoaHoc <	8 	=> khá
5 <= 	DiemKhoaHoc <	7 	=> trung bình
	DiemKhoaHoc <	5 	=> yếu*/
SELECT SinhVien.MSSV, Ten, XepLoai = IIF (AVG(DiemKhoaHoc) >= 9, N'Xuất sắc', 
									IIF (AVG(DiemKhoaHoc) >= 8, N'Giỏi', 
									IIF (AVG(DiemKhoaHoc) >= 7, N'Khá', 
									IIF (AVG(DiemKhoaHoc) >= 5, N'Trung bình', N'Yếu'))))
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten
------------------------------------------
SELECT SinhVien.MSSV, Ten, XepLoai = CASE WHEN AVG(DiemKhoaHoc) >= 9 THEN N'Xuất sắc'
											WHEN AVG(DiemKhoaHoc) >= 8 THEN N'Giỏi'
											WHEN AVG(DiemKhoaHoc) >= 7 THEN N'Khá'
											WHEN AVG(DiemKhoaHoc) >= 5 THEN N'Trung bình'
											ELSE N'Yếu'
											END
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten

--3.3.5.	Lớn/Nhỏ nhất
--Yêu cầu chung của phần này: sinh viên cần thực hiện mỗi yêu cầu bằng nhiều cách (khác nhau) nhất.
--50.		Cho biết tên của môn học có số tín chỉ tối thiểu (SoTC_ToiThieu) là nhiều nhất.
-- Cach 1: dung min max
SELECT TenMH
FROM MonHoc
WHERE SoTC_ToiThieu = (SELECT MAX(SoTC_ToiThieu)
		FROM MonHoc)
-------------------
-- Cach 2: dung >= ALL
SELECT TenMH
FROM MonHoc
WHERE SoTC_ToiThieu >= ALL(SELECT SoTC_ToiThieu
		FROM MonHoc)
------------------
-- Cach 3: TOP N WITH TIES
SELECT TOP 1 TenMH
FROM MonHoc
ORDER BY SoTC_ToiThieu DESC

--51.		Cho biết tên của khoa có số lượng CBGD ít nhất.
--Cach 1: Dung MIN/MAX
SELECT TenKhoa
FROM Khoa
WHERE SL_CBGD = (SELECT MIN(SL_CBGD)
		FROM Khoa)
--------------------
--Cach 2: Dung >=ALL
SELECT TenKhoa
FROM Khoa
WHERE SL_CBGD >= ALL(SELECT SL_CBGD
		FROM Khoa)
--------------------
--Cach 3: Dung TOP N WITH TIES
SELECT TOP 1 WITH TIES TenKhoa
FROM Khoa
ORDER BY SL_CBGD ASC

--52.	Cho biết mã, tên, địa chỉ của các SV có DiemKhoaHoc lớn nhất trong khóa học có mã là ‘K001’.
SELECT TOP 1 WITH TIES SinhVien.MSSV, Ten, DiaChi
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE MaKhoaHoc = N'K001'
ORDER BY DiemKhoaHoc DESC
------------------------
SELECT SinhVien.MSSV, Ten, DiaChi
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE MaKhoaHoc = N'K001' AND DiemKhoaHoc = (SELECT MAX(DiemKhoaHoc)
												FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
												WHERE MaKhoaHoc = N'K001')
------------------------
SELECT SinhVien.MSSV, Ten, DiaChi
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE MaKhoaHoc = N'K001' AND DiemKhoaHoc >= ALL(SELECT DiemKhoaHoc
												FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
												WHERE MaKhoaHoc = N'K001')

--53.	Tên các sinh viên có DiemKhoaHoc cao nhất trong môn ‘Kỹ Thuật Lập Trình’.


--Cách 1:
SELECT SinhVien.MSSV, Ten, DiaChi, MonHoc.MaMH, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV=KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc=GiangDay.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenMH = N'Kỹ thuật lập trình' AND DiemKhoaHoc = (SELECT MAX(DiemKhoaHoc)
														FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV=KetQua.MSSV
																		INNER JOIN GiangDay ON KetQua.MaKhoaHoc=GiangDay.MaKhoaHoc
																		INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
														WHERE TenMH = N'Kỹ thuật lập trình')
-----------------------
--Cách 2:
SELECT SinhVien.MSSV, Ten, DiaChi, MonHoc.MaMH, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV=KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc=GiangDay.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenMH = N'Kỹ thuật lập trình' AND DiemKhoaHoc >= ALL(SELECT DiemKhoaHoc
															FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV=KetQua.MSSV
																			INNER JOIN GiangDay ON KetQua.MaKhoaHoc=GiangDay.MaKhoaHoc
																			INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
															WHERE TenMH = N'Kỹ thuật lập trình')
--------------------------
--Cach 3: TOP N WITH TIES
SELECT TOP 1 WITH TIES SinhVien.MSSV, Ten, DiaChi, MonHoc.MaMH, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV=KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc=GiangDay.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenMH = N'Kỹ thuật lập trình'
ORDER BY DiemKhoaHoc DESC

--54.	Cho biết tên những giáo viên tham gia giảng dạy nhiều khóa học nhất.
SELECT TOP 1 WITH TIES TenGV
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenGV
ORDER BY COUNT(*) DESC
-----------------------
SELECT TenGV
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenGV
HAVING COUNT(*) >= ALL(SELECT COUNT(*)
						FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
						GROUP BY TenGV)

--55.		Cho biết mã số, tên và DiemKhoaHoc cao nhất của từng SV.
SELECT  SinhVien.MSSV, Ten, MAX(DiemKhoaHoc) AS DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV =  KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten

--56.		Đối với từng môn học, cho biết tên môn học và DiemKhoaHoc cao nhất của môn học đó. 
SELECT MonHoc.TenMH, MAX(DiemKhoaHoc) AS DiemKhoaHoc
FROM MonHoc INNER JOIN GiangDay ON MonHoc.MaMH=GiangDay.MaMH
			 INNER JOIN KetQua  ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
GROUP BY MonHoc.TenMH


--57.	Học kỳ nào có nhiều môn học được giảng dạy nhất (không quan tâm đến năm học).
SELECT TOP 1 WITH TIES GiangDay.Hocky
FROM MonHoc  
INNER JOIN GiangDay ON MonHoc.MaMH=GiangDay.MaMH
GROUP BY GiangDay.Hocky
ORDER BY COUNT(MonHoc.TenMH) DESC

--58.	Cho biết tên các môn học có nhiều sinh viên tham gia nhất (tên môn, số lượng sinh viên).
SELECT TenMH,COUNT(MSSV)
FROM MonHoc M INNER JOIN GiangDay G ON M.MaMH=G.MaMH
			  INNER JOIN KetQua K ON G.MaKhoaHoc=K.MaKhoaHoc
GROUP BY TenMH
HAVING COUNT(MSSV) >= ALL (SELECT COUNT(MSSV) AS MSSV
							FROM MonHoc M INNER JOIN GiangDay G ON M.MaMH=G.MaMH
										  INNER JOIN KetQua K ON G.MaKhoaHoc=K.MaKhoaHoc
							GROUP BY TenMH)

--59.	Cho biết tên các sinh viên có nhiều DiemKhoaHoc trong khoảng từ 7 đến 8 nhất. (bao gồm tên sinh viên, số lượng DiemKhoaHoc từ 7 đến 8).


--60.	Cho biết tên các sinh viên có số lượng tín chỉ tham gia học là nhiều nhất (có thể điểm của môn đó không đạt – DiemKhoaHoc <5), thông tin hiển thị bao gồm tên sinh viên, số lượng tín chỉ).


--61.	Cho biết tên các sinh viên có số lượng tín chỉ đạt (DiemKhoaHoc >=5) nhiều nhất. (bao gồm tên sinh viên, số lượng tín chỉ có DiemKhoaHoc >=5).


--62.	Cho biết tên môn học, tên sinh viên, DiemKhoaHoc của các sinh viên học những môn học có số tín chỉ tối thiểu (SoTC_ToiThieu) là thấp nhất.


--63.	Tương tự yêu cầu của câu trên, cho biết tên môn học, tên sinh viên có điểm cao nhất của môn học đó. Hay nói cách khác cho biết tên sinh viên có điểm cao nhất của những môn học có số tín chỉ là thấp nhất.


--64.	 Cho biết tên Khoa, tên sinh viên thuộc Khoa và có điểm trung bình cao nhất.*/

/*3.3.6.	Left Join
65.	Cho biết tên tất cả các giáo viên cùng với số lương khóa học mà từng giáo viên đã tham gia giảng dạy.*/
SELECT TenGV, SoLuongKhoaHoc = COUNT(*)
FROM GiaoVien LEFT JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenGV

/*66.	Cho biết tên tất cả các sinh viên, điểm trung bình (của tất cả các DiemKhoaHoc), số lượng khóa học đã tham gia học tập. Với yêu cầu:
-	Nếu điểm trung bình có giá trị là NULL thì chuyển thành thông báo ‘SV chưa thi bất kỳ môn học nào’.
-	Giá trị của điểm trung bình được định dạng với 2 số lẻ.
Minh họa 
kết quả thực hiện	Tên	Điểm trung bình	SL khóa học
	BUI THUY AN	7.85	4
	HOANG THI HOA	SV chưa thi bất kỳ môn học nào	0
	NGUYEN THANH LONG	5.37	3
	NGUYEN THANH TUNG	5.80	1
	TRAN HONG SON	8.30	2 */
SELECT Ten, DiemTrungBinh = IIF (AVG(DiemKhoaHoc) IS NULL, N'SV chưa thi bất kỳ môn học nào', CAST (ROUND(AVG(DiemKhoaHoc),2) AS nvarchar(5))), SoLuongKhoaHoc = COUNT(MaKhoaHoc)
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY Ten

--67.	Cho biết số lượng tín chỉ mà từng sinh viên đã tham gia (gồm MSSV, tên SV, số lượng tín chỉ).
SELECT SinhVien.MSSV, Ten, SoLuongTinChi = SUM(TongSoTC)
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				LEFT JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
GROUP BY SinhVien.MSSV, Ten

/*68.	Cho biết tên tất cả các môn học, SL SV đã có điểm của môn học đó, DiemKhoaHoc nhỏ nhất của môn học đó. Nếu môn học nào chưa có SV có điểm thì in ra ‘Chưa có SV có điểm môn học này’.
Minh họa 
kết quả thực hiện	Tên	Điểm trung bình	SL khóa học
	Cau Truc Du Lieu	3	6.77
	Co So Du Lieu	2	6.10
	Ky Thuat Lap Trinh	2	6.10
	Lap Trinh C Tren Window	2	8.20
	Ly thuyet do thi	0	Chưa có SV có điểm môn học này
	Toan roi rac	1	8.80 */
SELECT TenMH, SLSinhVienCoDiem = COUNT(GiangDay.MaMH), DiemKhoaHocNhoNhat = IIF (ROUND(MIN(DiemKhoaHoc), 2) IS NULL, N'Chưa có SV có điểm môn học này', CAST (ROUND(MIN(DiemKhoaHoc), 2) AS nvarchar(5)))
FROM MonHoc LEFT JOIN GiangDay ON MonHoc.MaMH = GiangDay.MaMH
			LEFT JOIN KetQua ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
GROUP BY TenMH

/*69.	Cho biết tên khoa, số lượng sinh viên có trong từng khoa (tương tự câu 38, nhưng xuất kết quả cho tất cả các khoa).
Minh họa kết quả thực hiện	TenKhoa	SL SV
	Công nghệ thông tin	3
	Sinh học	0
	Toan	2 */
SELECT TenKhoa, SoLuongSV = COUNT(MSSV)
FROM Khoa LEFT JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
GROUP BY TenKhoa

/*70.	Cho biết tên khoa, số lượng khóa học mà giáo viên của khoa có tham gia giảng dạy (tương tự câu 39, nhưng xuất kết quả cho tất cả các khoa).
Minh họa kết quả thực hiện	TenKhoa	SL Khóa học
	Công nghệ thông tin	8
	Sinh học	0
	Toan	1 */
SELECT TenKhoa, SLKhoaHocGVThamGiaGiangDay = COUNT(MaKhoaHoc)
FROM Khoa LEFT JOIN GiaoVien ON Khoa.MaKhoa = GiaoVien.MaKhoa
			LEFT JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenKhoa

--71.	(*) Cho biết số lượng DiemKhoaHoc >=8 của từng sinh viên (tương tự câu 37, nhưng xuất kết quả cho tất cả sinh viên có trong table SinhVien). SV có thể viết câu này bằng 2 cách khác nhau.
SELECT Ten, SLDiemLonHonBang8 = SUM(CASE WHEN DiemKhoaHoc >= 8 THEN 1 ELSE 0 END)
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY Ten
---------------------
SELECT Ten, SLDiemLonHonBang8 = SUM(IIF (DiemKhoaHoc >= 8, 1, 0))
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY Ten

/*3.3.7.	Không/ Chưa có
Yêu cầu chung của phần này: sinh viên cần thực hiện mỗi yêu cầu bằng nhiều cách khác nhau nhất (nếu có thể) trong các cách  sau:
(i).-	NOT IN
(ii).-	NOT EXISTS
(iii).-	LEFT/RIGHT JOIN
(iv).-	EXCEPT */

--72.	Cho biết tên những môn học chưa được tổ chức cho các khóa học.
SELECT TenMH
FROM MonHoc LEFT JOIN GiangDay ON MonHoc.MaMH = GiangDay.MaMH
WHERE GiangDay.MaMH IS NULL
----------------
SELECT TenMH
FROM MonHoc
WHERE MaMH NOT IN (SELECT MaMH
					FROM GiangDay)
----------------
SELECT TenMH
FROM MonHoc
WHERE MaMH IN (SELECT MaMH
				FROM MonHoc
				EXCEPT
				SELECT MaMH
				FROM GiangDay)
----------------
SELECT TenMH
FROM MonHoc
WHERE NOT EXISTS (SELECT MaMH
					FROM GiangDay
					WHERE MonHoc.MaMH = GiangDay.MaMH)

--73.	Cho biết tên những sinh viên chưa có bất kỳ điểm nào trong table KetQua.
SELECT Ten
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE KetQua.MSSV IS NULL
----------------
SELECT Ten
FROM SinhVien
WHERE MSSV NOT IN (SELECT MSSV
					FROM KetQua)
------------------
SELECT Ten
FROM SinhVien
WHERE MSSV IN (SELECT MSSV
				FROM SinhVien
				EXCEPT
				SELECT MSSV
				FROM KetQua)
------------------
SELECT Ten
FROM SinhVien
WHERE NOT EXISTS (SELECT MSSV
					FROM KetQua
					WHERE SinhVien.MSSV = KetQua.MSSV)

--74.	Cho biết tên những khoa không có sinh viên theo học.
SELECT TenKhoa
FROM Khoa LEFT JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
WHERE SinhVien.MaKhoa IS NULL
------------------
SELECT TenKhoa
FROM Khoa
WHERE MaKhoa NOT IN (SELECT MaKhoa
						FROM SinhVien)
----------------
SELECT TenKhoa
FROM Khoa
WHERE MaKhoa IN (SELECT MaKhoa
				FROM Khoa
				EXCEPT
				SELECT MaKhoa
				FROM SinhVien)
-----------------------
SELECT TenKhoa
FROM Khoa
WHERE NOT EXISTS (SELECT MaKhoa
					FROM SinhVien
					WHERE Khoa.MaKhoa = SinhVien.MaKhoa)

--75.	(*)Cho biết các SV chưa học môn ‘LTC trên Windows’.
SELECT Ten
FROM SinhVien
WHERE Ten NOT IN (SELECT Ten 
			FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
			WHERE TenMH = N'Lập trình C trên Windows')
-----------------------
SELECT Ten
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				LEFT JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
				LEFT JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
GROUP BY Ten
HAVING SUM(IIF (TenMH = N'Lập trình C trên Windows',1 , 0)) = 0
----------------------
SELECT Ten
FROM SinhVien
WHERE MSSV IN (SELECT MSSV
				FROM SinhVien
				EXCEPT
				SELECT MSSV
				FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
							INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
				WHERE TenMH = N'Lập trình C trên Windows')
-------------------
SELECT Ten
FROM SinhVien
WHERE NOT EXISTS (SELECT MSSV
					FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
							INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
					WHERE SinhVien.MSSV= KetQua.MSSV AND TenMH = N'Lập trình C trên Windows')

--76.	(*)Tên các giáo viên không tham gia giảng dạy trong năm 2011 (bao gồm cả 2 trường hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).
SELECT TenGV
FROM GiaoVien LEFT JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
GROUP BY TenGV
HAVING SUM(IIF (NienKhoa LIKE N'%2011%', 1, 0)) = 0
----------------------
SELECT TenGV
FROM GiaoVien LEFT JOIN (SELECT MaGV
							FROM GiangDay
							WHERE NienKhoa IN ('2010-2011', '2011-2012')) D ON GiaoVien.MaGV = D.MaGV
WHERE D.MaGV IS NULL
-------------------
SELECT TenGV
FROM GiaoVien
WHERE MaGV NOT IN (SELECT MaGV
						FROM GiangDay
						WHERE NienKhoa IN ('2010-2011', '2011-2012'))
----------------------
SELECT TenGV
FROM GiaoVien
WHERE MaGV IN (SELECT MaGV
				FROM GiaoVien
				EXCEPT
				SELECT MaGV
				FROM GiangDay
				WHERE NienKhoa IN ('2010-2011', '2011-2012'))
------------------
SELECT TenGV
FROM GiaoVien
WHERE NOT EXISTS (SELECT MaGV
					FROM GiangDay
					WHERE GiaoVien.MaGV = GiangDay.MaGV AND NienKhoa IN ('2010-2011', '2011-2012'))

--77.	(*)Cho biết tên các môn học không được tổ chức trong năm 2011 (bao gồm cả 2 trường hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).
SELECT TenMH
FROM MonHoc LEFT JOIN (SELECT MaMH
						FROM GiangDay
						WHERE NienKhoa IN ('2010-2011', '2011-2012')) D ON MonHoc.MaMH = D.MaMH
WHERE D.MaMH IS NULL
--------------
SELECT TenMH
FROM MonHoc
WHERE MaMH NOT IN (SELECT MaMH
						FROM GiangDay
						WHERE NienKhoa IN ('2010-2011', '2011-2012'))
----------------
SELECT TenMH
FROM MonHoc
WHERE MaMH IN (SELECT MaMH
				FROM MonHoc
				EXCEPT
				SELECT MaMH
				FROM GiangDay
				WHERE NienKhoa IN ('2010-2011', '2011-2012')) 
--------------------
SELECT TenMH
FROM MonHoc
WHERE NOT EXISTS (SELECT MaMH
				FROM GiangDay
				WHERE MonHoc.MaMH = GiangDay.MaMH AND NienKhoa IN ('2010-2011', '2011-2012'))

--78.	(*) Tương tự câu trên là cho biết mã, tên các SV có tất cả các DiemKhoaHoc đều trên 7. Nhưng yêu cầu kết quả sẽ hiển thị tất cả những sinh viên có trong table sinh viên. Lưu ý cần loại trừ những sinh viên chưa có bất kỳ điềm nào trong table kết quả.
SELECT SinhVien.MSSV, Ten
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
GROUP BY SinhVien.MSSV, Ten
HAVING SUM(IIF (DiemKhoaHoc < 7,1 , 0)) = 0
INTERSECT
SELECT DISTINCT SinhVien.MSSV, Ten
FROM SinhVien LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
WHERE KetQua.MSSV IS NOT NULL
-----------------
SELECT MSSV, Ten
FROM SinhVien
WHERE MSSV NOT IN (SELECT MSSV
					FROM KetQua
					WHERE DiemKhoaHoc < 7)
	AND MSSV IN (SELECT DISTINCT MSSV
					FROM KetQua)
---------------
SELECT MSSV, Ten
FROM SinhVien
WHERE MSSV IN (SELECT MSSV
				FROM SinhVien
				EXCEPT
				SELECT MSSV
				FROM KetQua
				WHERE DiemKhoaHoc < 7)
	AND MSSV IN (SELECT DISTINCT MSSV
					FROM KetQua)
-------------------
SELECT MSSV, Ten
FROM SinhVien
WHERE NOT EXISTS (SELECT MSSV
					FROM KetQua
					WHERE SinhVien.MSSV = KetQua.MSSV AND DiemKhoaHoc < 7)
	AND MSSV IN (SELECT DISTINCT MSSV
					FROM KetQua)

--79.	(*) Cho biết mã, tên các GV chỉ tham gia giảng dạy trong học kỳ 1 (không quan tâm đến niên khóa). Lưu ý cần loại bỏ GV chưa có tham gia giảng dạy bất kỳ khóa học nào.
SELECT GiaoVien.MaGV, TenGV
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV =  GiangDay.MaGV
GROUP BY GiaoVien.MaGV, TenGV
HAVING SUM(IIF (HocKy = 1, 1, 0)) > 0 AND SUM(IIF (HocKy = 2, 1, 0)) = 0
INTERSECT
SELECT DISTINCT GiaoVien.MaGV, TenGV
FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV =  GiangDay.MaGV
WHERE GiangDay.MaGV IS NOT NULL
---------------------
SELECT MaGV, TenGV
FROM GiaoVien
WHERE MaGV NOT IN (SELECT MaGV
					FROM GiangDay
					WHERE HocKy = 2)
	AND MaGV IN (SELECT MaGV
					FROM GiangDay)
-------------------
SELECT MaGV, TenGV
FROM GiaoVien
WHERE MaGV IN (SELECT MaGV
				FROM GiaoVien
				EXCEPT
				SELECT MaGV
				FROM GiangDay
				WHERE HocKy <> 1)
	AND MaGV IN (SELECT DISTINCT MaGV
					FROM GiangDay)
-----------------
SELECT MaGV, TenGV
FROM GiaoVien
WHERE NOT EXISTS (SELECT MaGV
					FROM GiangDay
					WHERE GiaoVien.MaGV = GiangDay.MaGV AND HocKy <> 1)
		AND MaGV IN (SELECT DISTINCT MaGV
					FROM GiangDay)

--3.3.8.	Phép Bù
--80.	Giả sử quy định mỗi giáo viên phải dạy đủ tất cả các môn học. Cho biết tên giáo viên, tên môn học mà giáo viên chưa dạy.
SELECT *
FROM GiaoVien, MonHoc M
WHERE MaGV NOT IN (SELECT MaGV
					FROM GiangDay D
					WHERE D.MaMH = M.MaMH)

--81.	Tương tự, giả sử quy định mỗi sinh viên phải học đủ tất cả các môn học. Cho biết tên sinh viên, tên môn mà sinh viên chưa học.
SELECT Ten, TenMH
FROM SinhVien, MonHoc
WHERE MSSV NOT IN (SELECT MSSV
					FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
					WHERE MonHoc.MaMH = GiangDay.MaMH)

--3.3.9.	Phép Chia
--82.	Cho biết tên những giáo viên tham gia dạy đủ tất cả các môn học.
SELECT *
FROM GiaoVien
WHERE NOT EXISTS (SELECT *
					FROM MonHoc
					WHERE NOT EXISTS (SELECT *
										FROM GiangDay
										WHERE GiangDay.MaGV = GiaoVien.MaGV
											AND GiangDay.MaMH = MonHoc.MaMH))

--83.	Cho biết tên những môn học mà tất cả các giáo viên đều tham gia giảng dạy.
SELECT TenMH
FROM MonHoc
WHERE NOT EXISTS (SELECT *
					FROM GiaoVien
					WHERE NOT EXISTS (SELECT *
										FROM GiangDay
										WHERE GiangDay.MaMH = MonHoc.MaMH
											AND GiangDay.MaGV = GiaoVien.MaGV))

--84.	Cho biết khóa học mà tất cả các sinh viên đều tham gia.
SELECT MaKhoaHoc
FROM GiangDay
WHERE NOT EXISTS (SELECT *
					FROM SinhVien
					WHERE NOT EXISTS (SELECT *
										FROM KetQua
										WHERE KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
											AND KetQua.MSSV = SinhVien.MSSV))

--85.	Cho biết tên những sinh viên tham gia đủ tất cả các khóa học.
SELECT Ten
FROM SinhVien
WHERE NOT EXISTS (SELECT *
					FROM GiangDay
					WHERE NOT EXISTS (SELECT *
										FROM KetQua
										WHERE KetQua.MSSV = SinhVien.MSSV
											AND KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc))

--86.	Cho biết tên môn học mà tất cả các sinh viên đều đã học.
SELECT TenMH
FROM MonHoc
WHERE NOT EXISTS (SELECT *
					FROM SinhVien
					WHERE NOT EXISTS (SELECT *
										FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
										WHERE KetQua.MSSV = SinhVien.MSSV
											AND GiangDay.MaMH = MonHoc.MaMH))

--87.	Cho biết tên sinh viên đã học đủ tất cả các môn học.
SELECT Ten
FROM SinhVien
WHERE NOT EXISTS (SELECT *
					FROM MonHoc
					WHERE NOT EXISTS (SELECT *
										FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
										WHERE KetQua.MSSV = SinhVien.MSSV
											AND KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
											AND GiangDay.MaMH = MonHoc.MaMH))

--88.	Cho biết tên những sinh viên đã học tất cả những môn mà sinh viên ‘T0003M’ đã học.
SELECT Ten
FROM SinhVien
WHERE MSSV <> N'T0003M' AND NOT EXISTS (SELECT *
										FROM MonHoc M1 INNER JOIN GiangDay G1 ON M1.MaMH = G1.MaMH
													INNER JOIN KetQua K1 ON K1.MaKhoaHoc = G1.MaKhoaHoc
										WHERE MSSV = N'T0003M' 
										AND NOT EXISTS (SELECT *
															FROM MonHoc M2 INNER JOIN GiangDay G2 ON M2.MaMH = G2.MaMH
																			INNER JOIN KetQua K2 ON K1.MaKhoaHoc = G2.MaKhoaHoc
															WHERE K2.MSSV = SinhVien.MSSV
																AND M1.MaMH = M2.MaMH))

--89.	Cho biết tên những giáo viên đã dạy tất cả những môn học mà giáo viên ‘C01F’ đã dạy.
SELECT TenGV
FROM GiaoVien
WHERE MaGV <> N'C01F' AND NOT EXISTS (SELECT *
										FROM GiangDay G1
										WHERE MaGV = N'C01F'
											AND NOT EXISTS (SELECT *
															FROM GiangDay G2
															WHERE G2.MaGV = GiaoVien.MaGV
																AND G2.MaMH = G1.MaMH))

/*3.3.10.	Update
90.	Thêm các field SLMon(Số lượng môn), DTB (Điểm trung bình), DTBTichLuy (Điểm trung bình tích lũy), 
--SoTCTichLuy(SoTCTichLuy), XL(Xếp loại) vào table SinhVien.*/
ALTER TABLE SinhVien
	ADD SLMon int, DTB float, DTBTichLuy float, SoTCTichLuy int, XL nvarchar(20)
/*91.	Cập nhật thông tin cho các field vừa tạo theo yêu cầu:
a.-	NgayNhapHoc: sinh viên khoa CNTT nhập học ngày 15/11/2011; sinh viên khoa TOAN nhập học ngày 22/10/2011; các Khoa khác giữ nguyên giá trị ngày đang có. */
UPDATE SinhVien
SET NgayNhapHoc = CASE WHEN MaKhoa = N'CNTT' THEN N'15/11/2011'
						WHEN MaKhoa = N'TOAN' THEN N'20/10/2011'
						ELSE NgayNhapHoc
						END
--b.-	SLMon: tổng số lượng môn học mà sinh viên đã kiểm tra (có điểm).
UPDATE SinhVien
SET SLMon = (SELECT COUNT(*) FROM SinhVien S INNER JOIN KetQua ON S.MSSV = KetQua.MSSV WHERE S.MSSV = SinhVien.MSSV)
--------------
UPDATE SinhVien
SET SLMon = (SELECT COUNT(*) FROM KetQua WHERE SinhVien.MSSV = KetQua.MSSV)

--c.-	DTB: điểm trung bình của tất cả các điểm mà sinh viên đã có (kể cả những DiemKhoaHoc<5).
UPDATE SinhVien
SET DTB = (SELECT AVG(DiemKhoaHoc) 
FROM SinhVien S INNER JOIN KetQua ON S.MSSV = KetQua.MSSV 
WHERE S.MSSV = SinhVien.MSSV 
GROUP BY KetQua.MSSV)

--d.-	DTBTichLuy: 
--•	Thêm mới cột điểm trung bình DTBTichLuy với kiểu dữ liệu là nvarchar(30).
--•	Tính điểm trung bình của tất cả các DiemKhoaHoc>=5 của từng SV. Nếu SV chưa có bất kỳ điểm nào trong table KetQua thì DTBTichLuy sẽ nhận giá trị là “Chưa có điểm”.
ALTER TABLE SinhVien
	ADD DTBTichLuy nvarchar(20)
UPDATE SinhVien
SET DTBTichLuy =  (SELECT IIF(AVG(IIF(DiemKhoaHoc>=5, DiemKhoaHoc, NULL)) IS NULL,'Chua co diem', CAST(AVG(IIF(DiemKhoaHoc>=5, DiemKhoaHoc, NULL)) as nvarchar(20)))
						FROM SinhVien S LEFT JOIN KetQua K ON S.MSSV = K.MSSV
						WHERE SinhVien.MSSV=S.MSSV
						GROUP BY S.MSSV)
-------------------
UPDATE SinhVien
SET DTBTichluy = (SELECT IIF(DTBTichluy IS NULL, N'Chua co diem', DTBTichluy)
						FROM (SELECT S.MSSV, FORMAT(AVG(DIEMKHOAHOC), 'N', 'EN-US') AS DTBTichluy
												FROM SINHVIEN S
													LEFT JOIN KETQUA ON S.MSSV = KETQUA.MSSV
													--WHERE DIEMKHOAHOC>=5
													GROUP BY S.MSSV) AS A1
								WHERE SinhVien.MSSV = A1.MSSV)

--e.-	SoTCTichLuy: tương tự câu trên, nhưng tính tổng số các tín chỉ của những DiemKhoaHoc >=5. Đối với sinh viên chưa học sẽ nhận giá trị 0 
UPDATE SinhVien
SET SoTCTichLuy =  (SELECT IIF(SUM(IIF(DiemKhoaHoc>=5, TongSoTC, NULL)) IS NULL, 0, SUM(IIF (DiemKhoaHoc>=5, TongSoTC, NULL)))
						FROM SinhVien S LEFT JOIN KetQua K ON S.MSSV = K.MSSV
										LEFT JOIN GiangDay G ON K.MaKhoaHoc = G.MaKhoaHoc
										LEFT JOIN MonHoc M ON G.MaMH = M.MaMH
						WHERE SinhVien.MSSV=S.MSSV
						GROUP BY S.MSSV)

/*f.-	XepLoai:	nếu 	DTBTichLuy = NULL	: Chưa xếp loại 
		DTBTichLuy <5.0		: yếu
5.0 <= DTBTichLuy < 6.5	: trung bình
6.5 <= DTBTichLuy < 8.0	: khá
8.0 <= DTBTichLuy < 9.0	: giỏi
9.0 <= DTBTichLuy <=10.0	: xuất sắc */
UPDATE SinhVien
SET XL = (SELECT CASE WHEN DTBTichLuy >= 9.0 THEN N'Xuất sắc'
											WHEN DTBTichLuy >= 8.0 THEN N'Giỏi'
											WHEN DTBTichLuy >= 6.5 THEN N'Khá'
											WHEN DTBTichLuy >= 5.0 THEN N'Trung bình'
											ELSE N'Yếu'
											END
			FROM SinhVien S
			WHERE S.MSSV = SinhVien.MSSV)

/*92.	Thực hiện thêm mới cột Học bổng cho table SinhVien dựa trên cột DTBTichLuy với quy định 3 mức học bổng như sau:
	DTBTichLuy >= 9	: 	2.000.000 đ
8 <= 	DTBTichLuy <   9	:	1.000.000 đ
	DTBTichLuy <   8	:	0 đ*/
ALTER TABLE SinhVien
	ADD HocBong float
UPDATE SinhVien
SET HocBong = (SELECT CASE WHEN DTBTichLuy >= 9.0 THEN 2000000
											WHEN DTBTichLuy >= 8.0 THEN 1000000
											ELSE 0
											END
				FROM SinhVien S
				WHERE S.MSSV = SinhVien.MSSV)

--3.3.11.	Delete
--93.	Xóa tất cả kết quả học tập của sinh viên ‘C0002M’.
DELETE KetQua
WHERE MSSV = N'C0002M'

--94.	Xóa tên những sinh viên có điểm trung bình (DTBTichLuy) dưới 5 hoặc chưa có bất kỳ điểm nào trong table KetQua.
DELETE SinhVien
FROM SinhVien
WHERE MSSV IN (SELECT MSSV FROM SinhVien WHERE DTBTichLuy = N'Chua co diem')
	OR MSSV NOT IN (SELECT MSSV FROM SinhVien WHERE LEFT(DTBTichLuy, 1) <> 'C' AND CAST(LEFT(DTBTichLuy, 1) AS int) < 5)

--95.	Xóa những khoa không có sinh viên theo học.
DELETE Khoa
WHERE MaKhoa NOT IN (SELECT DISTINCT MaKhoa FROM SinhVien)


/*3.4	View
96.	Tạo View chứa các thông tin sau: tên khoa, số lượng sinh viên nam, số lượng sinh viên nữ.*/
CREATE OR ALTER VIEW v_Cau96
AS 
	SELECT TenKhoa, SLNam = SUM(IIF (PhaiNu = 0, 1, 0)), SLNu = SUM(IIF (PhaiNu = 1, 1, 0))
	FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
	GROUP BY TenKhoa

SELECT * FROM v_Cau96

/*97.	Tạo View chứa danh sách sinh viên (gồm MSSV, Ten, MaMH, DiemKhoaHoc) không thuộc khoa “CNTT” có điểm thi môn “CSDL” lớn hơn điểm thi môn “CSDL” của ít nhất một sinh viên thuộc khoa “CNTT”.
	Yêu cầu thực hiện:*/
--(i).-	Tạo View v_Cau97A chứa DiemKhoaHoc môn ‘CSDL’ của những sinh viên thuộc khoa CNTT.
CREATE OR ALTER VIEW v_Cau97A
AS
	SELECT DiemKhoaHoc
	FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
				INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE MaMH = N'CSDL' AND Khoa.MaKhoa = N'CNTT'

SELECT * FROM v_Cau97A

--(ii).-	Tạo View v_Cau97B gồm các field MSSV, Ten, MaMH, DiemKhoaHoc chứa kết quả môn ‘CSDL’ của những sinh viên KHÔNG thuộc khoa CNTT.
CREATE OR ALTER VIEW v_Cau97B
AS
	SELECT SinhVien.MSSV, Ten, MaMH, DiemKhoaHoc
	FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
				INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE MaMH = N'CSDL' AND Khoa.MaKhoa <> N'CNTT'

SELECT * FROM v_Cau97B

--(iii).-	Viết lệnh truy vấn dữ liệu từ 2 view trên để có kết quả mong muốn.*/
SELECT *
FROM v_Cau97B
WHERE DiemKhoaHoc > (SELECT MIN(DiemKhoaHoc) FROM v_Cau97A)

/*98.	Tạo View chứa danh sách sinh viên không thuộc khoa “CNTT” có điểm trung bình (DTB) lớn hơn ít nhất một sinh viên thuộc khoa “CNTT”.
	Yêu cầu thực hiện:*/
--(i).-	Tạo View v_Cau98A chứa DTB của những sinh viên thuộc khoa CNTT.
CREATE OR ALTER VIEW v_Cau98A
AS
	SELECT DTB
	FROM SinhVien
	WHERE MaKhoa = N'CNTT'

--(ii).-	Tạo View v_Cau98B gồm các field MSSV, Ten, MaKhoa, DTB) của những sinh viên KHÔNG thuộc khoa CNTT.
CREATE OR ALTER VIEW v_Cau98B
AS
	SELECT MSSV, Ten, MaKhoa, DTB
	FROM SinhVien
	WHERE MaKhoa <> N'CNTT'

--(iii).-	Viết lệnh truy vấn dữ liệu từ 2 view trên để có kết quả mong muốn.*/
SELECT *
FROM v_Cau98B
WHERE DTB >= ANY (SELECT DTB FROM v_Cau98A)

--99.	Tạo View chứa danh sách sinh viên đã thi tất cả các môn học có trong danh mục môn học (không tính đến học kỳ).
CREATE OR ALTER VIEW v_Cau99
AS
	SELECT MSSV
	FROM SinhVien
	WHERE NOT EXISTS (SELECT *
						FROM MonHoc
						WHERE NOT EXISTS (SELECT *
											FROM KetQua INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
											WHERE KetQua.MSSV = SinhVien.MSSV
												AND GiangDay.MaMH = MonHoc.MaMH))

SELECT * FROM v_Cau99

--100.	Tạo View chứa danh sách giáo viên đã dạy tất cả các môn học (không tính đến học kỳ).
CREATE OR ALTER VIEW v_Cau100
AS
	SELECT *
	FROM GiaoVien
	WHERE NOT EXISTS (SELECT *
						FROM MonHoc
						WHERE NOT EXISTS (SELECT *
											FROM GiangDay
											WHERE GiangDay.MaGV = GiaoVien.MaGV
												AND GiangDay.MaMH = MonHoc.MaMH))

SELECT * FROM v_Cau100

--101.	Tạo View chứa thông tin về số lượng các môn học đã được giảng dạy trong từng học kỳ, từng năm học.
CREATE OR ALTER VIEW v_Cau101
AS
	SELECT HocKy, NienKhoa, SLMonHoc = COUNT(*)
	FROM GiangDay
	GROUP BY HocKy, NienKhoa

SELECT * FROM v_Cau101

--102.	Thống kê tỷ lệ đậu, rớt của từng môn học.
--MaMH	TenMH	SLDau	SLRot
			
--103.	Tạo View thống kê tỷ lệ sinh viên nam, sinh viên nữ theo từng xếp loại của từng khoa.


--104.	Tạo View cho biết sĩ số của các khoa trong trường . Kết xuất có dạng:
--MaKhoa	TenKhoa	Siso
--Lưu ý: chỉ tính sĩ số đối với các sinh viên hiện còn đang học (NgayRaTruong=NULL).*/


/*3.5	Common Table Expression (CTE)
105.	Thực hiện lại câu 59 nhưng sử dụng CTE: Cho biết tên các môn học có nhiều sinh viên tham gia nhất (tên môn, số lượng sinh viên)*/
WITH CTE105
AS
(
	SELECT TenMH, COUNT(*) AS SLSV_ThamGia
	FROM MonHoc INNER JOIN GiangDay ON MonHoc.MaMH = GiangDay.MaMH
				INNER JOIN KetQua ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
	GROUP BY TenMH
)
SELECT *
FROM CTE105
WHERE SLSV_ThamGia = (SELECT MAX(SLSV_ThamGia) FROM CTE105) 

--106.	Thực hiện lại câu 60 nhưng sử dụng CTE: Học kỳ nào có nhiều môn học được giảng dạy nhất (không quan tâm đến năm học).
WITH CTE106
AS
(
	SELECT HocKy, COUNT(*) AS SLMon
	FROM GiangDay
	GROUP BY HocKy
)
SELECT * 
FROM CTE106
WHERE SLMon = (SELECT MAX(SLMon) FROM CTE106)

--107.	Thực hiện lại câu 61 nhưng sử dụng CTE: Cho biết tên các sinh viên có nhiều điểm (DiemKhoaHoc) >=7 nhất. (bao gồm tên sinh viên, số lượng điểm >= 7). 
WITH CTE107
AS
(
	SELECT Ten, SLDiemLonHonbang7 = COUNT(*)
	FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
	WHERE DiemKhoaHoc >= 7
	GROUP BY Ten
)
SELECT * 
FROM CTE107
WHERE SLDiemLonHonbang7 = (SELECT MAX(SLDiemLonHonbang7) FROM CTE107)

--108.	Thực hiện lại câu 62 nhưng sử dụng CTE: Cho biết tên các sinh viên có số lượng tín chỉ đạt (DiemKhoaHoc >=5) nhiều nhất. 
--Thông tin hiển thị bao gồm tên sinh viên, số lượng tín chỉ).
WITH CTE108
AS
(
	SELECT Ten, SLTinChi = SUM(TongSoTC)
	FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
	WHERE DiemKhoaHoc >= 5
	GROUP BY Ten
)
SELECT * 
FROM CTE108
WHERE SLTinChi = (SELECT MAX(SLTinChi) FROM CTE108)
--109.	Thực hiện lại câu 76 nhưng sử dụng CTE: Cho biết các SV chưa học môn ‘LTC trên Windows’.
WITH CTE109
AS
(
	SELECT SinhVien.MSSV
	FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
	WHERE TenMH = N'Lập trình C trên Windows'
)
SELECT Ten
FROM SinhVien
WHERE MSSV NOT IN (SELECT * FROM CTE109)

--110.	Thực hiện lại câu 77 nhưng sử dụng CTE: Tên các giáo viên không tham gia giảng dạy trong năm 2011 (bao gồm cả 2 trường hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).
WITH CTE110
AS
(
	SELECT GiaoVien.MaGV
	FROM GiaoVien INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
	WHERE NienKhoa = N'2010-2011' OR NienKhoa = N'2011-2012'
)
SELECT TenGV
FROM GiaoVien
WHERE MaGV NOT IN (SELECT * FROM CTE110)

--111.	Thực hiện lại câu 78 nhưng sử dụng CTE: Cho biết tên các môn học không được tổ chức trong năm 2011 (bao gồm cả 2 trường hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).


--112.	Cho biết tên các khoa không có sinh viên.


--113.	Cho biết (Masv, Hoten, Phai ) của các sinh viên chưa được nhập (hoặc chưa có) điểm.


--114.	Thống kê số sinh viên nam, số sinh viên nữ của các khoa. Kết xuất có dạng:
--MaKhoa	TenKhoa	SoSVNam	SoSVNu
			
--Lưu ý: chỉ thống kê đối với các sinh viên hiện còn đang học


--115.	Cho biết danh sách sinh viên trong trường có học tất cả các môn trong danh sách môn học. Kết xuất có dạng:
--MaKhoa	MaSV	MaMH	TenMH
			
--116.	Thống kê số sinh viên nam, số sinh viên nữ của các khoa. Kết xuất có dạng:
--MaKhoa	TenKhoa	SoSVNam	SoSVNu
--Lưu ý: chỉ thống kê đối với các sinh viên hiện còn đang học.


--117.	Thống kê tỷ lệ sinh viên nam, sinh viên nữ theo từng xếp loại của từng khoa.


--118.	Cho biết sĩ số của các khoa trong trường . Kết xuất có dạng:
--MaKhoa	TenKhoa	Siso	
--Lưu ý: chỉ tính sĩ số đối với các sinh viên hiện còn đang học (NgayRaTruong=NULL).


--119.	Cho biết danh sách sinh viên trong trường có học tất cả các môn trong danh sách môn học. Kết xuất có dạng:
--MaKhoa	MaSV	MaMH	TenMH
WITH CTE119A
AS
(
	SELECT MaMH
	FROM MonHoc
)
WITH CTE119B
AS
(
	SELECT DISTINCT SinhVien.mssv, COUNT(*)
	FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
					INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	GROUP BY SinhVien.MSSV
)
			
--120.	Để có thể so sánh kết quả học tập của sinh viên qua các khóa học, người ta muốn tạo kết quả truy vấn gồm tất cả các field có trong table KetQua và thêm vào 1 cột (DiemCaoNhatCuaSV) bên phải như sau:*/
WITH CTE120
AS
(
	SELECT MSSV, MAX(DiemKhoaHoc) AS DiemCaoNhatCuaSV
	FROM KetQua
	GROUP BY MSSV
)
SELECT KetQua.MSSV, MaKhoaHoc, DiemKhoaHoc, DiemCaoNhatCuaSV
FROM KetQua INNER JOIN CTE120 ON KetQua.MSSV = CTE120.MSSV
---------------
WITH CTE120
AS
(
	SELECT MSSV, MAX(DiemKhoaHoc) AS DiemCaoNhatCuaSV
	FROM KetQua
	GROUP BY MSSV
)
SELECT KetQua.MSSV, KetQua.MaKhoaHoc, DiemKhoaHoc, DiemCaoNhatCuaSV
FROM KetQua LEFT JOIN CTE120 ON KetQua.MSSV = CTE120.MSSV
ORDER BY KetQua.MSSV

--121.	Tương tự câu trên, để có thể so sánh kết quả học tập của các sinh viên tham gia khóa học, người ta muốn tạo kết quả truy vấn gồm tất cả các field có trong table KetQua và thêm vào 1 cột (DiemCaoNhatCuaKhoaHoc) bên phải như sau:
WITH CTE121
AS
(
	SELECT MaKhoaHoc, MAX(DiemKhoaHoc) AS DiemCaoNhatCuaKhoaHoc
	FROM KetQua
	GROUP BY MaKhoaHoc
)
SELECT KetQua.MaKhoaHoc, KetQua.MSSV, DiemKhoaHoc, DiemCaoNhatCuaKhoaHoc
FROM KetQua LEFT JOIN CTE121 ON KetQua.MaKhoaHoc = CTE121.MaKhoaHoc
ORDER BY KetQua.MaKhoaHoc

/*122.	 Tạo thống kê về điểm trung bình của tất cả các Khoa cho niên khóa 2011-2012 như hình minh họa. Với các yêu cầu sau:  
-	Định dạng để các điểm trung bình chỉ có tối đa 2 số lẻ.
-	Nếu trong học kỳ (hoặc niên khóa) mà SV của Khoa không có đăng ký học (giá trị = NULL), sẽ hiển thị câu thông báo “Không có SV đăng ký học” */
WITH CTE122A
AS
(
	SELECT Khoa.MaKhoa, TenKhoa, DTBNam2011 = AVG(DiemKhoaHoc)
	FROM Khoa LEFT JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
				LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				LEFT JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE NienKhoa = N'2011-2012'
	GROUP BY Khoa.MaKhoa, TenKhoa
),
CTE122B
AS
(
	SELECT Khoa.MaKhoa, TenKhoa, DTBHK1_2011 = AVG(DiemKhoaHoc)
	FROM Khoa LEFT JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
				LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				LEFT JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE NienKhoa = N'2011-2012' AND HocKy = 1
	GROUP BY Khoa.MaKhoa, TenKhoa
),
CTE122C
AS
(
	SELECT Khoa.MaKhoa, TenKhoa, DTBHK2_2011 = AVG(DiemKhoaHoc)
	FROM Khoa LEFT JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
				LEFT JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				LEFT JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE NienKhoa = N'2011-2012' AND HocKy = 2
	GROUP BY Khoa.MaKhoa, TenKhoa
)
SELECT Khoa.MaKhoa, Khoa.TenKhoa, DTBNam2011 = IIF(DTBNam2011 IS NULL, N'Không có SV đăng ký học', CAST(ROUND(DTBNam2011, 2) AS nvarchar(5))), 
									DTBHK1_2011 = IIF(DTBHK1_2011 IS NULL, N'Không có SV đăng ký học', CAST(ROUND(DTBHK1_2011, 2) AS nvarchar(5))),
									DTBHK2_2011 = IIF(DTBHK2_2011 IS NULL, N'Không có SV đăng ký học', CAST(ROUND(DTBHK2_2011, 2) AS nvarchar(5)))
FROM Khoa LEFT JOIN CTE122A ON Khoa.MaKhoa = CTE122A.MaKhoa
			LEFT JOIN CTE122B ON CTE122A.MaKhoa = CTE122B.MaKhoa
			LEFT JOIN CTE122C ON CTE122B.MaKhoa = CTE122C.MaKhoa

--123.	Tạo thống kê về điểm trung bình của tất cả các Khoa cho niên khóa 2011-2012 như hình minh họa. Với yêu cầu nếu SV của Khoa không có tham gia khóa học (giá trị = NULL), sẽ hiển thị thay thế NULL bằng dấu gạch ngang (-).  
WITH CTE123A
AS
(
	SELECT GiangDay.MaKhoaHoc, DiemKhoaHoc
	FROM GiangDay LEFT JOIN KetQua ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
					LEFT JOIN SinhVien ON KetQua.MSSV = SinhVien.MSSV
					LEFT JOIN Khoa ON SinhVien.MaKhoa = Khoa.MaKhoa
)

--124.	Thống kê sinh viên theo xếp loại học tập


-- Programming in SQL Server
--134.	Nhận tham số là mã số môn học, in ra tên môn học, số lượng sinh viên đã có điểm môn học đó, và các điểm nhỏ nhất, 
--điểm lớn nhất, điểm trung bình của môn học.
CREATE OR ALTER PROC dbo.sp_Cau134
	@ma nvarchar(4)
AS
	SELECT TenMH, SLSV = COUNT(*), DiemNhoNhat = MIN(DiemKhoaHoc), DiemLonNhat = MAX(DiemKhoaHoc)
	FROM MonHoc INNER JOIN GiangDay ON MonHoc.MaMH = GiangDay.MaMH
				INNER JOIN KetQua ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
	WHERE MonHoc.MaMH = @ma
	GROUP BY TenMH
--
EXEC dbo.sp_Cau134 'CSDL'

--135.	Liệt kê các sinh viên thuộc khoa  @MaKhoa có DiemKhoaHoc cao nhất của môn @MaMonHoc. 
--Với  @MaKhoa và @MaMonHoc là 2 tham số được truyền vào cho SP.
CREATE OR ALTER PROC dbo.sp_Cau135
	@MaKhoa nvarchar(10), @MaMonHoc nvarchar(10)
AS
	SELECT SinhVien.MSSV, Ten, DiemCaoNhat = MAX(DiemKhoaHoc)
	FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
					INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE MaKhoa = @MaKhoa AND MaMH = @MaMonHoc
	GROUP BY SinhVien.MSSV, Ten
--
EXEC dbo.sp_Cau135 'CNTT', 'CSDL'

--136.	Nhận 2 tham số là @MaKhoa và @MaMonHoc, liệt kê danh sách sinh viên thuộc khoa @MaKhoa bị thi lại (DiemKhoaHoc<5) của môn @MaMonHoc. 
--Kết xuất có dạng: MaSV	HoTen	NgaySinh	DiemThi
CREATE OR ALTER PROC dbo.sp_Cau136
	@MaKhoa nvarchar(10), @MaMonHoc nvarchar(10)
AS
	SELECT SinhVien.MSSV, Ten, DiemKhoaHoc
	FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
					INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
	WHERE MaKhoa = @MaKhoa AND MaMH = @MaMonHoc AND DiemKhoaHoc < 5
--
EXEC dbo.sp_Cau136 'TOAN', 'CTDL'

--137.	Thống kê tỷ lệ đậu, rớt của từng môn học.
--MaMH	TenMH	SLDau	SLRot
			
/*3.7.1.	Tạo Stored Procedure với OUTPUT Parameter cho các câu sau đây:
138.	Tạo SP nhận tham số là mã số sinh viên, SP trả về họ và tên của sinh viên đó.*/


--139.	Tạo SP nhận tham số là mã số sinh viên, SP trả về số lượng khóa học mà sinh viên không đạt (DiemKhoaHoc<5).


--140.	Tạo SP nhận 2 tham số là tên giáo viên (X) và tên sinh viên (Y), SP trả về kết quả cho biết 
--sinh viên Y có từng học những khóa học do giáo viên Y giảng dạy hay không?


/*141.	Tạo SP nhận tham số là mã khoa, SP trả về tên khoa, số lượng SV đạt được của mỗi loại Xuất sắc/Giỏi/Khá/Trung bình/ Yếu (dựa trên field DTBTichLuy trong table SinhVien). Biết rằng việc phân loại dựa trên quy định như sau:
	nếu 	DTBTichLuy <5.0		: yếu
5.0 <= DTBTichLuy < 6.5	: trung bình
6.5 <= DTBTichLuy < 8.0	: khá
8.0 <= DTBTichLuy < 9.0	: giỏi
9.0 <= DTBTichLuy <=10.0	: xuất sắc*/

/*3.10	Tối ưu hóa câu truy vấn (Query Optimization)
Đối với các câu trong phần này, sinh viên cần thực hiện cả 2 cách trước và sau khi tối ưu hóa. 
178.	Cho biết mssv, tên và DiemKhoaHoc của những sinh viên đã học môn Cơ sở dữ liệu do cô Phạm Thị Thảo giảng dạy.*/
-- Chưa tối ưu
SELECT DISTINCT SinhVien.MSSV, Ten, DiemKhoaHoc
FROM SinhVien INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
				INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
				INNER JOIN GiaoVien ON GiangDay.MaGV = GiaoVien.MaGV
				INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
WHERE TenMH = N'Cơ sở dữ liệu' AND TenGV = N'Phạm Thị Thảo'
-- Tối ưu
SELECT DISTINCT S.MSSV, S.Ten, K.DiemKhoaHoc
FROM (SELECT MSSV, Ten FROM SinhVien) S
		INNER JOIN (SELECT MSSV, MaKhoaHoc, DiemKhoaHoc FROM KetQua) K ON S.MSSV = K.MSSV
		INNER JOIN (SELECT MaKhoaHoc, MaGV, MaMH FROM GiangDay) D ON K.MaKhoaHoc = D.MaKhoaHoc
		INNER JOIN (SELECT MaGV FROM GiaoVien WHERE TenGV = N'Phạm Thị Thảo') V ON D.MaGV = V.MaGV
		INNER JOIN (SELECT MaMH FROM MonHoc WHERE TenMH = N'Cơ sở dữ liệu') M ON D.MaMH = M.MaMH

--179.	Cho biết mssv, tên và DiemKhoaHoc của những sinh viên không thuộc khoa Công nghệ thông tin nhưng có học những môn 
--do giáo viên thuộc khoa Công nghệ thông tin giảng dạy.
--Chua toi uu
SELECT SinhVien.MSSV,SinhVien.Ten,KetQua.DiemKhoaHoc
FROM Khoa INNER JOIN SinhVien ON Khoa.MaKhoa = SinhVien.MaKhoa
			INNER JOIN KetQua ON SinhVien.MSSV = KetQua.MSSV
			INNER JOIN GiangDay ON KetQua.MaKhoaHoc = GiangDay.MaKhoaHoc
			INNER JOIN GiaoVien ON GiangDay.MaGV = GiaoVien.MaGV
WHERE SinhVien.MaKhoa NOT IN (SELECT MaKhoa FROM Khoa K WHERE K.TenKhoa = N'Công nghệ thông tin')
	AND GiaoVien.MaKhoa IN (SELECT MaKhoa FROM Khoa K1 WHERE K1.TenKhoa = N'Công nghệ thông tin')
--Toi uu
SELECT S.MSSV, Ten, DiemKhoaHoc
FROM (SELECT MaKhoa FROM Khoa) KH
		INNER JOIN (SELECT MSSV, Ten, MaKhoa 
					FROM SinhVien
					WHERE MaKhoa NOT IN (SELECT MaKhoa FROM Khoa K WHERE K.TenKhoa = N'Công nghệ thông tin')) S ON KH.MaKhoa = S.MaKhoa
		INNER JOIN (SELECT MSSV, MaKhoaHoc, DiemKhoaHoc FROM KetQua) K ON S.MSSV = K.MSSV
		INNER JOIN (SELECT MaKhoaHoc, MaGV FROM GiangDay) G ON K.MaKhoaHoc = G.MaKhoaHoc
		INNER JOIN (SELECT MaGV
					FROM GiaoVien
					WHERE MaKhoa IN (SELECT MaKhoa FROM Khoa K1 WHERE K1.TenKhoa = N'Công nghệ thông tin')) V ON G.MaGV = V.MaGV

--180.	Cho biết tên giáo viên, DiemKhoaHoc mà giáo viên này đã cho đối với sinh viên Nguyễn Thanh Long 
--khi dạy môn Kỹ thuật lập trình trong học kỳ 2 năm học 2011-2012.
SELECT GiaoVien.TenGV,KetQua.DiemKhoaHoc
FROM GiaoVien
INNER JOIN GiangDay ON GiaoVien.MaGV = GiangDay.MaGV
INNER JOIN MonHoc ON GiangDay.MaMH = MonHoc.MaMH
INNER JOIN KetQua ON GiangDay.MaKhoaHoc = KetQua.MaKhoaHoc
INNER JOIN SinhVien ON KetQua.MSSV = SinhVien.MSSV
WHERE SinhVien.Ten = N'Nguyễn Thanh Long'
AND MonHoc.TenMH = N'Kỹ thuật lập trình'
AND GiangDay.NienKhoa = '2011-2012' AND HocKy = 2
-- Toi uu
SELECT TenGV,DiemKhoaHoc
FROM (SELECT MaGV,TenGV FROM GiaoVien ) AS GV
INNER JOIN (SELECT MaGV,MaMH,MaKhoaHoc FROM GiangDay WHERE NienKhoa = '2011-2012' AND HocKy = 2) AS GD ON GV.MaGV = GD.MaGV
INNER JOIN (SELECT MaMH FROM MonHoc WHERE TenMH = N'Kỹ thuật lập trình') AS M ON GD.MaMH = M.MaMH
INNER JOIN (SELECT MSSV,MaKhoaHoc,DiemKhoaHoc FROM KetQua) AS K ON GD.MaKhoaHoc = K.MaKhoaHoc
INNER JOIN (SELECT MSSV FROM SinhVien WHERE Ten = N'Nguyễn Thanh Long') AS S ON K.MSSV = S.MSSV

--181.	Cho biết mã số và tên của các SV đã học đủ 2 môn ‘CSDL’ & ’CTDL’ hoặc có DiemKhoaHoc của 1 trong 2 môn đạt từ 7 đến 8.

