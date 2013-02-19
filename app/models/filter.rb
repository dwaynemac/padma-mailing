class Filter < ActiveRecord::Base
  attr_accessible :key, :trigger_id, :value

  belongs_to :trigger

  validates_presence_of :key
  validates_presence_of :value

  SUGGESTED_VALUES = {
      'estimated_coefficient' => [
          ['unknown','??'],
          ['pmenos','P-'],
          ['perfil','P'],
          ['pmas','P+']
      ],
      'contact_gender' => [
          ['h','Hombre'],
          ['m','Mujer']
      ]
  }

end
