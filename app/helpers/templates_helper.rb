module TemplatesHelper

  def tags_description
    tags={}
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
    time_slot = {"[Time Slot's Time]" => "1. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", 
               "[Time Slot's Name]" => "2. Lorem Ipsum is simply dummy text of the printing and typesetting industry."}

    contact = {"[Contact's Full Name]" => "3.Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                "[Contact's First Name]" => "4. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                "[Contact's Last Name]" => "5. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                "[Contact's Gender]" => "6. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", 
                "[Contact's a_u_o]" => "7. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", 
                "[Contact's Instructor Name]" => "8. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", 
                "[Contact's Instructor Email]" => "9. Lorem Ipsum is simply dummy text of the printing and typesetting industry."}

    instructor = {"[Instructor's Name]" => "10. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", 
                "[Instructor's email" => "11. Lorem Ipsum is simply dummy text of the printing and typesetting industry."}

    trial_lesson = {"[Trial Lesson's Date]" => "12. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", 
                            "[Instructor's Trial Lesson's Name]" => "13. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                            "[Instructor's Trial Lesson's Email]" => "14 Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                            "[Instructor's Time Slot Time]" => "15. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                            "[Instructor's Trial Lesson Name]" => "9. Lorem Ipsum is simply dummy text of the printing and typesetting industry."}
    
    tags.merge!(time_slot).merge!(instructor).merge!(contact).merge!(trial_lesson)                            
  end

end