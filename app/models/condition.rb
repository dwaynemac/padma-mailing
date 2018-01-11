# encoding: UTF-8
class Condition < ActiveRecord::Base
  attr_accessible :key, :value

  belongs_to :trigger

  validates_presence_of :key
  validates_presence_of :value

  SUGGESTED_VALUES = {
    status: ["prospect", "former_student", "student"],
    coefficient: ["unknown", "fp","pmenos", "perfil", "pmas"],
    level: ["aspirante", "sádhaka", "yôgin", "chêla", "graduado", "asistente", "docente", "maestro"]
  }
end
