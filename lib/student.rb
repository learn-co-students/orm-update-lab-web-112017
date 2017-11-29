require_relative "../config/environment.rb"

A = DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER primary key,
      name TEXT,
      grade TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    #new
      sql = <<-SQL
      INSERT INTO students (name,grade)
      VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
    end
    #### find or create by name
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql =<<-SQL
    SELECT * FROM students where name = (?);
    SQL

    query_result = DB[:conn].execute(sql, name)
    self.new_from_db(query_result.first)
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = (?), grade = (?) where id = (?);
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
