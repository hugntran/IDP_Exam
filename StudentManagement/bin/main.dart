import 'dart:convert';
import 'dart:io';

String filePath = "../data/students.json"; // Đường dẫn file JSON

void main() {
  print("Chương trình Quản Lý Sinh Viên");

  while (true) {
    print("\n----- MENU -----");
    print("1. Hiển thị toàn bộ sinh viên");
    print("2. Thêm sinh viên");
    print("3. Sửa thông tin sinh viên");
    print("4. Tìm kiếm sinh viên theo Tên hoặc ID");
    print("5. Thoát");

    stdout.write("Chọn chức năng: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case "1":
        displayStudents();
        break;
      case "2":
        addStudent();
        break;
      case "3":
        editStudent();
        break;
      case "4":
        searchStudent();
        break;
      case "5":
        print("Thoát chương trình.");
        return;
      default:
        print("Lựa chọn không hợp lệ, vui lòng chọn lại.");
    }
  }
}

// Đọc file JSON
List<Map<String, dynamic>> readFile() {
  try {
    final file = File(filePath);
    if (!file.existsSync()) {
      file.writeAsStringSync("[]"); // Nếu file chưa tồn tại, tạo file rỗng
    }
    String content = file.readAsStringSync();
    List<dynamic> jsonData = jsonDecode(content);
    return jsonData.cast<Map<String, dynamic>>(); // Ép kiểu đúng
  } catch (e) {
    print("Lỗi khi đọc file: $e");
    return [];
  }
}

// Ghi file JSON
void writeFile(List<Map<String, dynamic>> data) {
  try {
    final file = File(filePath);
    file.writeAsStringSync(jsonEncode(data));
  } catch (e) {
    print("Lỗi khi ghi file: $e");
  }
}

// 1️⃣ Hiển thị toàn bộ sinh viên
void displayStudents() {
  List<Map<String, dynamic>> students = readFile();
  if (students.isEmpty) {
    print("Không có sinh viên nào!");
    return;
  }
  print("\n----- Danh Sách Sinh Viên -----");
  for (var student in students) {
    print("ID: ${student['id']}, Tên: ${student['name']}");
    print("Môn học:");
    for (var subject in student['subjects']) {
      print("- ${subject['name']}: ${subject['score']}");
    }
  }
}

// 2️⃣ Thêm sinh viên mới
void addStudent() {
  List<Map<String, dynamic>> students = readFile();

  stdout.write("Nhập ID: ");
  int id = int.parse(stdin.readLineSync()!);

  stdout.write("Nhập tên sinh viên: ");
  String name = stdin.readLineSync()!;

  List<Map<String, dynamic>> subjects = [];
  while (true) {
    stdout.write("Nhập tên môn học (hoặc nhấn Enter để dừng): ");
    String? subjectName = stdin.readLineSync();
    if (subjectName == null || subjectName.isEmpty) break;

    stdout.write("Nhập điểm: ");
    double score = double.parse(stdin.readLineSync()!);

    subjects.add({"name": subjectName, "score": score});
  }

  students.add({"id": id, "name": name, "subjects": subjects});
  writeFile(students);
  print("✅ Đã thêm sinh viên thành công!");
}

// 3️⃣ Sửa thông tin sinh viên
void editStudent() {
  List<Map<String, dynamic>> students = readFile();

  stdout.write("Nhập ID sinh viên cần sửa: ");
  int id = int.parse(stdin.readLineSync()!);

  var student = students.firstWhere((s) => s['id'] == id, orElse: () => {});
  if (student.isEmpty) {
    print("❌ Không tìm thấy sinh viên!");
    return;
  }

  stdout.write("Nhập tên mới (hoặc Enter để giữ nguyên): ");
  String? newName = stdin.readLineSync();
  if (newName != null && newName.isNotEmpty) {
    student['name'] = newName;
  }

  print("1. Thêm môn học mới");
  print("2. Sửa điểm môn học");
  print("3. Xóa môn học");
  print("4. Hoàn tất chỉnh sửa");

  while (true) {
    stdout.write("Chọn chức năng: ");
    String? option = stdin.readLineSync();

    switch (option) {
      case "1":
        stdout.write("Nhập tên môn học: ");
        String subjectName = stdin.readLineSync()!;
        stdout.write("Nhập điểm: ");
        double score = double.parse(stdin.readLineSync()!);
        student['subjects'].add({"name": subjectName, "score": score});
        break;
      case "2":
        stdout.write("Nhập tên môn học cần sửa điểm: ");
        String subjectName = stdin.readLineSync()!;
        var subject = student['subjects'].firstWhere(
                (s) => s['name'] == subjectName,
            orElse: () => {});
        if (subject.isEmpty) {
          print("❌ Không tìm thấy môn học!");
        } else {
          stdout.write("Nhập điểm mới: ");
          subject['score'] = double.parse(stdin.readLineSync()!);
        }
        break;
      case "3":
        stdout.write("Nhập tên môn học cần xóa: ");
        String subjectName = stdin.readLineSync()!;
        student['subjects'].removeWhere((s) => s['name'] == subjectName);
        break;
      case "4":
        writeFile(students);
        print("✅ Đã cập nhật thông tin sinh viên!");
        return;
      default:
        print("Lựa chọn không hợp lệ!");
    }
  }
}

// 4️⃣ Tìm kiếm sinh viên theo Tên hoặc ID
void searchStudent() {
  List<Map<String, dynamic>> students = readFile();

  stdout.write("Nhập Tên hoặc ID sinh viên cần tìm: ");
  String query = stdin.readLineSync()!;

  var results = students.where((s) =>
  s['id'].toString() == query || s['name'].toLowerCase().contains(query.toLowerCase()));

  if (results.isEmpty) {
    print("❌ Không tìm thấy sinh viên!");
  } else {
    print("\n----- Kết Quả Tìm Kiếm -----");
    for (var student in results) {
      print("ID: ${student['id']}, Tên: ${student['name']}");
      print("Môn học:");
      for (var subject in student['subjects']) {
        print("- ${subject['name']}: ${subject['score']}");
      }
    }
  }
}
