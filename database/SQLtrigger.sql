-- TRigger


Drop trigger trg_InsertKhachHangFromUser
CREATE TRIGGER trg_InsertFromUser
ON tbUser
AFTER INSERT
AS
BEGIN
    DECLARE @SĐT INT;
    DECLARE @Email NVARCHAR(50);
    DECLARE @Type INT;
    DECLARE @newMaKH NVARCHAR(50);
    DECLARE @newMaNV NVARCHAR(50);
    DECLARE @maxSoThuTuKH INT;
    DECLARE @maxSoThuTuNV INT;

    -- Lấy thông tin từ bản ghi mới được chèn vào bảng tbUser
    SELECT @SĐT = i.SĐT, @Email = i.PassWord, @Type = i.[Type]
    FROM inserted i;

    -- Nếu Type = 1, chèn vào bảng tbKhachHang
    IF @Type = 1
    BEGIN
        -- Lấy số thứ tự lớn nhất hiện tại từ tbKhachHang
        SELECT @maxSoThuTuKH = ISNULL(MAX(CAST(SUBSTRING(MaKH, 3, LEN(MaKH) - 2) AS INT)), 0)
        FROM tbKhachHang;

        -- Tạo MaKH mới: 'KH' + số thứ tự lớn nhất + 1
        SET @newMaKH = 'KH' + CAST(@maxSoThuTuKH + 1 AS NVARCHAR(50));

        -- Thêm khách hàng mới vào bảng tbKhachHang
        INSERT INTO tbKhachHang (MaKH, SĐT, Email)
        VALUES (@newMaKH, @SĐT, @Email);
    END
    -- Nếu Type = 0, chèn vào bảng tbNhanVien
    ELSE IF @Type = 0
    BEGIN
        -- Lấy số thứ tự lớn nhất hiện tại từ tbNhanVien
        SELECT @maxSoThuTuNV = ISNULL(MAX(CAST(SUBSTRING(MaNV, 3, LEN(MaNV) - 2) AS INT)), 0)
        FROM tbNhanVien;

        -- Tạo MaNV mới: 'NV' + số thứ tự lớn nhất + 1
        SET @newMaNV = 'NV' + CAST(@maxSoThuTuNV + 1 AS NVARCHAR(50));

        -- Thêm nhân viên mới vào bảng tbNhanVien
        INSERT INTO tbNhanVien (MaNV, SĐT, Email)
        VALUES (@newMaNV, @SĐT, @Email);
    END
END;

INSERT INTO tbUser (SĐT, PassWord, [Type])
VALUES (123, 'password123', 0);
Select * from tbKhachHang
Select * from tbNhanVien
Select * from tbUser
-- tính 1 chitietdonhang




-- tăng tự động id ma sp

-- thêm danh mục
CREATE TRIGGER trg_InsertDanhMuc
ON tbSanPham
AFTER INSERT
AS
BEGIN
    DECLARE @MaDanhMuc NVARCHAR(50);
    DECLARE @TenDanhMuc NVARCHAR(100);

    -- Lặp qua tất cả các bản ghi mới được chèn vào bảng SanPham
    DECLARE cur CURSOR FOR
    SELECT i.MaDanhMuc, d.TenDanhMuc
    FROM inserted i
    LEFT JOIN tbDanhMuc d ON i.MaDanhMuc = d.MaDanhMuc
    WHERE d.MaDanhMuc IS NULL; -- Chỉ thêm nếu MaDanhMuc chưa tồn tại trong bảng DanhMuc

    OPEN cur;

    FETCH NEXT FROM cur INTO @MaDanhMuc, @TenDanhMuc;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Thêm dữ liệu vào bảng DanhMuc
        INSERT INTO tbDanhMuc (MaDanhMuc, TenDanhMuc)
        VALUES (@MaDanhMuc, 'Danh mục mới');

        FETCH NEXT FROM cur INTO @MaDanhMuc, @TenDanhMuc;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;


--Hien thi san pham theo danh muc
CREATE PROCEDURE GetSanPhamByMaDanhMuc
    @MaDanhMuc NVARCHAR(50)  -- Tham số đầu vào
AS
BEGIN
    SET NOCOUNT ON;  -- Ngăn chặn thông báo số dòng bị ảnh hưởng

    SELECT 
        sp.MaSP,
        sp.TenSP,
        sp.MoTa,
        sp.GiaBan,
        sp.GiaNhap,
        sp.SL
    FROM 
        tbSanPham sp
    WHERE 
        sp.MaDanhMuc = @MaDanhMuc;  -- Lọc theo MaDanhMuc
END;
EXEC GetSanPhamByMaDanhMuc @MaDanhMuc = 'BB';
-- tim kiem san pham theo từ khoá tên sản phẩm
CREATE PROCEDURE SearchSanPhamByName
    @TenSP NVARCHAR(100)  -- Tham số đầu vào để tìm kiếm theo tên sản phẩm
AS
BEGIN
    SET NOCOUNT ON;  -- Ngăn không hiển thị thông báo ảnh hưởng số dòng

    -- Truy vấn tìm kiếm sản phẩm theo tên
    SELECT 
        sp.MaSP,
        sp.TenSP,
        sp.MoTa,
        sp.GiaBan,
        sp.GiaNhap,
        sp.SL,
        sp.MaDanhMuc
		
    FROM 
        tbSanPham sp
    WHERE 
        TenSP LIKE '%' + @TenSP + '%'  -- Tìm kiếm theo chuỗi con
END;
EXEC SearchSanPhamByName @TenSP = 'Oishi';
drop PROCEDURE SearchSanPhamByName
-- procedure truyền vào mã sản phẩm thì trả về ảnh sản phẩm đó 
CREATE PROCEDURE GetAnhSanPhamByMaSP
    @MaSP NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Truy vấn lấy ảnh của sản phẩm theo MaSP
    SELECT 
        sp.MaSP,
        sp.TenSP,
        asp.TenFileAnh,
        asp.IdAnh
    FROM 
        tbSanPham sp
    INNER JOIN 
        tbAnhSanPham asp ON sp.MaSP = asp.MaSP
    WHERE 
        sp.MaSP = @MaSP;
END;
EXEC GetAnhSanPhamByMaSP @MaSP='SP01'
