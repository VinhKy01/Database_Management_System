USE QLBD


/** 1. Cho biết họ tên, vị trí, và tên câu lạc bộ của các cầu thủ mang áo số 9. **/
	
	SELECT ct.hoten, ct.vitri, clb.tenclb 
	FROM CAUTHU ct, CAULACBO clb
	WHERE ct.maclb = clb.maclb
	AND ct.so='9'

/** 2. Cho biết tên các CLB có cầu thủ nước ngoài (quốc tịch khác Việt Nam). **/

	SELECT clb.TENCLB
	FROM CAULACBO clb, CAUTHU ct, QUOCGIA qg
	WHERE clb.MACLB = ct.MACLB
	AND ct.MAQG = qg.MAQG
	AND qg.MAQG != 'VN'

/** 3. Cho biết tên cầu thủ đã ghi từ 2 bàn thắng trở lên trong một trận đấu. **/

	SELECT ct.hoten, tg.sotrai 
	FROM CAUTHU ct, THAMGIA tg
	WHERE ct.mact = tg.mact
	AND tg.sotrai >= 2
	GROUP BY ct.hoten, tg.sotrai

/** 4. Cho biết mã số, họ tên của những cầu thủ có họ không phải họ Nguyễn. **/

	SELECT hoten
	FROM CAUTHU
	WHERE hoten not in (SELECT hoten
						FROM CAUTHU
						WHERE hoten like N'Nguyễn%')

/** 5. Cho biết tên câu lạc bộ có huấn luyện viên chính sinh ngày 20 tháng 5. **/

	SELECT clb.tenclb, hlv.tenhlv, hlv.ngaysinh
	FROM CAULACBO clb, HLV_CLB hlv_clb ,HUANLUYENVIEN hlv
	WHERE clb.maclb = hlv_clb.maclb
	AND hlv_clb.mahlv = hlv.mahlv
	AND hlv_clb.vaitro = N'HLV Chính'
	AND MONTH(hlv.ngaysinh) = '05'
	AND DAY(hlv.ngaysinh) = '20'

/** 6. Cho biết tên các câu lạc bộ cùng số lượng cầu thủ thuộc CLB đó. **/

	SELECT clb.tenclb, count(clb.tenclb)
	FROM CAULACBO AS clb, CAUTHU AS ct 
	WHERE clb.maclb = ct.maclb 
	GROUP BY clb.tenclb

	HAVING COUNT(clb.tenclb) not in (SELECT COUNT(DISTINCT clb.tenclb) AS temp
									FROM CAULACBO AS clb, CAUTHU AS ct 
									WHERE clb.maclb = ct.maclb )
	ORDER BY COUNT(clb.tenclb) ASC

/** 7. Cho biết tên SVĐ diễn ra nhiều trận đấu nhất **/

	SELECT TOP 1 s.tensan, COUNT(s.tensan) AS 'So tran dau' 
	FROM SANVD AS s, TRANDAU AS t 
	WHERE s.masan = t.masan 
	GROUP BY s.tensan
	ORDER BY count(s.tensan) DESC

/** 8. Cho biết tên các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn luyện tại bất kỳ một câu lạc bộ nào **/

	 SELECT tenhlv 
	 FROM HUANLUYENVIEN 
	 WHERE mahlv not in (SELECT mahlv 
						 FROM HLV_CLB) 
						 AND maqg='VN' 

					/********************************** BÀI TẬP VIEW **********************************/

/** 9. Cho biết mã số, họ tên, ngày sinh, địa chỉ, vị trí của các cầu thủ thuộc đội bóng “SHB Đà Nẵng” có quốc tịch “Bra-xin”. **/

	CREATE VIEW C9 AS
	SELECT ct.mact, ct.hoten, ct.ngaysinh, ct.diachi, ct.vitri
	FROM CAUTHU ct, CAULACBO clb, QUOCGIA qg
	WHERE ct.maclb = clb.maclb
	AND ct.maqg = qg.maqg
	AND clb.tenclb = N'SHB Đà Nẵng'
	AND qg.tenqg = N'Bra-xin'

/** 10. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, vai trò, tên CLB đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”. **/

	CREATE VIEW C10 AS
	SELECT hlv.mahlv, hlv.tenhlv, hlv.ngaysinh, hlv.diachi, hlv_clb.vaitro, clb.tenclb
	FROM HUANLUYENVIEN hlv, HLV_CLB hlv_clb, QUOCGIA qg, CAULACBO clb
	WHERE clb.maclb = hlv_clb.maclb
	AND hlv.mahlv = hlv_clb.mahlv
	AND hlv.maqg = qg.maqg
	AND qg.maqg = N'VN'

/** 11. Cho biết kết quả các trận đấu vòng 3 của mùa bóng năm 2009, thông tin gồm mã trận, ngày thi đấu, tên sân, tên CLB1, tên CLB2, kết quả. **/

	SELECT td.matran, td.ngaytd, svd.tensan, td.maclb1, td.maclb2, td.ketqua
	FROM TRANDAU td, SANVD svd, CAULACBO clb
	WHERE td.maclb1 = clb.maclb
	AND td.masan = svd.masan
	AND td.vong = 3
	AND td.nam = 2009

/** 12. Cho biết tên huấn luyện viên đang nắm giữ một vị trí trong một câu lạc bộ mà chưa có số điện thoại. **/

	SELECT hlv.tenhlv, hlv.dienthoai
	FROM HUANLUYENVIEN hlv, HLV_CLB hlv_clb
	WHERE hlv.mahlv = hlv_clb.mahlv
	AND hlv.tenhlv not in (SELECT tenhlv
						  FROM HUANLUYENVIEN
						  WHERE dienthoai like '%0%')

/** 13. Cho biết tên tỉnh, số lượng cầu thủ đang thi đấu ở vị trí tiền đạo trong các câu lạc bộ thuộc địa bàn tỉnh đó quản lý. **/

	SELECT t.tentinh, COUNT(ct.mact) AS
	FROM TINH t, CAUTHU ct, CAULACBO clb
	WHERE t.matinh = clb.matinh
	AND clb.maclb = ct.maclb
	GROUP BY ct.mact, tt.tentinh
