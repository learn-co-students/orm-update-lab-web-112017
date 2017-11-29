require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def self.create_table
    DB[:conn].execute("
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT);
    ")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end

  def save #push to database, set new id, id checker
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO students(name,grade) VALUES (?,?);", self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?;", self.name, self.grade, self.id)
  end

  def self.create(name,grade)
    self.new(name,grade).save
  end

  def self.new_from_db(row) #id,name,grade
    a = self.new(row[1], row[2])
    a.id = row[0]
    a
  end

  def self.find_by_name(name)
    a=DB[:conn].execute("SELECT * FROM students WHERE name = ?",name)[0]
    self.new_from_db(a)
  end

end
