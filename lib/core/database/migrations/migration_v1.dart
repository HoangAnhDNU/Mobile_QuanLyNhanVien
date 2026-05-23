import 'package:sqflite/sqflite.dart';

class MigrationV1 {
  static Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('admin', 'manager', 'employee')),
        employee_id TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE departments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        manager_id TEXT,
        description TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE positions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        allowance REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        employee_code TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        date_of_birth TEXT,
        gender TEXT CHECK(gender IN ('male', 'female', 'other')),
        department_id TEXT,
        position_id TEXT,
        phone TEXT,
        email TEXT,
        start_date TEXT,
        contract_type TEXT CHECK(contract_type IN ('full_time', 'part_time', 'intern', 'contractor')),
        base_salary REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'on_leave', 'resigned')),
        avatar_url TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
        FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('present', 'absent_approved', 'absent_unapproved', 'late')),
        check_in_time TEXT,
        check_out_time TEXT,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
        UNIQUE(employee_id, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE salaries (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        work_days INTEGER NOT NULL DEFAULT 0,
        base_salary REAL NOT NULL,
        allowance REAL NOT NULL DEFAULT 0,
        deduction REAL NOT NULL DEFAULT 0,
        net_salary REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
        UNIQUE(employee_id, month, year)
      )
    ''');

    await db.execute('''
      CREATE TABLE leave_requests (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        reason TEXT,
        status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'approved', 'rejected')),
        approved_by TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
        FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_employees_department ON employees(department_id)');
    await db.execute('CREATE INDEX idx_employees_status ON employees(status)');
    await db.execute('CREATE INDEX idx_employees_code ON employees(employee_code)');
    await db.execute('CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date)');
    await db.execute('CREATE INDEX idx_salaries_employee_month ON salaries(employee_id, month, year)');
    await db.execute('CREATE INDEX idx_leave_requests_employee ON leave_requests(employee_id)');
    await db.execute('CREATE INDEX idx_leave_requests_status ON leave_requests(status)');

    // Seed default admin user (password: admin123)
    await db.execute('''
      INSERT INTO users (id, username, password_hash, role, status, created_at)
      VALUES ('usr_admin_001', 'admin', 'admin123', 'admin', 'active', datetime('now'))
    ''');

    // Seed sample departments
    await db.execute('''
      INSERT INTO departments (id, name, description, created_at) VALUES
      ('dept_001', 'Phòng Kỹ thuật', 'Phòng phát triển phần mềm và hạ tầng', datetime('now')),
      ('dept_002', 'Phòng Nhân sự', 'Phòng quản lý nhân sự và tuyển dụng', datetime('now')),
      ('dept_003', 'Phòng Kinh doanh', 'Phòng kinh doanh và marketing', datetime('now')),
      ('dept_004', 'Phòng Tài chính', 'Phòng kế toán và tài chính', datetime('now')),
      ('dept_005', 'Phòng Hành chính', 'Phòng hành chính tổng hợp', datetime('now'))
    ''');

    // Seed sample positions
    await db.execute('''
      INSERT INTO positions (id, name, level, allowance, created_at) VALUES
      ('pos_001', 'Giám đốc', 5, 10000000, datetime('now')),
      ('pos_002', 'Phó Giám đốc', 4, 7000000, datetime('now')),
      ('pos_003', 'Trưởng phòng', 3, 5000000, datetime('now')),
      ('pos_004', 'Phó phòng', 3, 3000000, datetime('now')),
      ('pos_005', 'Nhân viên chính', 2, 1500000, datetime('now')),
      ('pos_006', 'Nhân viên', 1, 1000000, datetime('now')),
      ('pos_007', 'Thực tập sinh', 0, 500000, datetime('now'))
    ''');
  }
}
