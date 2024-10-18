import base64
import pyodbc
import flask
from Config import *
from SQLQuery import *
try:
    # kết nối
    conn = pyodbc.connect(con_str)
    print("Kết nối Thành công")
    app = flask.Flask(__name__)
    # GET: select, POST: insert, PUT: cập nhật dữ liệu, DELETE: xóa dữ liệu
    @app.route('/sanpham/getall', methods=['GET'])
    def getAllBook():
        try:
            cursor = conn.cursor()
            sql = SQLSPGETALL
            cursor.execute(sql)
            results = [] # kết quả
            keys = []
            for i in cursor.description: # lấy các key
                keys.append(i[0])
            for i in cursor.fetchall(): # lấy tất cả bản ghi
                results.append(dict(zip(keys, i)))
            resp = flask.jsonify(results)
            resp.status_code = 200
            return resp
        except Exception as e:
            return flask.jsonify({"lỗi":e})    
    
    @app.route('/sanpham/getbyname/<ten>', methods=['GET'])
    def getByName(ten):
        try:
            cursor = conn.cursor()
            sql = "exec SearchSanPhamByName @TenSP = ?"  # Thay thế với tên thủ tục của bạn
            data = (ten,)  # Tham số truyền vào
            cursor.execute(sql, data)
            
            result = []
            keys = [column[0] for column in cursor.description]  # Lấy các key
            for row in cursor.fetchall():  # Lấy kết quả
                result.append(dict(zip(keys, row)))

            resp = flask.jsonify(result)  # Trả về kết quả
            resp.status_code = 200
            return resp
        except Exception as e:
            return flask.jsonify({"lỗi": str(e)}), 500  # Trả về lỗi nếu có
    @app.route('/sanpham/getanh/<masp>', methods=['GET'])
    def get_image_by_masp(masp):
        try:
            cursor = conn.cursor()
            sql = "EXEC GetAnhSanPhamByMaSP @MaSP = ?"
            cursor.execute(sql, (masp,))

            result = []
            keys = [column[0] for column in cursor.description]  # Lấy các key từ mô tả
            for row in cursor.fetchall():  # Lấy kết quả
            # Mã hóa ảnh thành base64
                image_data = row[2]  # Giả sử TenFileAnh là cột thứ 3 trong kết quả
                image_base64 = base64.b64encode(image_data).decode('utf-8')
                result.append({
                    'MaSP': row[0],
                    'TenSP': row[1],
                    'TenFileAnh': image_base64,
                    'IdAnh': row[3]
                })

            resp = flask.jsonify(result)
            resp.status_code = 200
            return resp
        except Exception as e:
            return flask.jsonify({"lỗi": str(e)}), 500  # Trả về lỗi nếu có

   
    if __name__ == "__main__":
        app.run()
        
        
except:
    print("Lỗi")
